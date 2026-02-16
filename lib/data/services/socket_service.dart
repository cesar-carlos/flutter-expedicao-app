import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';

enum SocketConnectionState { disconnected, connecting, connected, reconnecting, error }

class SocketService extends ChangeNotifier {
  SocketConnectionState _connectionState = SocketConnectionState.disconnected;
  final Map<String, StreamController> _eventStreams = {};
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  String? _userId;
  int _reconnectAttempts = 0;
  bool _isReconnecting = false;
  static const int _maxReconnectAttempts = 10;

  SocketConnectionState get connectionState => _connectionState;

  bool get isConnected => _connectionState == SocketConnectionState.connected;

  String? get userId => _userId;

  Future<void> initialize(ApiConfig apiConfig, {String? userId}) async {
    try {
      _userId = userId;
      AppLogger.init('Inicializando SocketService', tag: 'SocketService');
      AppLogger.data('URL: ${apiConfig.fullUrl}, userId: $userId', tag: 'SocketService');
      SocketConfig.initialize(apiConfig);
      _setupSocketListeners();
      await connect();
    } catch (e) {
      AppLogger.error('Falha ao inicializar SocketService', tag: 'SocketService', error: e);
      _updateConnectionState(SocketConnectionState.error);
    }
  }

  Future<void> connect() async {
    if (_connectionState == SocketConnectionState.connected) {
      return;
    }

    try {
      AppLogger.connection('Tentando conectar socket', tag: 'SocketService');
      _updateConnectionState(SocketConnectionState.connecting);
      await SocketConfig.connect();
    } catch (e) {
      AppLogger.error('Falha ao conectar socket', tag: 'SocketService', error: e);
      _updateConnectionState(SocketConnectionState.error);
    }
  }

  void disconnect() {
    try {
      _cancelReconnectTimer();
      _stopHeartbeat();
      _reconnectAttempts = 0;
      SocketConfig.disconnect();
      _updateConnectionState(SocketConnectionState.disconnected);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao desconectar socket', tag: 'SocketService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> reconnect() async {
    if (_isReconnecting) return;

    try {
      _isReconnecting = true;
      _updateConnectionState(SocketConnectionState.reconnecting);
      await SocketConfig.reconnect();
    } catch (e) {
      _updateConnectionState(SocketConnectionState.error);
      rethrow;
    } finally {
      _isReconnecting = false;
    }
  }

  Future<void> _scheduleReconnect() async {
    if (_isReconnecting || _reconnectAttempts >= _maxReconnectAttempts) {
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        AppLogger.error('Número máximo de tentativas de reconexão atingido', tag: 'SocketService');
      }
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;

    final delay = Duration(seconds: min(512, pow(2, _reconnectAttempts - 1).toInt()));

    AppLogger.connection(
      'Agendando reconexão em ${delay.inSeconds}s (tentativa $_reconnectAttempts/$_maxReconnectAttempts)',
      tag: 'SocketService',
    );

    _reconnectTimer = Timer(delay, () async {
      if (_connectionState == SocketConnectionState.connected) {
        _reconnectAttempts = 0;
        _isReconnecting = false;
        return;
      }

      try {
        await connect();
        if (isConnected) {
          _reconnectAttempts = 0;
          AppLogger.connection('Reconexão bem-sucedida', tag: 'SocketService');
        } else {
          await _scheduleReconnect();
        }
      } catch (e) {
        AppLogger.error('Falha na reconexão', tag: 'SocketService', error: e);
        await _scheduleReconnect();
      } finally {
        _isReconnecting = false;
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isReconnecting = false;
  }

  void emit(String eventName, dynamic data) {
    if (!SocketConfig.isConnected) {
      throw StateError('Socket não está conectado');
    }

    try {
      final payload = {'userId': _userId, 'timestamp': DateTime.now().toIso8601String(), 'data': data};

      SocketConfig.instance.emit(eventName, payload);
      AppLogger.operation('Evento emitido: $eventName', tag: 'SocketService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao emitir evento socket: $eventName',
        tag: 'SocketService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Stream<dynamic> on(String eventName) {
    if (!_eventStreams.containsKey(eventName)) {
      _eventStreams[eventName] = StreamController<dynamic>.broadcast();

      SocketConfig.instance.on(eventName, (data) {
        _eventStreams[eventName]?.add(data);
      });
    }

    return _eventStreams[eventName]!.stream;
  }

  void off(String eventName) {
    SocketConfig.instance.off(eventName);
    _eventStreams[eventName]?.close();
    _eventStreams.remove(eventName);
  }

  void sendLocationUpdate(double latitude, double longitude) {
    emit('location_update', {'latitude': latitude, 'longitude': longitude});
  }

  void sendScannerResult(String scanData, String scanType) {
    emit('scanner_result', {'scanData': scanData, 'scanType': scanType});
  }

  void sendMessage(String message, String? recipientId) {
    emit('message', {'message': message, 'recipientId': recipientId});
  }

  void updateConfig(ApiConfig newConfig) {
    try {
      final wasConnected = isConnected;
      AppLogger.init('Atualizando config do socket', tag: 'SocketService');
      AppLogger.data('Nova URL: ${newConfig.fullUrl}', tag: 'SocketService');

      _cancelReconnectTimer();
      _stopHeartbeat();
      _reconnectAttempts = 0;
      _updateConnectionState(SocketConnectionState.disconnected);

      SocketConfig.updateConfig(newConfig);

      _setupSocketListeners();

      if (wasConnected) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (SocketConfig.isConnected) {
            _updateConnectionState(SocketConnectionState.connected);
            _startHeartbeat();
          } else {
            _updateConnectionState(SocketConnectionState.connecting);
            reconnect();
          }
        });
      } else {
        _updateConnectionState(SocketConnectionState.disconnected);
      }
    } catch (e) {
      AppLogger.error('Falha ao atualizar config do socket', tag: 'SocketService', error: e);
      _updateConnectionState(SocketConnectionState.error);
      rethrow;
    }
  }

  void _setupSocketListeners() {
    final socket = SocketConfig.instance;

    socket.onConnect((_) {
      _cancelReconnectTimer();
      _reconnectAttempts = 0;
      _updateConnectionState(SocketConnectionState.connected);
      _startHeartbeat();

      if (_userId != null) {
        emit('user_join', {'userId': _userId});
      }
    });

    socket.onDisconnect((_) {
      _updateConnectionState(SocketConnectionState.disconnected);
      _stopHeartbeat();
      _scheduleReconnect();
    });

    socket.onConnectError((data) {
      _updateConnectionState(SocketConnectionState.error);
      _scheduleReconnect();
    });

    socket.onError((data) {
      _updateConnectionState(SocketConnectionState.error);
    });

    socket.onReconnect((_) {
      _cancelReconnectTimer();
      _reconnectAttempts = 0;
      _updateConnectionState(SocketConnectionState.connected);
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isConnected) {
        emit('heartbeat', {'timestamp': DateTime.now().toIso8601String()});
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _updateConnectionState(SocketConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cancelReconnectTimer();
    _stopHeartbeat();

    for (final stream in _eventStreams.values) {
      stream.close();
    }
    _eventStreams.clear();

    disconnect();
    SocketConfig.dispose();
    super.dispose();
  }
}
