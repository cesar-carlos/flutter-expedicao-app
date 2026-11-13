import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/domain/services/i_socket_connection_port.dart';
import 'package:data7_expedicao/di/locator.dart';

class SocketViewModel extends ChangeNotifier {
  ISocketConnectionPort? _socketService;
  VoidCallback? _connectionListener;
  bool _disposed = false;

  ISocketConnectionPort get socketService {
    _socketService ??= locator<ISocketConnectionPort>();
    if (_connectionListener == null && !_disposed) {
      _setupConnectionListener();
    }
    return _socketService!;
  }

  SocketConnectionState get connectionState => socketService.connectionState;

  bool get isConnected => socketService.isConnected;

  bool get isSessionEndedByServer => socketService.isSessionEndedByServer;

  String? get userId => socketService.userId;

  void initialize() {
    if (_connectionListener != null) {
      return;
    }
    _setupConnectionListener();
  }

  Future<void> connect() => socketService.connect();

  void disconnect() => socketService.disconnect();

  Future<void> reconnect() => socketService.reconnect();

  Future<void> reconnectAfterServerEnd() => socketService.reconnectAfterServerEnd();

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
    _connectionListener = () {
      if (_disposed) {
        return;
      }
      notifyListeners();
    };
    socketService.addListener(_connectionListener!);
  }

  String get connectionStateDescription {
    if (isSessionEndedByServer) {
      return 'Sessão encerrada';
    }
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
    if (isSessionEndedByServer) {
      return 0xFFFF5722;
    }
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
    _disposed = true;
    if (_socketService != null && _connectionListener != null) {
      _socketService!.removeListener(_connectionListener!);
      _connectionListener = null;
    }
    super.dispose();
  }
}
