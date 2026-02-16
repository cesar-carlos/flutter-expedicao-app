import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/data/services/socket_service.dart';
import 'package:data7_expedicao/di/locator.dart';

class SocketViewModel extends ChangeNotifier {
  SocketService? _socketService;
  VoidCallback? _connectionListener;

  SocketService get socketService {
    _socketService ??= locator<SocketService>();
    return _socketService!;
  }

  /// Retorna o estado físico de conexão baseado no socket_io_client
  /// Isso garante que a UI mostre o mesmo estado que o repository verifica
  SocketConnectionState get connectionState {
    if (SocketConfig.isConnected) {
      return SocketConnectionState.connected;
    }
    return SocketConnectionState.disconnected;
  }

  bool get isConnected => SocketConfig.isConnected;

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
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao conectar ao socket', tag: 'SocketViewModel', error: e);
      }
    }
  }

  void disconnect() {
    try {
      socketService.disconnect();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao desconectar do socket', tag: 'SocketViewModel', error: e);
      }
    }
  }

  Future<void> reconnect() async {
    try {
      await socketService.reconnect();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao reconectar ao socket', tag: 'SocketViewModel', error: e);
      }
    }
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
    _connectionListener = notifyListeners;
    socketService.addListener(_connectionListener!);
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
    if (_socketService != null && _connectionListener != null) {
      _socketService!.removeListener(_connectionListener!);
      _connectionListener = null;
    }
    super.dispose();
  }
}
