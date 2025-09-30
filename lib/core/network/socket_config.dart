import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:exp/domain/models/api_config.dart';

/// Configuração global do Socket.IO
class SocketConfig {
  static IO.Socket? _socketInstance;
  static ApiConfig? _currentApiConfig;

  /// Inicializa o Socket.IO com configurações globais
  static void initialize(ApiConfig apiConfig) {
    _currentApiConfig = apiConfig;
    _socketInstance = _createSocketInstance(apiConfig);
  }

  /// Obtém a instância global do Socket.IO
  static IO.Socket get instance {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado. Chame SocketConfig.initialize() primeiro.');
    }
    return _socketInstance!;
  }

  /// Obtém a URL do WebSocket baseada na configuração atual
  static String get socketUrl {
    if (_currentApiConfig == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    return _currentApiConfig!.fullUrl;
  }

  /// Verifica se o socket está conectado
  static bool get isConnected {
    return _socketInstance?.connected ?? false;
  }

  /// Obtém o ID da sessão atual do socket
  static String? get sessionId {
    return _socketInstance?.id;
  }

  /// Atualiza as configurações do Socket.IO
  static void updateConfig(ApiConfig newConfig) {
    // Verifica se a configuração mudou
    final configChanged =
        (_currentApiConfig?.apiUrl != newConfig.apiUrl ||
        _currentApiConfig?.apiPort != newConfig.apiPort ||
        _currentApiConfig?.useHttps != newConfig.useHttps);

    // Se a configuração mudou, reconecta o socket
    if (configChanged) {
      _currentApiConfig = newConfig;
      _socketInstance?.disconnect();
      _socketInstance = _createSocketInstance(newConfig);
    }
  }

  /// Conecta ao servidor WebSocket
  static Future<void> connect() async {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    _socketInstance!.connect();
  }

  /// Desconecta do servidor WebSocket
  static void disconnect() {
    _socketInstance?.disconnect();
  }

  /// Reconecta ao servidor WebSocket
  static Future<void> reconnect() async {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    _socketInstance!.disconnect();
    _socketInstance!.connect();
  }

  /// Cria uma nova instância do Socket.IO com as configurações
  static IO.Socket _createSocketInstance(ApiConfig apiConfig) {
    debugPrint('🔌 Conectando ao Socket.IO: ${apiConfig.fullUrl}');

    final socket = IO.io(apiConfig.fullUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'reconnectionAttempts': 5,
    });

    // Adiciona listeners padrão
    socket.onConnect((_) {
      debugPrint('✅ Socket.IO conectado: ${apiConfig.fullUrl}');
      debugPrint('🔑 Socket.IO ID: ${socket.id}');
    });

    socket.onDisconnect((_) {
      debugPrint('❌ Socket.IO desconectado');
    });

    socket.onError((error) {
      debugPrint('❌ Socket.IO erro: $error');
    });

    socket.onConnectError((error) {
      debugPrint('❌ Socket.IO erro de conexão: $error');
    });

    socket.onReconnect((_) {
      debugPrint('🔄 Socket.IO reconectado');
      debugPrint('🔑 Novo Socket.IO ID: ${socket.id}');
    });

    socket.onReconnectError((error) {
      debugPrint('❌ Socket.IO erro de reconexão: $error');
    });

    socket.onReconnectFailed((_) {
      debugPrint('❌ Socket.IO falha na reconexão');
    });

    return socket;
  }

  /// Verifica se o Socket.IO está inicializado
  static bool get isInitialized => _socketInstance != null;

  /// Limpa a configuração (útil para testes)
  static void reset() {
    _socketInstance?.disconnect();
    _socketInstance = null;
    _currentApiConfig = null;
  }

  /// Descarta recursos
  static void dispose() {
    reset();
  }
}
