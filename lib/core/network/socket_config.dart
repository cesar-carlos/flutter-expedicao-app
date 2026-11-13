import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:data7_expedicao/core/network/socket_connect_wait.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';

class SocketConfig {
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const String sessionEndedMessage = 'O servidor encerrou a sessão.';

  static io.Socket? _socketInstance;
  static ApiConfig? _currentApiConfig;
  static DateTime? _connectionAttemptStarted;
  static Completer<void>? _connectWait;

  static final List<void Function()> _rebindCallbacks = <void Function()>[];
  static final List<void Function()> _disconnectCallbacks = <void Function()>[];
  static bool _trafficPaused = false;
  static bool _sessionEndedByServer = false;

  /// Métrica de tentativa de conexão. Preenchido na borda de DI
  /// (`NetworkInitializer`), sem `locator` nesta classe.
  static void Function(bool success, Duration duration)? onConnectionAttempt;

  static void initialize(ApiConfig apiConfig) {
    _disposeCurrentSocket();
    _currentApiConfig = apiConfig;
    _socketInstance = _createSocketInstance(apiConfig);
  }

  static io.Socket get instance {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado. Chame SocketConfig.initialize() primeiro.');
    }
    return _socketInstance!;
  }

  static String get socketUrl {
    if (_currentApiConfig == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    return _currentApiConfig!.fullUrl;
  }

  static bool get isConnected => _socketInstance?.connected ?? false;

  static String? get sessionId => _socketInstance?.id;

  static bool get isTrafficPaused => _trafficPaused;

  static bool get isSessionEndedByServer => _sessionEndedByServer;

  static bool get isTrafficBlocked => _trafficPaused || _sessionEndedByServer;

  static void pauseForServerDisconnect() {
    _trafficPaused = true;
  }

  static void markSessionEndedByServer() {
    _trafficPaused = true;
    _sessionEndedByServer = true;
  }

  static void clearServerDisconnectPause() {
    _trafficPaused = false;
    _sessionEndedByServer = false;
  }

  static void updateConfig(ApiConfig newConfig) {
    final configChanged =
        (_currentApiConfig?.apiUrl != newConfig.apiUrl ||
        _currentApiConfig?.apiPort != newConfig.apiPort ||
        _currentApiConfig?.useHttps != newConfig.useHttps);

    if (!configChanged) {
      return;
    }

    _currentApiConfig = newConfig;
    _disposeCurrentSocket();
    _socketInstance = _createSocketInstance(newConfig);
    _notifyRebind();
  }

  static void addRebindListener(void Function() callback) {
    if (!_rebindCallbacks.contains(callback)) {
      _rebindCallbacks.add(callback);
    }
  }

  static void removeRebindListener(void Function() callback) {
    _rebindCallbacks.remove(callback);
  }

  static void addDisconnectListener(void Function() callback) {
    if (!_disconnectCallbacks.contains(callback)) {
      _disconnectCallbacks.add(callback);
    }
  }

  static void removeDisconnectListener(void Function() callback) {
    _disconnectCallbacks.remove(callback);
  }

  static void _notifyRebind() {
    for (final callback in List<void Function()>.from(_rebindCallbacks)) {
      try {
        callback();
      } catch (e, s) {
        AppLogger.warning(
          'Falha ao re-vincular listeners apos recriacao do socket',
          tag: 'SocketConfig',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  static void _notifyDisconnect() {
    for (final callback in List<void Function()>.from(_disconnectCallbacks)) {
      try {
        callback();
      } catch (e, s) {
        AppLogger.warning('Falha ao notificar disconnect do socket', tag: 'SocketConfig', error: e, stackTrace: s);
      }
    }
  }

  static Future<void> connect({Duration timeout = connectionTimeout}) async {
    if (isTrafficBlocked) {
      throw StateError(sessionEndedMessage);
    }
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    if (_socketInstance!.connected) {
      AppLogger.debug('Socket ja conectado, connect() ignorado', tag: 'SocketConfig');
      return;
    }
    if (_connectWait != null) {
      return _connectWait!.future;
    }

    final socket = _socketInstance!;
    final completer = Completer<void>();
    _connectWait = completer;
    _connectionAttemptStarted = DateTime.now();

    late final void Function() offConnect;
    late final void Function() offError;

    offConnect = socket.onConnect((_) {
      _completeConnectWait();
    });
    offError = socket.onConnectError((error) {
      _failConnectWait(TimeoutException('Falha ao conectar com o servidor: $error'));
    });

    if (socket.connected) {
      offConnect();
      offError();
      _completeConnectWait();
      return;
    }

    socket.connect();

    try {
      await waitForSocketConnect(
        wait: completer,
        timeout: timeout,
        onTimeout: () {
          _socketInstance?.disconnect();
        },
      );
    } finally {
      offConnect();
      offError();
      if (identical(_connectWait, completer)) {
        _connectWait = null;
      }
    }
  }

  static void disconnect() {
    _failConnectWait(StateError('Conexão encerrada.'));
    _socketInstance?.disconnect();
  }

  static Future<void> reconnect({Duration timeout = connectionTimeout}) async {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    _socketInstance!.disconnect();
    await connect(timeout: timeout);
  }

  static io.Socket _createSocketInstance(ApiConfig apiConfig) {
    _connectionAttemptStarted = DateTime.now();

    final socket = io.io(apiConfig.fullUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': false,
      'forceNew': true,
    });

    socket.onConnect((_) {
      try {
        AppLogger.connection('Socket conectado', tag: 'SocketConfig');
        AppLogger.data('SessionId: ${socket.id}', tag: 'SocketConfig');
        _recordConnectionAttempt(true);
      } catch (_) {}
    });

    socket.onDisconnect((reason) {
      try {
        AppLogger.warning('Socket desconectado', tag: 'SocketConfig');
        AppLogger.data('Motivo: $reason', tag: 'SocketConfig');
        _failConnectWait(StateError('Conexão com o servidor foi perdida.'));
        _notifyDisconnect();
      } catch (_) {}
    });

    socket.onError((error) {
      try {
        AppLogger.error('Erro no socket', tag: 'SocketConfig', error: error);
      } catch (_) {}
    });

    socket.onConnectError((error) {
      try {
        AppLogger.error('Erro ao conectar socket', tag: 'SocketConfig', error: error);
        _recordConnectionAttempt(false);
      } catch (_) {}
    });

    return socket;
  }

  static void _completeConnectWait() {
    final wait = _connectWait;
    _connectWait = null;
    if (wait != null && !wait.isCompleted) {
      wait.complete();
    }
  }

  static void _failConnectWait(Object error) {
    final wait = _connectWait;
    _connectWait = null;
    if (wait != null && !wait.isCompleted) {
      wait.completeError(error);
    }
  }

  static void _recordConnectionAttempt(bool success) {
    final started = _connectionAttemptStarted;
    _connectionAttemptStarted = null;
    if (started == null) {
      return;
    }
    final duration = DateTime.now().difference(started);
    onConnectionAttempt?.call(success, duration);
  }

  static bool get isInitialized => _socketInstance != null;

  static void _disposeCurrentSocket() {
    _failConnectWait(StateError('Conexão encerrada.'));
    final socket = _socketInstance;
    _socketInstance = null;
    if (socket == null) {
      return;
    }
    try {
      socket.dispose();
    } catch (e, s) {
      AppLogger.warning(
        'Falha ao descartar instancia anterior do socket',
        tag: 'SocketConfig',
        error: e,
        stackTrace: s,
      );
    }
  }

  static void reset() {
    _disposeCurrentSocket();
    _currentApiConfig = null;
    _connectionAttemptStarted = null;
    _rebindCallbacks.clear();
    _disconnectCallbacks.clear();
    onConnectionAttempt = null;
    clearServerDisconnectPause();
  }

  static void dispose() {
    reset();
  }
}
