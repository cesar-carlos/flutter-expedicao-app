import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:exp/domain/models/api_config.dart';

/// Configuração global do cliente Socket.IO
class SocketConfig {
  static IO.Socket? _socketInstance;
  static ApiConfig? _currentApiConfig;
  static bool _isConnected = false;

  /// Inicializa o Socket.IO com configurações globais
  static void initialize(ApiConfig apiConfig) {
    _currentApiConfig = apiConfig;
    _createSocketInstance(apiConfig);
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

    final protocol = _currentApiConfig!.useHttps ? 'wss' : 'ws';
    return '$protocol://${_currentApiConfig!.apiUrl}:${_currentApiConfig!.apiPort}';
  }

  /// Conecta ao servidor Socket.IO
  static Future<void> connect() async {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }

    if (!_isConnected) {
      _socketInstance!.connect();
    }
  }

  /// Desconecta do servidor Socket.IO
  static void disconnect() {
    if (_socketInstance != null && _isConnected) {
      _socketInstance!.disconnect();
    }
  }

  /// Reconecta ao servidor Socket.IO
  static Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }

  /// Atualiza a configuração e reconecta se necessário
  static void updateConfig(ApiConfig newConfig) {
    final shouldReconnect =
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
  static void _createSocketInstance(ApiConfig apiConfig) {
    final socketUrl = _buildSocketUrl(apiConfig);

    _socketInstance = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
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

    _socketInstance!.onConnect((_) {
      _isConnected = true;
      print('Socket.IO conectado: $socketUrl');
    });

    _socketInstance!.onDisconnect((_) {
      _isConnected = false;
      print('Socket.IO desconectado');
    });

    _socketInstance!.onConnectError((data) {
      _isConnected = false;
      print('Erro de conexão Socket.IO: $data');
    });

    _socketInstance!.onError((data) {
      print('Erro Socket.IO: $data');
    });

    _socketInstance!.onReconnect((_) {
      _isConnected = true;
      print('Socket.IO reconectado');
    });

    _socketInstance!.onReconnectError((data) {
      print('Erro de reconexão Socket.IO: $data');
    });
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
  }
}
