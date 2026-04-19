import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/services/barcode_broadcast_service.dart';
import 'package:data7_expedicao/core/services/scanner_mode_coordinator.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';

/// Controller de broadcast usado pelo `ScannerActivationController` no
/// fluxo de picking.
///
/// Hoje é um wrapper fino sobre [ScannerModeCoordinator], preservando a
/// API antiga (`start(action, extraKey, onBarcodeReceived)`, `stop()`,
/// `dispose()`) para evitar refator no `PickingCardScan`. A lógica
/// real de subscription, retry, error handling e logging vive no
/// coordinator (testável, puro Dart).
class ScannerBroadcastController {
  static const _logTag = 'ScannerBroadcastController';

  late final ScannerModeCoordinator _coordinator;
  void Function(String)? _onBarcodeReceived;

  ScannerBroadcastController({BarcodeBroadcastService? broadcastService}) {
    _coordinator = ScannerModeCoordinator(
      broadcastService: broadcastService ?? locator<BarcodeBroadcastService>(),
      onBarcode: (code) => _onBarcodeReceived?.call(code),
    );
  }

  /// Indica se o broadcast listener está ativo.
  bool get isActive => _coordinator.isBroadcastActive;

  /// Inicia o broadcast listener.
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
        tag: _logTag,
      );
      return;
    }

    AppLogger.debug('Starting broadcast listener: action=$action extraKey=$extraKey', tag: _logTag);

    _onBarcodeReceived = onBarcodeReceived;
    // Garante que start() apos um stop() (que setou manual override) volte
    // a ouvir antes de aplicar as novas preferencias.
    await _coordinator.setManualOverride(false);
    await _coordinator.start(
      ScannerModePreferences(mode: ScannerInputMode.broadcast, action: action, extraKey: extraKey),
    );
    AppLogger.debug('Broadcast listener created successfully', tag: _logTag);
  }

  /// Para o broadcast listener.
  ///
  /// Não destrói o coordinator: um `start()` posterior religa a subscription
  /// (limpando o manual override).
  Future<void> stop() async {
    if (!_coordinator.isBroadcastActive) {
      return;
    }

    AppLogger.debug('Stopping broadcast listener', tag: _logTag);
    await _coordinator.setManualOverride(true);
  }

  /// Descarta o controller e cancela a subscription.
  /// (S3: o `dispose()` do coordinator é assíncrono mas este é sync;
  /// usamos `discarded_futures` porque erros já são logados internamente.)
  void dispose() {
    // ignore: discarded_futures
    _coordinator.dispose();
    _onBarcodeReceived = null;
  }
}
