import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:exp/core/network/socket_config.dart';
import 'package:exp/domain/models/api_config.dart';

/// Eventos do WebSocket que podem ser emitidos
enum SocketEvent { userLocationUpdate, scannerResult, notification, statusUpdate, chatMessage }

/// Estados de conexão do WebSocket
enum SocketConnectionState { disconnected, connecting, connected, reconnecting, error }

/// Serviço para gerenciar comunicação em tempo real via WebSocket
class SocketService extends ChangeNotifier {
  SocketConnectionState _connectionState = SocketConnectionState.disconnected;
  final Map<String, StreamController> _eventStreams = {};
  Timer? _heartbeatTimer;
  String? _userId;

  /// Estado atual da conexão
  SocketConnectionState get connectionState => _connectionState;

  /// Verifica se está conectado
  bool get isConnected => _connectionState == SocketConnectionState.connected;

  /// ID do usuário atual
  String? get userId => _userId;

  /// Inicializa o serviço de socket
  Future<void> initialize(ApiConfig apiConfig, {String? userId}) async {
    try {
      _userId = userId;
      SocketConfig.initialize(apiConfig);
      _setupSocketListeners();
      await connect();
    } catch (e) {
      // Erro ao inicializar SocketService
      _updateConnectionState(SocketConnectionState.error);
    }
  }

  /// Conecta ao servidor WebSocket
  Future<void> connect() async {
    if (_connectionState == SocketConnectionState.connected) {
      return;
    }

    try {
      _updateConnectionState(SocketConnectionState.connecting);
      await SocketConfig.connect();
    } catch (e) {
      // Erro ao conectar WebSocket
      _updateConnectionState(SocketConnectionState.error);
    }
  }

  /// Desconecta do servidor WebSocket
  void disconnect() {
    try {
      _stopHeartbeat();
      SocketConfig.disconnect();
      _updateConnectionState(SocketConnectionState.disconnected);
    } catch (e) {
      // Erro ao desconectar WebSocket
    }
  }

  /// Reconecta ao servidor WebSocket
  Future<void> reconnect() async {
    try {
      _updateConnectionState(SocketConnectionState.reconnecting);
      await SocketConfig.reconnect();
    } catch (e) {
      // Erro ao reconectar WebSocket
      _updateConnectionState(SocketConnectionState.error);
    }
  }

  /// Emite um evento para o servidor
  void emit(String eventName, dynamic data) {
    if (!isConnected) {
      // Socket não conectado
      return;
    }

    try {
      final payload = {'userId': _userId, 'timestamp': DateTime.now().toIso8601String(), 'data': data};

      SocketConfig.instance.emit(eventName, payload);
      // Evento emitido
    } catch (e) {
      // Erro ao emitir evento
    }
  }

  /// Escuta um evento específico do servidor
  Stream<dynamic> on(String eventName) {
    if (!_eventStreams.containsKey(eventName)) {
      _eventStreams[eventName] = StreamController<dynamic>.broadcast();

      SocketConfig.instance.on(eventName, (data) {
        _eventStreams[eventName]?.add(data);
      });
    }

    return _eventStreams[eventName]!.stream;
  }

  /// Remove listener de um evento
  void off(String eventName) {
    SocketConfig.instance.off(eventName);
    _eventStreams[eventName]?.close();
    _eventStreams.remove(eventName);
  }

  /// Envia dados de localização do usuário
  void sendLocationUpdate(double latitude, double longitude) {
    emit('location_update', {'latitude': latitude, 'longitude': longitude});
  }

  /// Envia resultado de scanner
  void sendScannerResult(String scanData, String scanType) {
    emit('scanner_result', {'scanData': scanData, 'scanType': scanType});
  }

  /// Envia mensagem de chat/notificação
  void sendMessage(String message, String? recipientId) {
    emit('message', {'message': message, 'recipientId': recipientId});
  }

  /// Atualiza configuração do socket
  void updateConfig(ApiConfig newConfig) {
    try {
      SocketConfig.updateConfig(newConfig);
      if (isConnected) {
        reconnect();
      }
    } catch (e) {
      // Erro ao atualizar configuração do socket
    }
  }

  /// Configura os listeners básicos do socket
  void _setupSocketListeners() {
    final socket = SocketConfig.instance;

    socket.onConnect((_) {
      // Socket conectado com sucesso
      _updateConnectionState(SocketConnectionState.connected);
      _startHeartbeat();

      // Auto-join do usuário se ID estiver disponível
      if (_userId != null) {
        emit('user_join', {'userId': _userId});
      }
    });

    socket.onDisconnect((_) {
      // Socket desconectado
      _updateConnectionState(SocketConnectionState.disconnected);
      _stopHeartbeat();
    });

    socket.onConnectError((data) {
      // Erro de conexão do socket
      _updateConnectionState(SocketConnectionState.error);
    });

    socket.onError((data) {
      // Erro do socket
      _updateConnectionState(SocketConnectionState.error);
    });

    socket.onReconnect((_) {
      // Socket reconectado
      _updateConnectionState(SocketConnectionState.connected);
    });
  }

  /// Inicia heartbeat para manter conexão ativa
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isConnected) {
        emit('heartbeat', {'timestamp': DateTime.now().toIso8601String()});
      }
    });
  }

  /// Para o heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Atualiza estado de conexão e notifica listeners
  void _updateConnectionState(SocketConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      notifyListeners();
      // Socket state changed
    }
  }

  /// Limpa recursos quando o serviço é descartado
  @override
  void dispose() {
    _stopHeartbeat();

    // Fecha todos os streams de eventos
    for (final stream in _eventStreams.values) {
      stream.close();
    }
    _eventStreams.clear();

    disconnect();
    SocketConfig.dispose();
    super.dispose();
  }
}
