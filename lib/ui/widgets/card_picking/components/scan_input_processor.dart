import 'package:flutter/services.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/barcode_scanner_service.dart';
import 'package:data7_expedicao/core/services/barcode_validation_service.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';

class ScanInputProcessor {
  final CardPickingViewModel viewModel;
  final AudioService _audioService = locator<AudioService>();
  final BarcodeScannerService _scannerService = locator<BarcodeScannerService>();

  ScanInputProcessor({required this.viewModel});

  void dispose() {
    _scannerService.dispose();

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
    BarcodeValidationService.clearValidationCache();
  }

  Future<void> handleSuccessfulItemAddition(
    SeparateItemConsultationModel item,
    int quantity,
    void Function() onResetQuantity,
    void Function() onInvalidateCache,
    Future<void> Function() onCheckSectorCompletion,
  ) async {
    final itemId = item.item;
    final wasCompletedBefore = viewModel.isItemCompleted(itemId);

    onResetQuantity();
    onInvalidateCache();

    if (wasCompletedBefore) {
      final currentQuantity = _getCurrentQuantity(itemId);
      final totalQuantity = _getTotalQuantity(item);

      if (currentQuantity == totalQuantity) {
        await _audioService.playItemCompleted();
        return;
      }
    }

    if (_didItemBecomeCompleted(itemId, wasCompletedBefore)) {
      await _audioService.playItemCompleted();
    } else {
      await _provideSuccessFeedback();
    }

    onCheckSectorCompletion().catchError((_) {});
  }

  Future<void> _provideSuccessFeedback() async {
    _audioService.playBarcodeScan();
    _provideTactileFeedback();
  }

  void handleFailedItemAddition(SeparateItemConsultationModel item, String errorMessage) {
    _audioService.playError();
  }

  void _provideTactileFeedback() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  bool _didItemBecomeCompleted(String itemId, bool wasCompletedBefore) {
    return !wasCompletedBefore && viewModel.isItemCompleted(itemId);
  }

  int _getCurrentQuantity(String itemId) => viewModel.getPickedQuantity(itemId);

  int _getTotalQuantity(SeparateItemConsultationModel item) => item.quantidade.toInt();
}
