import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:exp/domain/models/api_config.dart';

/// Configuração global do cliente Socket.IO com reatividade
class SocketConfig {
  static IO.Socket? _socketInstance;
  static ApiConfig? _currentApiConfig;
  static bool _isConnected = false;

  // Stream controllers para reatividade
  static final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();
  static final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Callbacks personalizados
  static VoidCallback? _onConnectCallback;
  static VoidCallback? _onDisconnectCallback;
  static Function(dynamic)? _onErrorCallback;

  /// Stream que notifica mudanças no estado de conexão
  static Stream<bool> get connectionStateStream =>
      _connectionStateController.stream;

  /// Stream que notifica erros de conexão
  static Stream<String> get errorStream => _errorController.stream;

  /// Inicializa o Socket.IO com configurações globais
  static void initialize(
    ApiConfig apiConfig, {
    bool autoConnect = false,
    VoidCallback? onConnect,
    VoidCallback? onDisconnect,
    Function(dynamic)? onError,
  }) {
    _currentApiConfig = apiConfig;
    _onConnectCallback = onConnect;
    _onDisconnectCallback = onDisconnect;
    _onErrorCallback = onError;

    _createSocketInstance(apiConfig, autoConnect: autoConnect);

    if (autoConnect && !_isConnected) {
      connect();
    }
  }

  /// Obtém a instância global do Socket
  static IO.Socket get instance {
    if (_socketInstance == null) {
      throw StateError(
        'SocketConfig não foi inicializado. Chame SocketConfig.initialize() primeiro.',
      );
    }
    return _socketInstance!;
  }

  /// Verifica se o Socket foi inicializado
  static bool get isInitialized => _socketInstance != null;

  /// Verifica se o Socket está conectado
  static bool get isConnected => _isConnected;

  /// Obtém a URL do WebSocket baseada na configuração atual
  static String get socketUrl {
    if (_currentApiConfig == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }

    final protocol = _currentApiConfig!.useHttps ? 'https' : 'http';
    return '$protocol://${_currentApiConfig!.apiUrl}:${_currentApiConfig!.apiPort}';
  }

  /// Conecta ao servidor Socket.IO
  static Future<void> connect() async {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }

    if (!_isConnected) {
      debugPrint('🔌 Conectando ao Socket.IO: $socketUrl');
      _socketInstance!.connect();
    }
  }

  /// Desconecta do servidor Socket.IO
  static void disconnect() {
    if (_socketInstance != null && _isConnected) {
      debugPrint('🔌 Desconectando do Socket.IO');
      _socketInstance!.disconnect();
    }
  }

  /// Reconecta ao servidor Socket.IO
  static Future<void> reconnect() async {
    debugPrint('🔄 Reconectando Socket.IO...');
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }

  /// Atualiza a configuração e reconecta se necessário
  static void updateConfig(ApiConfig newConfig, {bool autoReconnect = true}) {
    final shouldReconnect =
        autoReconnect &&
        _isConnected &&
        (_currentApiConfig?.apiUrl != newConfig.apiUrl ||
            _currentApiConfig?.apiPort != newConfig.apiPort ||
            _currentApiConfig?.useHttps != newConfig.useHttps);

    _currentApiConfig = newConfig;

    if (_socketInstance != null) {
      disconnect();
    }

    _createSocketInstance(newConfig);

    if (shouldReconnect) {
      connect();
    }
  }

  /// Cria uma nova instância do Socket.IO
  static void _createSocketInstance(
    ApiConfig apiConfig, {
    bool autoConnect = false,
  }) {
    final socketUrl = _buildSocketUrl(apiConfig);

    _socketInstance = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': autoConnect,
      'timeout': 20000,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'maxReconnectionAttempts': 5,
      'forceNew': true,
    });

    _setupSocketListeners();
  }

  /// Configura os listeners básicos do Socket
  static void _setupSocketListeners() {
    if (_socketInstance == null) return;

    _socketInstance!.onConnect(_handleConnect);
    _socketInstance!.onDisconnect(_handleDisconnect);
    _socketInstance!.onConnectError(_handleConnectError);
    _socketInstance!.onError(_handleError);
    _socketInstance!.onReconnect(_handleReconnect);
    _socketInstance!.onReconnectError(_handleReconnectError);
  }

  /// Handler para evento de conexão
  static void _handleConnect(_) {
    _isConnected = true;
    debugPrint('✅ Socket.IO conectado: $socketUrl');
    _connectionStateController.add(true);
    _onConnectCallback?.call();
  }

  /// Handler para evento de desconexão
  static void _handleDisconnect(_) {
    _isConnected = false;
    debugPrint('❌ Socket.IO desconectado');
    _connectionStateController.add(false);
    _onDisconnectCallback?.call();
  }

  /// Handler para erro de conexão
  static void _handleConnectError(data) {
    _isConnected = false;
    final errorMsg = 'Erro de conexão Socket.IO: $data';
    debugPrint('🔴 $errorMsg');
    _connectionStateController.add(false);
    _errorController.add(errorMsg);
    _onErrorCallback?.call(data);
  }

  /// Handler para erros gerais
  static void _handleError(data) {
    final errorMsg = 'Erro Socket.IO: $data';
    debugPrint('⚠️ $errorMsg');
    _errorController.add(errorMsg);
    _onErrorCallback?.call(data);
  }

  /// Handler para reconexão
  static void _handleReconnect(_) {
    _isConnected = true;
    debugPrint('🔄 Socket.IO reconectado');
    _connectionStateController.add(true);
  }

  /// Handler para erro de reconexão
  static void _handleReconnectError(data) {
    final errorMsg = 'Erro de reconexão Socket.IO: $data';
    debugPrint('🔴 $errorMsg');
    _errorController.add(errorMsg);
  }

  /// Constrói a URL do Socket baseada na configuração
  static String _buildSocketUrl(ApiConfig apiConfig) {
    final protocol = apiConfig.useHttps ? 'https' : 'http';
    return '$protocol://${apiConfig.apiUrl}:${apiConfig.apiPort}';
  }

  /// Limpa a instância do Socket (usado em testes ou reset completo)
  static void dispose() {
    if (_socketInstance != null) {
      disconnect();
      _socketInstance!.dispose();
      _socketInstance = null;
      _currentApiConfig = null;
      _isConnected = false;
    }

    // Fechar streams
    _connectionStateController.close();
    _errorController.close();
  }
}
