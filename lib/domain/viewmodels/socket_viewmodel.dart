import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/data/services/socket_service.dart';
import 'package:data7_expedicao/di/locator.dart';

/// ViewModel para gerenciar o estado e comunicação do WebSocket
class SocketViewModel extends ChangeNotifier {
  SocketService? _socketService;
  StreamSubscription? _connectionStateSubscription;

  /// Obtém o serviço de socket
  SocketService get socketService {
    _socketService ??= locator<SocketService>();
    return _socketService!;
  }

  /// Estado atual da conexão
  SocketConnectionState get connectionState => socketService.connectionState;

  /// Verifica se está conectado
  bool get isConnected => socketService.isConnected;

  /// ID do usuário atual
  String? get userId => socketService.userId;

  /// Inicializa o ViewModel e configura listeners
  void initialize() {
    _setupConnectionListener();
    // Tenta conectar automaticamente ao inicializar
    _autoConnect();
  }

  /// Tenta conectar automaticamente
  void _autoConnect() {
    Future.delayed(const Duration(seconds: 2), () {
      if (connectionState == SocketConnectionState.disconnected) {
        connect();
      }
    });
  }

  /// Conecta ao WebSocket
  Future<void> connect() async {
    try {
      await socketService.connect();
    } catch (e) {
      // Erro ao conectar WebSocket no ViewModel
    }
  }

  /// Desconecta do WebSocket
  void disconnect() {
    try {
      socketService.disconnect();
    } catch (e) {
      // Erro ao desconectar WebSocket no ViewModel
    }
  }

  /// Reconecta ao WebSocket
  Future<void> reconnect() async {
    try {
      await socketService.reconnect();
    } catch (e) {
      // Erro ao reconectar WebSocket no ViewModel
    }
  }

  /// Envia dados de localização
  void sendLocationUpdate(double latitude, double longitude) {
    if (!isConnected) {
      // WebSocket não conectado - localização
      return;
    }

    socketService.sendLocationUpdate(latitude, longitude);
  }

  /// Envia resultado de scanner
  void sendScannerResult(String scanData, String scanType) {
    if (!isConnected) {
      // WebSocket não conectado - scanner
      return;
    }

    socketService.sendScannerResult(scanData, scanType);
  }

  /// Envia mensagem
  void sendMessage(String message, {String? recipientId}) {
    if (!isConnected) {
      // WebSocket não conectado - mensagem
      return;
    }

    socketService.sendMessage(message, recipientId);
  }

  /// Escuta eventos específicos do servidor
  Stream<dynamic> listenToEvent(String eventName) {
    return socketService.on(eventName);
  }

  /// Para de escutar um evento específico
  void stopListeningToEvent(String eventName) {
    socketService.off(eventName);
  }

  /// Emite um evento personalizado
  void emitCustomEvent(String eventName, dynamic data) {
    if (!isConnected) {
      // WebSocket não conectado - evento
      return;
    }

    socketService.emit(eventName, data);
  }

  /// Configura listener para mudanças no estado de conexão
  void _setupConnectionListener() {
    _connectionStateSubscription =
        socketService.addListener(() {
              notifyListeners();
            })
            as StreamSubscription?;
  }

  /// Obtém uma descrição amigável do estado de conexão
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

  /// Obtém a cor do indicador de estado
  int get connectionStateColor {
    switch (connectionState) {
      case SocketConnectionState.disconnected:
        return 0xFF9E9E9E; // Cinza
      case SocketConnectionState.connecting:
      case SocketConnectionState.reconnecting:
        return 0xFFFF9800; // Laranja
      case SocketConnectionState.connected:
        return 0xFF4CAF50; // Verde
      case SocketConnectionState.error:
        return 0xFFFF5722; // Vermelho
    }
  }

  @override
  void dispose() {
    _connectionStateSubscription?.cancel();
    super.dispose();
  }
}
