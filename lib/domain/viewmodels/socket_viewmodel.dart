import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/data/services/socket_service.dart';
import 'package:data7_expedicao/di/locator.dart';

class SocketViewModel extends ChangeNotifier {
  SocketService? _socketService;
  StreamSubscription? _connectionStateSubscription;

  SocketService get socketService {
    _socketService ??= locator<SocketService>();
    return _socketService!;
  }

  SocketConnectionState get connectionState => socketService.connectionState;

  bool get isConnected => socketService.isConnected;

  String? get userId => socketService.userId;

  void initialize() {
    _setupConnectionListener();

    _autoConnect();
  }

  void _autoConnect() {
    Future.delayed(const Duration(seconds: 2), () {
      if (connectionState == SocketConnectionState.disconnected) {
        connect();
      }
    });
  }

  Future<void> connect() async {
    try {
      await socketService.connect();
    } catch (e) {}
  }

  void disconnect() {
    try {
      socketService.disconnect();
    } catch (e) {}
  }

  Future<void> reconnect() async {
    try {
      await socketService.reconnect();
    } catch (e) {}
  }

  void sendLocationUpdate(double latitude, double longitude) {
    if (!isConnected) {
      return;
    }

    socketService.sendLocationUpdate(latitude, longitude);
  }

  void sendScannerResult(String scanData, String scanType) {
    if (!isConnected) {
      return;
    }

    socketService.sendScannerResult(scanData, scanType);
  }

  void sendMessage(String message, {String? recipientId}) {
    if (!isConnected) {
      return;
    }

    socketService.sendMessage(message, recipientId);
  }

  Stream<dynamic> listenToEvent(String eventName) {
    return socketService.on(eventName);
  }

  void stopListeningToEvent(String eventName) {
    socketService.off(eventName);
  }

  void emitCustomEvent(String eventName, dynamic data) {
    if (!isConnected) {
      return;
    }

    socketService.emit(eventName, data);
  }

  void _setupConnectionListener() {
    _connectionStateSubscription =
        socketService.addListener(() {
              notifyListeners();
            })
            as StreamSubscription?;
  }

  String get connectionStateDescription {
    switch (connectionState) {
      case SocketConnectionState.disconnected:
        return 'Desconectado';
      case SocketConnectionState.connecting:
        return 'Conectando...';
      case SocketConnectionState.connected:
        return 'Conectado';
      case SocketConnectionState.reconnecting:
        return 'Reconectando...';
      case SocketConnectionState.error:
        return 'Erro de conexão';
    }
  }

  int get connectionStateColor {
    switch (connectionState) {
      case SocketConnectionState.disconnected:
        return 0xFF9E9E9E;
      case SocketConnectionState.connecting:
      case SocketConnectionState.reconnecting:
        return 0xFFFF9800;
      case SocketConnectionState.connected:
        return 0xFF4CAF50;
      case SocketConnectionState.error:
        return 0xFFFF5722;
    }
  }

  @override
  void dispose() {
    _connectionStateSubscription?.cancel();
    super.dispose();
  }
}
