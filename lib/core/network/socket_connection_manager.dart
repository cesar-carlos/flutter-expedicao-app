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
  Completer<void>? _inFlight;

  SocketConnectionManagerState get state => _state;

  bool get isConnected => _state == SocketConnectionManagerState.connected;

  SocketConnectionManager({RetryPolicy? retryPolicy})
    : _retryPolicy =
          retryPolicy ??
          RetryPolicy.withJitter(
            maxAttempts: 3,
            initialDelay: const Duration(seconds: 1),
            backoffMultiplier: 2.0,
            maxDelay: const Duration(seconds: 10),
          );

  Future<void> connectWithRetry(ApiConfig config) async {
    if (_inFlight != null) {
      return _inFlight!.future;
    }

    final completer = Completer<void>();
    _inFlight = completer;

    try {
      if (!SocketConfig.isInitialized) {
        SocketConfig.initialize(config);
      } else {
        SocketConfig.updateConfig(config);
      }

      _setState(SocketConnectionManagerState.connecting);

      await _retryPolicy.execute(SocketConfig.connect, tag: 'SocketConnectionManager');
      _setState(SocketConnectionManagerState.connected);
      AppLogger.connection('Conexão estabelecida com retry', tag: 'SocketConnectionManager');
      completer.complete();
    } catch (e, s) {
      _setState(SocketConnectionManagerState.failed);
      AppLogger.error('Falha ao conectar após retries', tag: 'SocketConnectionManager', error: e, stackTrace: s);
      completer.completeError(e, s);
      rethrow;
    } finally {
      _inFlight = null;
    }
  }

  Future<void> reconnectWithRetry() async {
    if (_inFlight != null) {
      return _inFlight!.future;
    }

    final completer = Completer<void>();
    _inFlight = completer;

    try {
      _setState(SocketConnectionManagerState.reconnecting);

      await _retryPolicy.execute(SocketConfig.reconnect, tag: 'SocketConnectionManager');
      _setState(SocketConnectionManagerState.connected);
      completer.complete();
    } catch (e, s) {
      _setState(SocketConnectionManagerState.failed);
      AppLogger.error('Falha ao reconectar após retries', tag: 'SocketConnectionManager', error: e, stackTrace: s);
      completer.completeError(e, s);
      rethrow;
    } finally {
      _inFlight = null;
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
