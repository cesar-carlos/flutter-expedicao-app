import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';

enum SocketEvent { userLocationUpdate, scannerResult, notification, statusUpdate, chatMessage }

enum SocketConnectionState { disconnected, connecting, connected, reconnecting, error }

class SocketService extends ChangeNotifier {
  SocketConnectionState _connectionState = SocketConnectionState.disconnected;
  final Map<String, StreamController> _eventStreams = {};
  Timer? _heartbeatTimer;
  String? _userId;

  SocketConnectionState get connectionState => _connectionState;

  bool get isConnected => _connectionState == SocketConnectionState.connected;

  String? get userId => _userId;

  Future<void> initialize(ApiConfig apiConfig, {String? userId}) async {
    try {
      _userId = userId;
      SocketConfig.initialize(apiConfig);
      _setupSocketListeners();
      await connect();
    } catch (e) {
      _updateConnectionState(SocketConnectionState.error);
    }
  }

  Future<void> connect() async {
    if (_connectionState == SocketConnectionState.connected) {
      return;
    }

    try {
      _updateConnectionState(SocketConnectionState.connecting);
      await SocketConfig.connect();
    } catch (e) {
      _updateConnectionState(SocketConnectionState.error);
    }
  }

  void disconnect() {
    try {
      _stopHeartbeat();
      SocketConfig.disconnect();
      _updateConnectionState(SocketConnectionState.disconnected);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reconnect() async {
    try {
      _updateConnectionState(SocketConnectionState.reconnecting);
      await SocketConfig.reconnect();
    } catch (e) {
      _updateConnectionState(SocketConnectionState.error);
    }
  }

  void emit(String eventName, dynamic data) {
    if (!isConnected) {
      return;
    }

    try {
      final payload = {'userId': _userId, 'timestamp': DateTime.now().toIso8601String(), 'data': data};

      SocketConfig.instance.emit(eventName, payload);
    } catch (e) {
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
      SocketConfig.updateConfig(newConfig);
      if (isConnected) {
        reconnect();
      }
    } catch (e) {
      rethrow;
    }
  }

  void _setupSocketListeners() {
    final socket = SocketConfig.instance;

    socket.onConnect((_) {
      _updateConnectionState(SocketConnectionState.connected);
      _startHeartbeat();

      if (_userId != null) {
        emit('user_join', {'userId': _userId});
      }
    });

    socket.onDisconnect((_) {
      _updateConnectionState(SocketConnectionState.disconnected);
      _stopHeartbeat();
    });

    socket.onConnectError((data) {
      _updateConnectionState(SocketConnectionState.error);
    });

    socket.onError((data) {
      _updateConnectionState(SocketConnectionState.error);
    });

    socket.onReconnect((_) {
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
