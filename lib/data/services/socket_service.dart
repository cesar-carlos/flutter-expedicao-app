import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/services/i_socket_connection_port.dart';

export 'package:data7_expedicao/domain/services/i_socket_connection_port.dart' show SocketConnectionState;

class SocketService extends ChangeNotifier implements ISocketConnectionPort {
  static const int _maxReconnectAttempts = 10;
  static const List<Duration> _reconnectDelays = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 15),
    Duration(seconds: 30),
  ];

  SocketConnectionState _connectionState = SocketConnectionState.disconnected;
  final Map<String, StreamController<dynamic>> _eventStreams = {};
  final Map<String, void Function(dynamic)> _socketHandlers = {};
  Timer? _reconnectTimer;
  Completer<void>? _connectInFlight;
  String? _userId;
  int _reconnectAttempts = 0;
  bool _manualDisconnect = false;
  bool _listenersRegistered = false;

  @override
  SocketConnectionState get connectionState => _connectionState;

  @override
  bool get isConnected => _connectionState == SocketConnectionState.connected;

  @override
  String? get userId => _userId;

  Future<void> initialize(ApiConfig apiConfig, {String? userId}) async {
    try {
      _userId = userId;
      AppLogger.init('Inicializando SocketService', tag: 'SocketService');
      AppLogger.data('URL: ${apiConfig.fullUrl}, userId: $userId', tag: 'SocketService');
      if (SocketConfig.isInitialized) {
        SocketConfig.updateConfig(apiConfig);
      } else {
        SocketConfig.initialize(apiConfig);
      }
      SocketConfig.addRebindListener(_rebindListeners);
      _setupSocketListeners();
      await connect();
    } catch (e) {
      AppLogger.error('Falha ao inicializar SocketService', tag: 'SocketService', error: e);
      _updateConnectionState(SocketConnectionState.error);
    }
  }

  @override
  Future<void> connect() async {
    if (isConnected) {
      return;
    }
    if (_connectInFlight != null) {
      return _connectInFlight!.future;
    }

    _manualDisconnect = false;
    final completer = Completer<void>();
    _connectInFlight = completer;
    _updateConnectionState(SocketConnectionState.connecting);

    try {
      AppLogger.connection('Tentando conectar socket', tag: 'SocketService');
      await SocketConfig.connect();
      _reconnectAttempts = 0;
      if (SocketConfig.isConnected) {
        _updateConnectionState(SocketConnectionState.connected);
        completer.complete();
        return;
      }
      throw StateError('Conexão com o servidor não foi estabelecida.');
    } catch (e, s) {
      AppLogger.error('Falha ao conectar socket', tag: 'SocketService', error: e, stackTrace: s);
      _updateConnectionState(SocketConnectionState.error);
      if (!completer.isCompleted) {
        completer.completeError(e, s);
      }
      if (!_manualDisconnect) {
        _scheduleReconnect();
      }
      rethrow;
    } finally {
      if (identical(_connectInFlight, completer)) {
        _connectInFlight = null;
      }
    }
  }

  @override
  void disconnect() {
    try {
      _manualDisconnect = true;
      _cancelReconnectTimer();
      _reconnectAttempts = 0;
      SocketConfig.disconnect();
      _updateConnectionState(SocketConnectionState.disconnected);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao desconectar socket', tag: 'SocketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> reconnect() async {
    _cancelReconnectTimer();
    _reconnectAttempts = 0;
    _manualDisconnect = true;
    try {
      _updateConnectionState(SocketConnectionState.reconnecting);
      if (SocketConfig.isConnected) {
        SocketConfig.disconnect();
      }
      _manualDisconnect = false;
      await connect();
    } catch (e) {
      _updateConnectionState(SocketConnectionState.error);
      rethrow;
    }
  }

  void _scheduleReconnect() {
    if (_manualDisconnect) {
      return;
    }
    if (_reconnectTimer != null) {
      return;
    }
    if (isConnected) {
      return;
    }
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.error('Número máximo de tentativas de reconexão atingido', tag: 'SocketService');
      _updateConnectionState(SocketConnectionState.error);
      return;
    }

    _reconnectAttempts++;
    final delayIndex = (_reconnectAttempts - 1).clamp(0, _reconnectDelays.length - 1);
    final delay = _reconnectDelays[delayIndex];

    AppLogger.connection(
      'Agendando reconexão em ${delay.inSeconds}s (tentativa $_reconnectAttempts/$_maxReconnectAttempts)',
      tag: 'SocketService',
    );

    _updateConnectionState(SocketConnectionState.reconnecting);
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      unawaited(
        _runReconnectTick().catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha não tratada no tick de reconexão do socket',
            tag: 'SocketService',
            error: e,
            stackTrace: s,
          );
        }),
      );
    });
  }

  Future<void> _runReconnectTick() async {
    if (_manualDisconnect || isConnected) {
      return;
    }

    try {
      await connect();
      if (!isConnected && !_manualDisconnect) {
        _scheduleReconnect();
      }
    } catch (e) {
      AppLogger.error('Falha na reconexão', tag: 'SocketService', error: e);
      if (!_manualDisconnect) {
        _scheduleReconnect();
      }
    }
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  @override
  void emit(String eventName, dynamic data, {bool propagateErrors = true}) {
    try {
      if (!SocketConfig.isConnected) {
        throw StateError('Socket não está conectado');
      }

      SocketConfig.instance.emit(eventName, data);
      AppLogger.operation('Evento emitido: $eventName', tag: 'SocketService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao emitir evento socket: $eventName',
        tag: 'SocketService',
        error: e,
        stackTrace: stackTrace,
      );
      if (propagateErrors) {
        rethrow;
      }
    }
  }

  @override
  Stream<dynamic> on(String eventName) {
    if (!_eventStreams.containsKey(eventName)) {
      _eventStreams[eventName] = StreamController<dynamic>.broadcast();
      void handler(dynamic data) {
        _eventStreams[eventName]?.add(data);
      }

      _socketHandlers[eventName] = handler;
      SocketConfig.instance.on(eventName, handler);
    }

    return _eventStreams[eventName]!.stream;
  }

  @override
  void off(String eventName) {
    final handler = _socketHandlers.remove(eventName);
    if (handler != null) {
      SocketConfig.instance.off(eventName, handler);
    }
    _eventStreams[eventName]?.close();
    _eventStreams.remove(eventName);
  }

  void updateConfig(ApiConfig newConfig) {
    try {
      final wasConnected = isConnected;
      AppLogger.init('Atualizando config do socket', tag: 'SocketService');
      AppLogger.data('Nova URL: ${newConfig.fullUrl}', tag: 'SocketService');

      _cancelReconnectTimer();
      _reconnectAttempts = 0;
      _manualDisconnect = true;
      _updateConnectionState(SocketConnectionState.disconnected);

      SocketConfig.updateConfig(newConfig);

      if (wasConnected) {
        _manualDisconnect = false;
        _updateConnectionState(SocketConnectionState.connecting);
        unawaited(
          connect().catchError((Object e, StackTrace s) {
            AppLogger.warning(
              'Falha ao reconectar após atualizar config do socket',
              tag: 'SocketService',
              error: e,
              stackTrace: s,
            );
          }),
        );
      } else {
        _updateConnectionState(SocketConnectionState.disconnected);
      }
    } catch (e) {
      AppLogger.error('Falha ao atualizar config do socket', tag: 'SocketService', error: e);
      _updateConnectionState(SocketConnectionState.error);
      rethrow;
    }
  }

  void _rebindListeners() {
    _listenersRegistered = false;
    _setupSocketListeners();

    final socket = SocketConfig.instance;
    for (final entry in _socketHandlers.entries) {
      socket.on(entry.key, entry.value);
    }
  }

  void _setupSocketListeners() {
    if (_listenersRegistered) {
      return;
    }
    _listenersRegistered = true;

    final socket = SocketConfig.instance;

    socket.onConnect((_) {
      _cancelReconnectTimer();
      _reconnectAttempts = 0;
      _updateConnectionState(SocketConnectionState.connected);
    });

    socket.onDisconnect((reason) {
      _updateConnectionState(SocketConnectionState.disconnected);
      final wasClientDisconnect = reason == 'io client disconnect';
      if (!_manualDisconnect && !wasClientDisconnect) {
        _scheduleReconnect();
      }
    });

    socket.onConnectError((data) {
      _updateConnectionState(SocketConnectionState.error);
      if (!_manualDisconnect) {
        _scheduleReconnect();
      }
    });

    socket.onError((data) {
      if (!isConnected) {
        _updateConnectionState(SocketConnectionState.error);
      }
    });
  }

  void _updateConnectionState(SocketConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    SocketConfig.removeRebindListener(_rebindListeners);
    _cancelReconnectTimer();
    _manualDisconnect = true;

    for (final stream in _eventStreams.values) {
      stream.close();
    }
    _eventStreams.clear();
    _socketHandlers.clear();

    disconnect();
    SocketConfig.dispose();
    super.dispose();
  }
}
