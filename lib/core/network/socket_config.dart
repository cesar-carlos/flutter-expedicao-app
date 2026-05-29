import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';

class SocketConfig {
  static io.Socket? _socketInstance;
  static ApiConfig? _currentApiConfig;
  static DateTime? _connectionAttemptStarted;

  /// Callbacks chamados sempre que a instancia do socket e recriada
  /// (ex.: apos `updateConfig` com troca de host/porta). Servicos que
  /// registram listeners de eventos (`on(...)`) na instancia precisam
  /// re-vincula-los no novo socket, caso contrario as atualizacoes em
  /// tempo real param de chegar no socket descartado.
  static final List<void Function()> _rebindCallbacks = <void Function()>[];

  static void initialize(ApiConfig apiConfig) {
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

  static bool get isConnected {
    return _socketInstance?.connected ?? false;
  }

  static String? get sessionId {
    return _socketInstance?.id;
  }

  static void updateConfig(ApiConfig newConfig) {
    final configChanged =
        (_currentApiConfig?.apiUrl != newConfig.apiUrl ||
        _currentApiConfig?.apiPort != newConfig.apiPort ||
        _currentApiConfig?.useHttps != newConfig.useHttps);

    if (configChanged) {
      _currentApiConfig = newConfig;
      _socketInstance?.disconnect();
      _socketInstance = _createSocketInstance(newConfig);
      // Socket recriado: os listeners registrados na instancia anterior
      // ficaram orfaos. Notifica os servicos para re-vincularem no novo
      // socket de forma idempotente.
      _notifyRebind();
    }
  }

  /// Registra um callback de re-vinculo de listeners. Idempotente: o
  /// mesmo callback nao e adicionado duas vezes.
  static void addRebindListener(void Function() callback) {
    if (!_rebindCallbacks.contains(callback)) {
      _rebindCallbacks.add(callback);
    }
  }

  static void removeRebindListener(void Function() callback) {
    _rebindCallbacks.remove(callback);
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

  static Future<void> connect() async {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    // Bug U: connect() idempotente — se ja conectado, no-op.
    // Antes, chamadas redundantes geravam novas tentativas (poluindo
    // logs de metricas e disparando callbacks duplicados).
    if (_socketInstance!.connected) {
      AppLogger.debug('Socket ja conectado, connect() ignorado', tag: 'SocketConfig');
      return;
    }
    _connectionAttemptStarted = DateTime.now();
    _socketInstance!.connect();
  }

  static void disconnect() {
    _socketInstance?.disconnect();
  }

  static Future<void> reconnect() async {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    _socketInstance!.disconnect();
    _socketInstance!.connect();
  }

  static io.Socket _createSocketInstance(ApiConfig apiConfig) {
    _connectionAttemptStarted = DateTime.now();

    final socket = io.io(apiConfig.fullUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'reconnectionAttempts': 5,
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

    socket.onReconnect((_) {
      try {
        AppLogger.connection('Socket reconectado', tag: 'SocketConfig');
        AppLogger.data('SessionId: ${socket.id}', tag: 'SocketConfig');
        // Bug V: registra metrica de reconnect tambem (antes so registrava
        // o connect inicial, perdendo dados de qualidade de rede em
        // sessoes longas com varias reconexoes).
        _recordConnectionAttempt(true);
      } catch (_) {}
    });

    socket.onReconnectError((error) {
      try {
        AppLogger.warning('Erro ao reconectar socket', tag: 'SocketConfig', error: error);
      } catch (_) {}
    });

    socket.onReconnectFailed((_) {
      try {
        AppLogger.error('Falha total ao reconectar socket', tag: 'SocketConfig');
      } catch (_) {}
    });

    return socket;
  }

  static void _recordConnectionAttempt(bool success) {
    final started = _connectionAttemptStarted;
    _connectionAttemptStarted = null;
    if (started == null) return;
    final duration = DateTime.now().difference(started);
    try {
      locator<MetricsCollector>().recordConnectionAttempt(success, duration);
    } catch (_) {}
  }

  static bool get isInitialized => _socketInstance != null;

  static void reset() {
    _socketInstance?.disconnect();
    _socketInstance = null;
    _currentApiConfig = null;
    _connectionAttemptStarted = null;
  }

  static void dispose() {
    reset();
  }
}
