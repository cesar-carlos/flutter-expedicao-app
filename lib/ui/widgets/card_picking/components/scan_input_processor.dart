import 'dart:async';

import 'package:flutter/services.dart';

import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/barcode_scanner_service.dart';
import 'package:data7_expedicao/core/services/barcode_validation_service.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';

class ScanInputProcessor {
  final CardPickingViewModel viewModel;
  final AudioService? _audioServiceOverride;
  final BarcodeScannerService? _scannerServiceOverride;

  ScanInputProcessor({required this.viewModel, AudioService? audioService, BarcodeScannerService? scannerService})
    : _audioServiceOverride = audioService,
      _scannerServiceOverride = scannerService;

  AudioService get _audioService => _audioServiceOverride ?? locator<AudioService>();
  BarcodeScannerService get _scannerService => _scannerServiceOverride ?? locator<BarcodeScannerService>();

  void dispose() {
    BarcodeValidationService.clearCaches();
  }

  void processScannerInput(String input, void Function(String) onCompleteBarcode, void Function() onWaitForMore) {
    _scannerService.processBarcodeInputWithControlDetection(input, onCompleteBarcode, onWaitForMore);
  }

  BarcodeValidationResult validateScannedBarcode(String barcode) {
    return BarcodeValidationService.validateScannedBarcode(
      barcode,
      viewModel.items,
      viewModel.isItemCompleted,
      userSectorCode: viewModel.userModel?.codSetorEstoque,
    );
  }

  void clearValidationCaches() {
    _scannerService.clearValidationCache();
    BarcodeValidationService.clearCaches();
  }

  Future<void> handleSuccessfulItemAddition(
    SeparateItemConsultationModel item,
    int quantity,
    void Function() onResetQuantity,
    void Function() onInvalidateCache,
    Future<void> Function() onCheckSectorCompletion,
  ) async {
    final itemId = item.item;
    final currentQuantity = _getCurrentQuantity(itemId);
    final totalQuantity = _getTotalQuantity(item);
    final isCompletedAfterUpdate = currentQuantity >= totalQuantity;

    onResetQuantity();
    onInvalidateCache();

    if (isCompletedAfterUpdate) {
      await _audioService.playItemCompleted();
    } else {
      await _provideSuccessFeedback();
    }

    // Bug latente anterior: `catchError((_) {})` silenciava
    // COMPLETAMENTE qualquer erro de checagem de conclusao do
    // setor — sem log. Erros como race conditions, falha de
    // calculo de progresso ou bug no proprio handler ficavam
    // invisiveis em producao. Agora logamos via AppLogger.warning.
    unawaited(
      onCheckSectorCompletion().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao verificar conclusao do setor apos adicao de item',
          tag: 'ScanInputProcessor',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  Future<void> _provideSuccessFeedback() async {
    // Bug latente anterior: `_audioService.playBarcodeScan()`
    // retorna Future descartado. Embora playSound tenha try/catch
    // interno, qualquer erro nao tratado virava "Unhandled Future
    // error". Mesmo padrao em handleFailedItemAddition abaixo.
    unawaited(_audioService.playBarcodeScan());
    _provideTactileFeedback();
  }

  void handleFailedItemAddition(SeparateItemConsultationModel item, String errorMessage) {
    unawaited(_audioService.playError());
  }

  void _provideTactileFeedback() {
    try {
      HapticFeedback.lightImpact();
    } catch (e, stackTrace) {
      AppLogger.debug('Erro ao fornecer feedback tátil', tag: 'ScanInputProcessor', error: e, stackTrace: stackTrace);
    }
  }

  int _getCurrentQuantity(String itemId) => viewModel.getPickedQuantity(itemId);

  int _getTotalQuantity(SeparateItemConsultationModel item) => item.quantidade.toInt();
}
