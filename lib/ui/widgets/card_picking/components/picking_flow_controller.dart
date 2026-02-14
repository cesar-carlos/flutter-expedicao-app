import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_failure.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/keyboard_toggle_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_dialog_manager.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/shelf_scanning_modal_v2.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
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

    final confirmed = await _showFinishConfirmationDialog(navigator);
    if (!confirmed) return;

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
          children: [
          CircularProgressIndicator(),
          SizedBox(width: UIConstants.defaultPadding),
          Text('Salvando carrinho...'),
        ],
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
              SizedBox(height: UIConstants.smallPadding),
              Text(details, style: AppFonts.inter(fontSize: UIConstants.smallFontSize, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showFinishConfirmationDialog(BuildContext context) async {
    final cart = viewModel.cart;
    if (cart == null) return false;

    final completedItems = viewModel.completedItems;
    final totalItems = viewModel.totalItems;
    final progress = viewModel.progress;

    int pendingOps = 0;
    for (final item in viewModel.items) {
      final itemState = viewModel.pickingState.getItemState(item.item);
      if (itemState?.hasPendingSync == true) {
        pendingOps += itemState!.pendingOperations.length;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: UIConstants.mediumIconSize),
            SizedBox(width: UIConstants.smallPadding),
            const Expanded(child: Text('Finalizar Separação', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirma finalização do carrinho ${cart.nomeCarrinho}?'),
            SizedBox(height: UIConstants.defaultPadding),
            _buildInfoRow('Código', '#${cart.codCarrinho}'),
            _buildInfoRow('Itens totais', '$totalItems'),
            _buildInfoRow('Itens separados', '$completedItems'),
            _buildInfoRow('Progresso', '${(progress * 100).toInt()}%'),
            if (pendingOps > 0) ...[
              SizedBox(height: UIConstants.smallFontSize),
              Container(
                padding: const EdgeInsets.all(UIConstants.smallPadding),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: UIConstants.smallIconSize),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Há $pendingOps operação${pendingOps == 1 ? '' : 'es'} sincronizando',
                        style: AppFonts.inter(fontSize: UIConstants.tinyFontSize, color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: pendingOps == 0 ? () => Navigator.of(dialogContext).pop(true) : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: AppColors.white),
            child: const Text('Confirmar Finalização'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: UIConstants.smallFontSize)),
          ),
          Expanded(child: Text(value, style: AppFonts.inter(fontSize: UIConstants.smallFontSize))),
        ],
      ),
    );
  }
}
