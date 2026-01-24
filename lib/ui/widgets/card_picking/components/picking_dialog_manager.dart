import 'package:flutter/material.dart';

import 'package:data7_expedicao/ui/widgets/common/picking_dialog.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/shelf_scanning_modal.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pop();
              onFinish();
            }
          });
        },
        onCancel: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pop();
              scanFocusNode.requestFocus();
            }
          });
        },
      ),
    );
  }

  void showAllItemsCompletedDialog() {
    _showDialogWithFocusReturn(() => PickingDialogs.separationComplete());
  }

  void showQuantityExceededDialog(
    String barcode,
    String productName,
    int requestedQuantity,
    int availableQuantity,
  ) {
    _showDialogWithFocusReturn(
      () => PickingDialogs.quantityExceeded(
        barcode: barcode,
        productName: productName,
        requestedQuantity: requestedQuantity,
        availableQuantity: availableQuantity,
      ),
    );
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
            Icon(Icons.check_circle_outline, color: AppColors.success, size: UIConstants.largeIconSize),
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
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✓ Todos os itens do seu setor foram separados!',
                    style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.green700),
                  ),
                  const SizedBox(height: UIConstants.smallPadding),
                  Text('Seu setor: Setor $userSectorCode', style: AppFonts.inter(color: AppColors.green600)),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            Text(
              'Deseja salvar o carrinho agora ou continuar separando itens de outros setores?',
              style: AppFonts.inter(fontSize: UIConstants.defaultFontSize),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  onContinue();
                }
              });
            },
            child: Text('Continuar Separando'),
          ),
          ElevatedButton(
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  onSaveCart();
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text(
              'Salvar Carrinho',
              style: AppFonts.inter(color: Theme.of(context).colorScheme.onPrimary),
            ),
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
        FocusScope.of(context).unfocus();
        Future.delayed(UIConstants.shortDelay, () {
          if (context.mounted) {
            scanFocusNode.requestFocus();
          }
        });
      }
    });
  }
}
