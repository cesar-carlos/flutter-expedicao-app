import 'dart:async';

import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

/// Espera o socket.io ficar pronto de verdade (conectado + session id)
/// em vez de falhar no flag frio `connected == false`.
class SocketReadyGate {
  static const Duration defaultTimeout = Duration(seconds: 8);

  final bool Function() _isConnected;
  final String? Function() _sessionId;
  final Future<void> Function({required Duration timeout}) _connect;

  const SocketReadyGate({
    required bool Function() isConnected,
    required String? Function() sessionId,
    required Future<void> Function({required Duration timeout}) connect,
  }) : _isConnected = isConnected,
       _sessionId = sessionId,
       _connect = connect;

  factory SocketReadyGate.forConfig() {
    return SocketReadyGate(
      isConnected: () => SocketConfig.isConnected,
      sessionId: () => SocketConfig.sessionId,
      connect: ({required Duration timeout}) => SocketConfig.connect(timeout: timeout),
    );
  }

  bool get isReady {
    final id = _sessionId();
    return _isConnected() && id != null && id.isNotEmpty;
  }

  Future<void> ensureReady({Duration timeout = defaultTimeout}) async {
    if (isReady) {
      return;
    }

    AppLogger.connection('Socket ainda não pronto; aguardando até ${timeout.inSeconds}s', tag: 'SocketReadyGate');
    await _connect(timeout: timeout);
    if (isReady) {
      return;
    }

    throw TimeoutException('Conexão em tempo real indisponível após ${timeout.inSeconds}s');
  }
}
