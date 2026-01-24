import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_failure.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/keyboard_toggle_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_dialog_manager.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/shelf_scanning_modal_v2.dart';
import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class PickingFlowController {
  final CardPickingViewModel viewModel;
  final PickingDialogManager dialogManager;
  final AudioService audioService;
  final KeyboardToggleController keyboardController;

  PickingFlowController({
    required this.viewModel,
    required this.dialogManager,
    required this.audioService,
    required this.keyboardController,
  });

  void showShelfScanDialog(
    BuildContext context,
    SeparateItemConsultationModel nextItem, {
    VoidCallback? onShelfScanCompleted,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ShelfScanningModalV2(
        expectedAddress: nextItem.endereco!,
        expectedAddressDescription: nextItem.enderecoDescricao ?? 'Endereço não definido',
        viewModel: viewModel,
        onBack: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
        },
      ),
    ).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        keyboardController.enableScannerMode();
      });
      onShelfScanCompleted?.call();
    });
  }

  Future<void> checkAndShowSaveCartModal() async {
    final userSectorCode = viewModel.userModel?.codSetorEstoque;
    if (userSectorCode == null) return;

    final sectorItems = viewModel.items
        .where((item) => item.codSetorEstoque == null || item.codSetorEstoque == userSectorCode)
        .toList();

    if (sectorItems.isEmpty) return;

    final allSectorItemsCompleted = sectorItems.every((item) => viewModel.isItemCompleted(item.item));

    if (allSectorItemsCompleted) {
      await audioService.playAlertComplete();

      dialogManager.showSaveCartAfterSectorCompletedDialog(
        userSectorCode,
        () => finishPicking(),
        keyboardController.forceFocusAndCloseKeyboard,
      );
    }
  }

  Future<void> finishPicking() async {
    final navigator = dialogManager.context;
    if (navigator.mounted) {
      _showLoadingDialog(navigator);
    }

    try {
      final result = await viewModel.saveCart();

      if (navigator.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigator.mounted) {
            Navigator.of(navigator).pop();
          }
        });
      }

      result.fold(
        (_) {
          audioService.playSuccess();
          if (navigator.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (navigator.mounted) {
                Navigator.of(navigator).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (navigator.mounted) {
                    GoRouter.of(navigator).pop('save_cart');
                  }
                });
              }
            });
          }
        },
        (failure) {
          final message = failure is AppFailure ? failure.userMessage : 'Erro ao salvar carrinho: $failure';
          final details = failure is SaveSeparationCartFailure ? failure.details : null;
          if (navigator.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (navigator.mounted) {
                _showErrorDialog(navigator, message, details: details);
              }
            });
          }
        },
      );
    } catch (e) {
      if (navigator.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigator.mounted) {
            Navigator.of(navigator).pop();
            _showErrorDialog(navigator, 'Erro inesperado ao salvar carrinho: $e');
          }
        });
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Salvando carrinho...')],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message, {String? details}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details,
                style: AppFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              });
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
