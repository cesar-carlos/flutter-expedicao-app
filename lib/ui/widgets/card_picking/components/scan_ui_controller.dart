import 'dart:async';

import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/keyboard_toggle_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_dialog_manager.dart';

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

  /// Bug latente anterior: `ScaffoldMessenger.of(context!)` sem
  /// checar `context.mounted`. O `context` eh capturado pelo
  /// construtor (antipattern reconhecido) e pode ficar invalido
  /// se o widget que criou o controller for desmontado entre o
  /// scan e o callback. O `context!.mounted` previne o crash.
  void _showQuantityConversionFeedback(int originalQuantity, int convertedQuantity) {
    final ctx = context;
    if (ctx == null || !ctx.mounted) return;

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Quantidade convertida: $originalQuantity → $convertedQuantity (unidade de medida)'),
        duration: UIConstants.snackBarShortDuration,
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> handleScanResult(String barcode, ScanProcessResult scanResult, int inputQuantity) async {
    // Bug latente anterior: TODAS as chamadas `audioService.play*()`
    // (8 ocorrencias neste arquivo) retornavam Future descartado
    // sem catch. Embora `playSound` ja tenha try/catch interno que
    // loga via `AppLogger.warning`, qualquer exception nao tratada
    // virava "Unhandled Future error". Padronizado com `unawaited`.
    switch (scanResult.status) {
      case ScanProcessStatus.cartNotInSeparation:
        unawaited(audioService.playError());
        return;
      case ScanProcessStatus.ignored:
        return;
      case ScanProcessStatus.noItemsForSector:
        unawaited(audioService.playAlert());
        if (scanResult.userSectorCode != null) {
          dialogManager.showNoItemsForSectorDialog(scanResult.userSectorCode!, onFinishPicking);
        }
        return;
      case ScanProcessStatus.allItemsCompleted:
        unawaited(audioService.playAlert());
        dialogManager.showAllItemsCompletedDialog();
        return;
      case ScanProcessStatus.wrongSector:
        if (scanResult.scannedItem != null) {
          unawaited(audioService.playError());
          final scannedItem = scanResult.scannedItem!;
          final sectorName = scannedItem.nomeSetorEstoque ?? 'Setor ${scannedItem.codSetorEstoque}';
          final sectorCode = scanResult.userSectorCode ?? scannedItem.codSetorEstoque ?? 0;
          dialogManager.showWrongSectorDialog(barcode, scannedItem.nomeProduto, sectorName, sectorCode);
        }
        return;
      case ScanProcessStatus.wrongShelf:
        unawaited(audioService.playError());
        dialogManager.showWrongShelfDialog(
          scanResult.expectedShelf ?? 'Endereço não definido',
          scanResult.scannedShelf ?? 'Código escaneado',
        );
        return;
      case ScanProcessStatus.shelfScanned:
        unawaited(audioService.playSuccess());
        if (scanResult.expectedItem != null) {
          _showShelfScannedFeedback(scanResult.expectedItem!.enderecoDescricao ?? 'Endereço escaneado');
        }
        return;
      case ScanProcessStatus.wrongProduct:
        if (scanResult.expectedItem != null) {
          unawaited(audioService.playError());
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
          unawaited(audioService.playError());
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

  void _showShelfScannedFeedback(String shelfAddress) {
    final ctx = context;
    if (ctx == null || !ctx.mounted) return;

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Prateleira confirmada: $shelfAddress'),
        duration: UIConstants.snackBarShortDuration,
        backgroundColor: AppColors.success,
      ),
    );
  }
}
