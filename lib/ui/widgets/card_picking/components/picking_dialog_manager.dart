import 'dart:async';

import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/shelf_scanning_modal.dart';
import 'package:data7_expedicao/ui/widgets/common/picking_dialog.dart';

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

    // Bug latente anterior: `showDialog(...)` retorna Future
    // descartado sem catch (lint discarded_futures). Embora o
    // dialog em si raramente falhe, o catch defensivo garante
    // observabilidade e satisfaz o lint.
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PickingDialogs.noItemsForSector(
          userSectorCode: userSectorCode,
          // Bug menor anterior: callback marcado como `() async`
          // mas nao retornava Future nem usava await — apenas
          // confundia callers que pudessem esperar Future. Removido
          // o `async` (consistente com `onCancel` abaixo).
          onFinish: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                onFinish();
              }
            });
          },
          onCancel: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                scanFocusNode.requestFocus();
              }
            });
          },
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog noItemsForSector',
          tag: 'PickingDialogManager',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void showAllItemsCompletedDialog() {
    _showDialogWithFocusReturn(() => PickingDialogs.separationComplete());
  }

  void showQuantityExceededDialog(String barcode, String productName, int requestedQuantity, int availableQuantity) {
    _showDialogWithFocusReturn(
      () => PickingDialogs.quantityExceeded(
        barcode: barcode,
        productName: productName,
        requestedQuantity: requestedQuantity,
        availableQuantity: availableQuantity,
      ),
    );
  }

  void showWrongShelfDialog(String expectedShelf, String scannedShelf) {
    _showDialogWithFocusReturn(
      () => PickingDialogs.wrongShelf(expectedShelf: expectedShelf, scannedShelf: scannedShelf),
    );
  }

  void showShelfScanDialog({
    required String expectedAddress,
    required String expectedAddressDescription,
    required Function(String) onShelfScanned,
    Function()? onBack,
  }) {
    if (!context.mounted) return;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => ShelfScanningModal(
          expectedAddress: expectedAddress,
          expectedAddressDescription: expectedAddressDescription,
          onShelfScanned: onShelfScanned,
          onBack: onBack,
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog shelfScan',
          tag: 'PickingDialogManager',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void showSaveCartAfterSectorCompletedDialog(int userSectorCode, VoidCallback onSaveCart, VoidCallback onContinue) {
    if (!context.mounted) return;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.success, size: UIConstants.largeIconSize),
              const SizedBox(width: 8),
              const Text('Setor Concluído!'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
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
                    mainAxisSize: MainAxisSize.min,
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
          ),
          actions: [
            TextButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  unawaited(
                    Future<void>.delayed(Duration.zero, () {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                        onContinue();
                      }
                    }).catchError((Object e, StackTrace s) {
                      AppLogger.warning(
                        'Falha ao fechar dialog (continuar separando)',
                        tag: 'PickingDialogManager',
                        error: e,
                        stackTrace: s,
                      );
                    }),
                  );
                });
              },
              child: Text('Continuar Separando'),
            ),
            ElevatedButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  unawaited(
                    Future<void>.delayed(Duration.zero, () {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                        onSaveCart();
                      }
                    }).catchError((Object e, StackTrace s) {
                      AppLogger.warning(
                        'Falha ao fechar dialog (salvar carrinho)',
                        tag: 'PickingDialogManager',
                        error: e,
                        stackTrace: s,
                      );
                    }),
                  );
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              child: Text(
                'Salvar Carrinho',
                style: AppFonts.inter(color: Theme.of(dialogContext).colorScheme.onPrimary),
              ),
            ),
          ],
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog saveCartAfterSectorCompleted',
          tag: 'PickingDialogManager',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _showDialogWithFocusReturn(Widget Function() dialogBuilder) {
    if (!context.mounted) return;

    // Bug latente anterior: `showDialog(...).then(...)` retornava
    // Future descartado (lint discarded_futures + erros nao
    // observaveis). Agora envolvemos em `unawaited` + catchError
    // defensivo. O `_returnFocusToScanner` continua sendo chamado
    // no `.then` para preservar a semantica original (focus volta
    // ao scanner apos o dialog fechar).
    unawaited(
      showDialog<void>(context: context, builder: (dialogContext) => dialogBuilder())
          .then((_) => _returnFocusToScanner())
          .catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog (showDialogWithFocusReturn)',
          tag: 'PickingDialogManager',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _returnFocusToScanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        FocusScope.of(context).unfocus();
        unawaited(
          Future<void>.delayed(UIConstants.shortDelay, () {
            if (context.mounted) {
              scanFocusNode.requestFocus();
            }
          }).catchError((Object e, StackTrace s) {
            AppLogger.warning(
              'Falha ao reativar foco do scanner após dialog',
              tag: 'PickingDialogManager',
              error: e,
              stackTrace: s,
            );
          }),
        );
      }
    });
  }
}
