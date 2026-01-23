import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/keyboard_toggle_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_dialog_manager.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';

class ScanUiController {
  final PickingDialogManager dialogManager;
  final AudioService audioService;
  final KeyboardToggleController keyboardController;
  final TextEditingController quantityController;
  final Future<void> Function() onFinishPicking;
  final Future<void> Function(SeparateItemConsultationModel item, String barcode, int quantity) onAddItem;
  final BuildContext? context;

  const ScanUiController({
    required this.dialogManager,
    required this.audioService,
    required this.keyboardController,
    required this.quantityController,
    required this.onFinishPicking,
    required this.onAddItem,
    this.context,
  });

  void _showQuantityConversionFeedback(int originalQuantity, int convertedQuantity) {
    if (context == null) return;

    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text('Quantidade convertida: $originalQuantity → $convertedQuantity (unidade de medida)'),
        duration: UIConstants.snackBarShortDuration,
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> handleScanResult(String barcode, ScanProcessResult scanResult, int inputQuantity) async {
    switch (scanResult.status) {
      case ScanProcessStatus.cartNotInSeparation:
        audioService.playError();
        return;
      case ScanProcessStatus.ignored:
        return;
      case ScanProcessStatus.noItemsForSector:
        audioService.playAlert();
        if (scanResult.userSectorCode != null) {
          dialogManager.showNoItemsForSectorDialog(scanResult.userSectorCode!, onFinishPicking);
        }
        return;
      case ScanProcessStatus.allItemsCompleted:
        audioService.playAlert();
        dialogManager.showAllItemsCompletedDialog();
        return;
      case ScanProcessStatus.wrongSector:
        if (scanResult.scannedItem != null) {
          audioService.playError();
          final scannedItem = scanResult.scannedItem!;
          final sectorName = scannedItem.nomeSetorEstoque ?? 'Setor ${scannedItem.codSetorEstoque}';
          final sectorCode = scanResult.userSectorCode ?? scannedItem.codSetorEstoque ?? 0;
          dialogManager.showWrongSectorDialog(barcode, scannedItem.nomeProduto, sectorName, sectorCode);
        }
        return;
      case ScanProcessStatus.wrongProduct:
        if (scanResult.expectedItem != null) {
          audioService.playError();
          final expectedItem = scanResult.expectedItem!;
          dialogManager.showWrongProductDialog(
            barcode,
            expectedItem.enderecoDescricao ?? 'Endereço não definido',
            expectedItem.nomeProduto,
            expectedItem.codigoBarras ?? 'Código não definido',
          );
        }
        return;
      case ScanProcessStatus.quantityExceeded:
        if (scanResult.expectedItem != null &&
            scanResult.requestedQuantity != null &&
            scanResult.availableQuantity != null) {
          audioService.playError();
          final item = scanResult.expectedItem!;
          dialogManager.showQuantityExceededDialog(
            barcode,
            item.nomeProduto,
            scanResult.requestedQuantity!,
            scanResult.availableQuantity!,
          );
        }
        return;
      case ScanProcessStatus.success:
        if (scanResult.expectedItem != null) {
          final convertedQuantity = scanResult.convertedQuantity ?? inputQuantity;

          if (convertedQuantity != inputQuantity) {
            quantityController.text = convertedQuantity.toString();
            _showQuantityConversionFeedback(inputQuantity, convertedQuantity);
          }

          await onAddItem(scanResult.expectedItem!, barcode, convertedQuantity);
          keyboardController.forceFocusAndCloseKeyboard();
        }
        return;
    }
  }
}
