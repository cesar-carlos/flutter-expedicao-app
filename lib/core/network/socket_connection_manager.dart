import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/network/retry_policy.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';

enum SocketConnectionManagerState { disconnected, connecting, connected, reconnecting, failed }

class SocketConnectionManager extends ChangeNotifier {
  final RetryPolicy _retryPolicy;

  SocketConnectionManagerState _state = SocketConnectionManagerState.disconnected;
  static const Duration _connectionTimeout = Duration(seconds: 15);
  static const Duration _connectionPollInterval = Duration(milliseconds: 200);

  SocketConnectionManagerState get state => _state;

  bool get isConnected => _state == SocketConnectionManagerState.connected;

  SocketConnectionManager({RetryPolicy? retryPolicy})
    : _retryPolicy =
          retryPolicy ??
          const RetryPolicy(
            maxAttempts: 3,
            initialDelay: Duration(seconds: 1),
            backoffMultiplier: 2.0,
            maxDelay: Duration(seconds: 10),
          );

  Future<void> connectWithRetry(ApiConfig config) async {
    if (!SocketConfig.isInitialized) {
      SocketConfig.initialize(config);
    } else {
      SocketConfig.updateConfig(config);
    }

    _setState(SocketConnectionManagerState.connecting);

    try {
      await _retryPolicy.execute(() => _connectAndWait(), tag: 'SocketConnectionManager');
      _setState(SocketConnectionManagerState.connected);
      AppLogger.connection('Conexão estabelecida com retry', tag: 'SocketConnectionManager');
    } catch (e) {
      _setState(SocketConnectionManagerState.failed);
      AppLogger.error('Falha ao conectar após retries', tag: 'SocketConnectionManager', error: e);
      rethrow;
    }
  }

  Future<void> _connectAndWait() async {
    await SocketConfig.connect();

    final deadline = DateTime.now().add(_connectionTimeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(_connectionPollInterval);
      if (SocketConfig.isConnected) return;
    }

    throw TimeoutException('Conexão não estabelecida em ${_connectionTimeout.inSeconds}s');
  }

  Future<void> reconnectWithRetry() async {
    _setState(SocketConnectionManagerState.reconnecting);

    try {
      await _retryPolicy.execute(() async {
        await SocketConfig.reconnect();
        return _connectAndWait();
      }, tag: 'SocketConnectionManager');
      _setState(SocketConnectionManagerState.connected);
    } catch (e) {
      _setState(SocketConnectionManagerState.failed);
      rethrow;
    }
  }

  void disconnect() {
    SocketConfig.disconnect();
    _setState(SocketConnectionManagerState.disconnected);
  }

  void _setState(SocketConnectionManagerState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
}
