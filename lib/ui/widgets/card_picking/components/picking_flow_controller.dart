import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
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
import 'dart:async';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';

class PickingFlowController {
  final CardPickingViewModel viewModel;
  final PickingDialogManager dialogManager;
  final AudioService audioService;
  final KeyboardToggleController keyboardController;

  bool _isFinishing = false;
  BuildContext? _loadingDialogContext;

  PickingFlowController({
    required this.viewModel,
    required this.dialogManager,
    required this.audioService,
    required this.keyboardController,
  });

  Future<void> showShelfScanDialog(
    BuildContext context,
    SeparateItemConsultationModel nextItem, {
    VoidCallback? onShelfScanCompleted,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ShelfScanningModalV2(
        expectedAddress: nextItem.endereco!,
        expectedAddressDescription: nextItem.enderecoDescricao ?? 'Endereço não definido',
        viewModel: viewModel,
        onBack: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(Duration.zero, () {
              if (context.mounted) Navigator.of(context).pop();
            });
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
    if (_isFinishing) return;

    final navigator = dialogManager.context;
    if (!navigator.mounted) return;

    AppLogger.info('Iniciando finalização do picking', tag: 'PickingFlowController');

    final socketValidation = SocketValidationHelper.validateSocketState();
    if (!socketValidation.isValid) {
      AppLogger.warning(
        'Socket inválido ao salvar carrinho: ${socketValidation.errorMessage}',
        tag: 'PickingFlowController',
      );
      if (navigator.mounted) {
        _showErrorDialog(navigator, 'Conexão não está pronta. Verifique o indicador de conexão e tente novamente.');
      }
      return;
    }

    AppLogger.progress('Socket validado com sucesso', tag: 'PickingFlowController');

    final confirmed = await _showFinishConfirmationDialog(navigator);
    if (!confirmed) return;
    if (!navigator.mounted) return;

    _isFinishing = true;
    _showLoadingDialog(navigator);

    AppLogger.progress(
      'Iniciando salvamento com timeout de ${UIConstants.networkTimeout.inSeconds}s',
      tag: 'PickingFlowController',
    );

    try {
      final result = await viewModel.saveCart().timeout(
        UIConstants.networkTimeout,
        onTimeout: () {
          AppLogger.error(
            'Timeout ao salvar carrinho (${UIConstants.networkTimeout.inSeconds}s)',
            tag: 'PickingFlowController',
          );
          throw TimeoutException('Operação excedeu o tempo limite de ${UIConstants.networkTimeout.inSeconds} segundos');
        },
      );

      result.fold(
        (_) {
          audioService.playSuccess();
          AppLogger.success('Carrinho salvo com sucesso', tag: 'PickingFlowController');
          if (navigator.mounted) {
            void doPops() {
              if (!navigator.mounted) {
                return;
              }
              _ensureLoadingDialogClosed();
              if (navigator.mounted) Navigator.of(navigator).pop('save_cart');
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(Duration.zero, doPops);
            });
          }
          AppLogger.info('Retornando para tela anterior', tag: 'PickingFlowController');
        },
        (failure) {
          final message = failure is AppFailure ? failure.userMessage : 'Erro ao salvar carrinho. Tente novamente.';
          final details = failure is SaveSeparationCartFailure ? failure.details : null;
          if (navigator.mounted) {
            void doPopsAndDialog() {
              if (!navigator.mounted) {
                return;
              }
              _ensureLoadingDialogClosed();
              if (navigator.mounted) _showErrorDialog(navigator, message, details: details);
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(Duration.zero, doPopsAndDialog);
            });
          }
        },
      );
    } on TimeoutException catch (e) {
      AppLogger.error('TimeoutException ao salvar carrinho', tag: 'PickingFlowController', error: e);
      if (navigator.mounted) _handleTimeoutError(navigator, e);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro inesperado ao salvar carrinho',
        tag: 'PickingFlowController',
        error: e,
        stackTrace: stackTrace,
      );
      if (navigator.mounted) {
        void doPopsAndDialog() {
          if (!navigator.mounted) {
            return;
          }
          _ensureLoadingDialogClosed();
          if (navigator.mounted) _showErrorDialog(navigator, 'Erro inesperado ao salvar carrinho. Tente novamente.');
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(Duration.zero, doPopsAndDialog);
        });
      }
    } finally {
      _isFinishing = false;
    }
  }

  void _showLoadingDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _loadingDialogContext = dialogContext;
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: UIConstants.defaultPadding),
              Text('Salvando carrinho...'),
            ],
          ),
        );
      },
    );
  }

  void _ensureLoadingDialogClosed() {
    if (_loadingDialogContext == null) return;

    if (!_loadingDialogContext!.mounted) {
      _loadingDialogContext = null;
      return;
    }

    try {
      Navigator.of(_loadingDialogContext!).pop();
    } catch (e) {
      AppLogger.warning('Erro ao fechar loading: $e', tag: 'PickingFlowController');
    } finally {
      _loadingDialogContext = null;
    }
  }

  void _handleTimeoutError(BuildContext navigator, TimeoutException e) {
    audioService.playError();

    if (!navigator.mounted) {
      AppLogger.warning('Navigator desmontado ao tratar timeout', tag: 'PickingFlowController');
      return;
    }

    void showErrorAndCleanup() {
      if (!navigator.mounted) {
        return;
      }

      _ensureLoadingDialogClosed();

      _showErrorDialog(
        navigator,
        'A operação demorou muito tempo. Verifique sua conexão e tente novamente.',
        details: 'Timeout após ${UIConstants.networkTimeout.inSeconds} segundos',
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration.zero, showErrorAndCleanup);
    });
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
              Text(
                details,
                style: AppFonts.inter(
                  fontSize: UIConstants.smallFontSize,
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
                Future.delayed(Duration.zero, () {
                  if (context.mounted) Navigator.of(context).pop();
                });
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
            child: Text(
              '$label:',
              style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: UIConstants.smallFontSize),
            ),
          ),
          Expanded(
            child: Text(value, style: AppFonts.inter(fontSize: UIConstants.smallFontSize)),
          ),
        ],
      ),
    );
  }
}
