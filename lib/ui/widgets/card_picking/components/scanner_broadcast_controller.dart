import 'dart:async' show StreamSubscription;

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/services/barcode_broadcast_service.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

/// Controller responsável por gerenciar o broadcast listener do scanner
///
/// Responsabilidades:
/// - Gerenciar ciclo de vida do broadcast listener
/// - Iniciar/parar broadcast listener
/// - Processar códigos recebidos via broadcast
/// - Tratar erros do broadcast stream
class ScannerBroadcastController {
  final BarcodeBroadcastService _broadcastService = locator<BarcodeBroadcastService>();

  StreamSubscription<String>? _subscription;
  bool _isActive = false;

  /// Indica se o broadcast listener está ativo
  bool get isActive => _isActive;

  /// Retorna a subscription atual (para verificação)
  StreamSubscription<String>? get subscription => _subscription;

  /// Inicia o broadcast listener
  ///
  /// [action] - Action para o broadcast
  /// [extraKey] - Extra key para o broadcast
  /// [onBarcodeReceived] - Callback chamado quando um código é recebido
  Future<void> start({
    required String action,
    required String extraKey,
    required void Function(String) onBarcodeReceived,
  }) async {
    if (action.isEmpty || extraKey.isEmpty) {
      AppLogger.debug(
        'Broadcast listener start skipped - invalid configuration: action=$action extraKey=$extraKey',
        tag: 'ScannerBroadcastController',
      );
      return;
    }

    AppLogger.debug(
      'Starting broadcast listener: action=$action extraKey=$extraKey',
      tag: 'ScannerBroadcastController',
    );

    await stop();

    try {
      _subscription = _broadcastService
          .listen(action: action, extraKey: extraKey)
          .listen(
            (code) {
              final trimmed = code.trim();
              AppLogger.debug('Broadcast received code: $trimmed', tag: 'ScannerBroadcastController');
              if (trimmed.isEmpty) return;
              onBarcodeReceived(trimmed);
            },
            onError: (error, stackTrace) {
              AppLogger.error(
                'Broadcast listener error',
                tag: 'ScannerBroadcastController',
                error: error,
                stackTrace: stackTrace,
              );
            },
            onDone: () {
              AppLogger.debug('Broadcast listener stream done', tag: 'ScannerBroadcastController');
              _isActive = false;
            },
          );
      _isActive = true;
      AppLogger.debug('Broadcast listener created successfully', tag: 'ScannerBroadcastController');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error creating broadcast listener',
        tag: 'ScannerBroadcastController',
        error: e,
        stackTrace: stackTrace,
      );
      _isActive = false;
    }
  }

  /// Para o broadcast listener
  Future<void> stop() async {
    if (!_isActive && _subscription == null) {
      return;
    }

    AppLogger.debug('Stopping broadcast listener', tag: 'ScannerBroadcastController');
    try {
      await _subscription?.cancel();
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Error canceling broadcast subscription',
        tag: 'ScannerBroadcastController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _subscription = null;
      _isActive = false;
    }
  }

  /// Descarta o controller e cancela a subscription
  void dispose() {
    stop();
  }
}
