import 'package:flutter/material.dart';

import 'package:data7_expedicao/ui/widgets/common/picking_dialog.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/shelf_scanning_modal.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';

class PickingDialogManager {
  final BuildContext context;
  final FocusNode scanFocusNode;

  PickingDialogManager({required this.context, required this.scanFocusNode});

  void showErrorDialog(String barcode, String productName, String errorMessage) {
    _showDialogWithFocusReturn(
      () => PickingDialogs.addItemError(barcode: barcode, productName: productName, errorMessage: errorMessage),
    );
  }

  void showWrongProductDialog(String barcode, String expectedAddress, String expectedProduct, String expectedBarcode) {
    _showDialogWithFocusReturn(
      () => PickingDialogs.wrongProduct(
        scannedBarcode: barcode,
        expectedAddress: expectedAddress,
        expectedProduct: expectedProduct,
        expectedBarcode: expectedBarcode,
      ),
    );
  }

  void showWrongSectorDialog(String barcode, String productName, String productSector, int userSectorCode) {
    _showDialogWithFocusReturn(
      () => PickingDialogs.wrongSector(
        scannedBarcode: barcode,
        productName: productName,
        productSector: productSector,
        userSectorCode: userSectorCode,
      ),
    );
  }

  void showNoItemsForSectorDialog(int userSectorCode, VoidCallback onFinish) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PickingDialogs.noItemsForSector(
        userSectorCode: userSectorCode,
        onFinish: () async {
          Navigator.of(context).pop();
          onFinish();
        },
        onCancel: () {
          Navigator.of(context).pop();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            scanFocusNode.requestFocus();
          });
        },
      ),
    );
  }

  void showAllItemsCompletedDialog() {
    _showDialogWithFocusReturn(() => PickingDialogs.separationComplete());
  }

  void showShelfScanDialog({
    required String expectedAddress,
    required String expectedAddressDescription,
    required Function(String) onShelfScanned,
    Function()? onBack,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ShelfScanningModal(
        expectedAddress: expectedAddress,
        expectedAddressDescription: expectedAddressDescription,
        onShelfScanned: onShelfScanned,
        onBack: onBack,
      ),
    );
  }

  void showSaveCartAfterSectorCompletedDialog(int userSectorCode, VoidCallback onSaveCart, VoidCallback onContinue) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: UIConstants.largeIconSize),
            const SizedBox(width: 8),
            const Text('Setor Concluído!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.smallPadding),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✓ Todos os itens do seu setor foram separados!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                  ),
                  const SizedBox(height: UIConstants.smallPadding),
                  Text('Seu setor: Setor $userSectorCode', style: TextStyle(color: Colors.green.shade600)),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            Text(
              'Deseja salvar o carrinho agora ou continuar separando itens de outros setores?',
              style: TextStyle(fontSize: UIConstants.defaultFontSize),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onContinue();
            },
            child: Text('Continuar Separando'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSaveCart();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Salvar Carrinho', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDialogWithFocusReturn(Widget Function() dialogBuilder) {
    if (!context.mounted) return;

    showDialog(context: context, builder: (context) => dialogBuilder()).then((_) {
      _returnFocusToScanner();
    });
  }

  void _returnFocusToScanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        scanFocusNode.requestFocus();
      }
    });
  }
}
