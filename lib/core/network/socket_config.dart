import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:data7_expedicao/domain/models/api_config.dart';

class SocketConfig {
  static io.Socket? _socketInstance;
  static ApiConfig? _currentApiConfig;

  static void initialize(ApiConfig apiConfig) {
    _currentApiConfig = apiConfig;
    _socketInstance = _createSocketInstance(apiConfig);
  }

  static io.Socket get instance {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado. Chame SocketConfig.initialize() primeiro.');
    }
    return _socketInstance!;
  }

  static String get socketUrl {
    if (_currentApiConfig == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    return _currentApiConfig!.fullUrl;
  }

  static bool get isConnected {
    return _socketInstance?.connected ?? false;
  }

  static String? get sessionId {
    return _socketInstance?.id;
  }

  static void updateConfig(ApiConfig newConfig) {
    final configChanged =
        (_currentApiConfig?.apiUrl != newConfig.apiUrl ||
        _currentApiConfig?.apiPort != newConfig.apiPort ||
        _currentApiConfig?.useHttps != newConfig.useHttps);

    if (configChanged) {
      _currentApiConfig = newConfig;
      _socketInstance?.disconnect();
      _socketInstance = _createSocketInstance(newConfig);
    }
  }

  static Future<void> connect() async {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    _socketInstance!.connect();
  }

  static void disconnect() {
    _socketInstance?.disconnect();
  }

  static Future<void> reconnect() async {
    if (_socketInstance == null) {
      throw StateError('SocketConfig não foi inicializado.');
    }
    _socketInstance!.disconnect();
    _socketInstance!.connect();
  }

  static io.Socket _createSocketInstance(ApiConfig apiConfig) {
    final socket = io.io(apiConfig.fullUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'reconnectionAttempts': 5,
    });

    socket.onConnect((_) {});

    socket.onDisconnect((_) {});

    socket.onError((error) {});

    socket.onConnectError((error) {});

    socket.onReconnect((_) {});

    socket.onReconnectError((error) {});

    socket.onReconnectFailed((_) {});

    return socket;
  }

  static bool get isInitialized => _socketInstance != null;

  static void reset() {
    _socketInstance?.disconnect();
    _socketInstance = null;
    _currentApiConfig = null;
  }

  static void dispose() {
    reset();
  }
}
