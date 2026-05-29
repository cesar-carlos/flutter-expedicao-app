import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/services/picking_state_manager.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/theme/status_colors.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_success.dart';
import 'package:data7_expedicao/presentation/coordinators/cart_separation_coordinator.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_items_viewmodel.dart';
import 'package:data7_expedicao/domain/services/cart_validation_service.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_access_denied_dialog.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_cancel_confirmation_dialog.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_cancel_flow_coordinator.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_finalize_confirmation_dialog_content.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_finalize_result_dialogs.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_item_actions_bar.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_item_card_code_situation.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_item_card_header.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_item_group_info.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_item_sector_info.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_no_items_for_sector_dialog.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card/cart_item_timeline_section.dart';

class CartItemCard extends StatefulWidget {
  final ExpeditionCartRouteInternshipConsultationModel cartRouteInternshipConsultation;
  final VoidCallback? onCancel;
  final SeparationItemsViewModel? viewModel;
  final CartSeparationCoordinator? coordinator;

  const CartItemCard({
    super.key,
    required this.cartRouteInternshipConsultation,
    this.onCancel,
    this.viewModel,
    this.coordinator,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  DateTime? _lastSyncTime;
  String? _lastSyncKey;
  static const _minSyncInterval = Duration(seconds: 2);
  bool _isSaving = false;
  BuildContext? _loadingDialogContext;

  late final CartSeparationCoordinator _coordinator =
      widget.coordinator ??
      CartSeparationCoordinator(
        userSessionService: locator<IUserSessionService>(),
        cartValidationService: locator<CartValidationService>(),
        getSeparationConsultationUseCase: locator<GetSeparationConsultationUseCase>(),
        saveSeparationCartUseCase: locator<SaveSeparationCartUseCase>(),
      );

  ExpeditionCartRouteInternshipConsultationModel _resolveCurrentCart() {
    final viewModel = widget.viewModel;
    if (viewModel == null) {
      return widget.cartRouteInternshipConsultation;
    }

    return viewModel.getCartSnapshot(
          codEmpresa: widget.cartRouteInternshipConsultation.codEmpresa,
          codCarrinhoPercurso: widget.cartRouteInternshipConsultation.codCarrinhoPercurso,
          item: widget.cartRouteInternshipConsultation.item,
        ) ??
        widget.cartRouteInternshipConsultation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isActive = widget.cartRouteInternshipConsultation.ativo.code == 'S';
    final isFinalized = widget.cartRouteInternshipConsultation.dataFinalizacao != null;
    final situationColor = _getSituationColor(widget.cartRouteInternshipConsultation.situacao, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shadowColor: situationColor.withValues(alpha: 0.2),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.largeBorderRadius),
        side: BorderSide(color: situationColor.withValues(alpha: 0.4), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.largeBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [situationColor.withValues(alpha: 0.05), situationColor.withValues(alpha: 0.02)],
          ),
        ),
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CartItemCardHeader(
              cart: widget.cartRouteInternshipConsultation,
              isActive: isActive,
              isFinalized: isFinalized,
              situationColor: situationColor,
            ),

            const SizedBox(height: UIConstants.defaultPadding),

            CartItemCardCodeSituation(cart: widget.cartRouteInternshipConsultation, situationColor: situationColor),

            const SizedBox(height: UIConstants.defaultPadding),

            CartItemTimelineSection(cart: widget.cartRouteInternshipConsultation, isFinalized: isFinalized),

            if (widget.cartRouteInternshipConsultation.nomeSetorEstoque != null) ...[
              const SizedBox(height: UIConstants.smallPadding),
              CartItemSectorInfo(cart: widget.cartRouteInternshipConsultation),
            ],

            if (widget.cartRouteInternshipConsultation.carrinhoAgrupadorCode.isNotEmpty) ...[
              const SizedBox(height: UIConstants.smallPadding),
              CartItemGroupInfo(cart: widget.cartRouteInternshipConsultation),
            ],

            const SizedBox(height: UIConstants.defaultPadding),
            CartItemActionsBar(
              cart: widget.cartRouteInternshipConsultation,
              situationColor: situationColor,
              isSaving: _isSaving,
              viewModel: widget.viewModel,
              onSeparate: () => _onSeparateCart(context),
              onViewReadOnly: () => _onViewCartReadOnly(context),
              onView: () => _onViewCart(context),
              onFinalize: () => _onFinalizeCart(context),
              onShowCancelDialog: () => _showCancelDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSeparateCart(BuildContext context) async {
    final currentCart = _resolveCurrentCart();
    final userModel = await _getUserModel();
    final currentUserCode = userModel?.codUsuario;
    final userSectorCode = userModel?.codSetorEstoque;

    final accessValidation = _coordinator.validateAccess(
      currentUserCode: currentUserCode,
      cart: currentCart,
      userModel: userModel,
      accessType: CartAccessType.edit,
    );

    if (!accessValidation.canAccess) {
      if (context.mounted && accessValidation.cartOwnerName != null) {
        _showDifferentUserDialog(context, accessValidation.cartOwnerName!, actionLabel: 'separar');
      }
      return;
    }

    if (userSectorCode != null) {
      final hasItems = await _coordinator.hasItemsForUserSector(
        codEmpresa: widget.cartRouteInternshipConsultation.codEmpresa,
        codOrigem: widget.cartRouteInternshipConsultation.codOrigem,
        userSectorCode: userSectorCode,
      );

      if (!hasItems && context.mounted) {
        _showNoItemsForSectorDialog(context, userSectorCode);
        return;
      }
    }

    if (context.mounted) {
      final result = await context.push(AppRouter.cardPicking, extra: {'cart': currentCart, 'userModel': userModel});

      if (context.mounted && widget.viewModel != null && result != 'save_cart') {
        unawaited(_syncSeparationFromServer(context));
      }

      if (result == 'save_cart' && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carrinho salvo com sucesso!'),
            backgroundColor: AppColors.success,
            duration: UIConstants.snackBarShortDuration,
          ),
        );
        context.go(AppRouter.separation);
      }
    }
  }

  Future<void> _syncSeparationFromServer(BuildContext context) async {
    if (widget.viewModel == null) return;

    final syncKey =
        '${widget.cartRouteInternshipConsultation.codEmpresa}_${widget.cartRouteInternshipConsultation.codOrigem}';
    final now = DateTime.now();
    if (_lastSyncKey == syncKey && _lastSyncTime != null && now.difference(_lastSyncTime!) < _minSyncInterval) {
      return;
    }
    _lastSyncKey = syncKey;
    _lastSyncTime = now;

    final fresh = await _coordinator.fetchSeparation(
      codEmpresa: widget.cartRouteInternshipConsultation.codEmpresa,
      codSepararEstoque: widget.cartRouteInternshipConsultation.codOrigem,
    );
    if (!context.mounted) return;

    if (context.mounted) unawaited(widget.viewModel!.refreshWithSeparation(fresh));
  }

  Future<UserSystemModel?> _getUserModel() => _coordinator.getUserModel();

  void _showDifferentUserDialog(BuildContext context, String cartOwnerName, {required String actionLabel}) {
    if (!context.mounted) return;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => CartAccessDeniedDialog(
          actionLabel: actionLabel,
          cartOwnerName: cartOwnerName,
          onClose: () => Navigator.of(dialogContext).pop(),
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog de acesso negado ao carrinho',
          tag: 'CartItemCard',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _showNoItemsForSectorDialog(BuildContext context, int userSectorCode) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => CartNoItemsForSectorDialog(
          userSectorCode: userSectorCode,
          onClose: () => Navigator.of(dialogContext).pop(),
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning('Falha ao exibir dialog sem itens do setor', tag: 'CartItemCard', error: e, stackTrace: s);
      }),
    );
  }

  void _ensureLoadingDialogClosed() {
    if (_loadingDialogContext == null) return;
    if (!mounted || !_loadingDialogContext!.mounted) {
      _loadingDialogContext = null;
      return;
    }
    try {
      Navigator.of(_loadingDialogContext!).pop();
    } catch (e) {
      AppLogger.warning('Erro ao fechar loading: $e', tag: 'CartItemCard');
    } finally {
      _loadingDialogContext = null;
    }
  }

  Future<bool> _onFinalizeCart(BuildContext context, {bool skipConfirmation = false}) async {
    if (_isSaving) return false;
    setState(() => _isSaving = true);

    final socketValidation = SocketValidationHelper.validateSocketState();
    if (!socketValidation.isValid) {
      if (mounted) setState(() => _isSaving = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(socketValidation.errorMessage ?? 'Conexão não está pronta. Tente novamente.'),
            backgroundColor: AppColors.error,
            duration: UIConstants.snackBarMediumDuration,
          ),
        );
      }
      return false;
    }

    final currentCart = _resolveCurrentCart();
    final userModel = await _getUserModel();

    if (!context.mounted) {
      if (mounted) setState(() => _isSaving = false);
      return false;
    }

    final accessValidation = _coordinator.validateAccess(
      currentUserCode: userModel?.codUsuario,
      cart: currentCart,
      userModel: userModel,
      accessType: CartAccessType.save,
    );

    if (!accessValidation.canAccess) {
      if (mounted) setState(() => _isSaving = false);
      if (context.mounted && accessValidation.cartOwnerName != null) {
        _showDifferentUserDialog(context, accessValidation.cartOwnerName!, actionLabel: 'salvar');
      }
      return false;
    }

    if (!skipConfirmation) {
      final confirmed = await _showFinalizeConfirmationDialog(context);
      if (!confirmed || !context.mounted) {
        if (mounted) setState(() => _isSaving = false);
        return false;
      }
    }

    if (!context.mounted) {
      if (mounted) setState(() => _isSaving = false);
      return false;
    }

    _showLoadingDialog(context);

    try {
      final params = SaveSeparationCartParams(
        codEmpresa: currentCart.codEmpresa,
        codCarrinhoPercurso: currentCart.codCarrinhoPercurso,
        itemCarrinhoPercurso: currentCart.item,
        codSepararEstoque: currentCart.codOrigem,
      );

      final outcome = await _coordinator
          .finalizeCart(params)
          .timeout(
            UIConstants.networkTimeout,
            onTimeout: () {
              throw TimeoutException(
                'Operação excedeu o tempo limite de ${UIConstants.networkTimeout.inSeconds} segundos',
              );
            },
          );

      if (context.mounted) {
        _ensureLoadingDialogClosed();
      }

      if (outcome is FinalizeCartFailure) {
        final failure = outcome.failure;
        if (context.mounted && failure != null) {
          _showErrorDialog(context, failure);
        } else if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Erro ao salvar carrinho.'), backgroundColor: AppColors.error));
        }
        return false;
      }

      final success = (outcome as FinalizeCartSuccess).success;
      if (!context.mounted) return true;
      if (!skipConfirmation) _showSuccessDialog(context, success);
      if (widget.viewModel != null) unawaited(widget.viewModel!.refresh());

      return true;
    } on TimeoutException catch (e) {
      AppLogger.error('Timeout ao salvar carrinho', tag: 'CartItemCard', error: e);
      if (context.mounted) _ensureLoadingDialogClosed();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tempo esgotado. Verifique sua conexão e tente novamente.'),
            backgroundColor: AppColors.error,
            duration: UIConstants.snackBarMediumDuration,
          ),
        );
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Erro inesperado ao salvar carrinho', tag: 'CartItemCard', error: e, stackTrace: stackTrace);
      if (context.mounted) _ensureLoadingDialogClosed();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro inesperado ao salvar carrinho. Tente novamente.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onViewCart(BuildContext context) {
    if (!context.mounted) return;

    context.push(
      AppRouter.pickingProductsList,
      extra: {'filterType': 'completed', 'cart': widget.cartRouteInternshipConsultation},
    );
  }

  void _onViewCartReadOnly(BuildContext context) {
    if (!context.mounted) return;

    context.push(
      AppRouter.pickingProductsList,
      extra: {'filterType': 'completed', 'cart': widget.cartRouteInternshipConsultation, 'isReadOnly': true},
    );
  }

  Future<bool> _showFinalizeConfirmationDialog(BuildContext context) async {
    if (!context.mounted) return false;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return ListenableBuilder(
              listenable: locator<PickingStateManager>(),
              builder: (context, _) {
                final pickingState = locator<PickingStateManager>().pickingState;
                final hasPending = pickingState.hasAnyPendingOperations();
                final pendingCount = pickingState.getTotalPendingOperations();
                return CartFinalizeConfirmationDialogContent(
                  codCarrinho: widget.cartRouteInternshipConsultation.codCarrinho,
                  hasPending: hasPending,
                  pendingCount: pendingCount,
                  onCancel: () => Navigator.of(dialogContext).pop(false),
                  onConfirm: () => Navigator.of(dialogContext).pop(true),
                );
              },
            );
          },
        ).catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha ao exibir confirmação de finalização (carrinho)',
            tag: 'CartItemCard',
            error: e,
            stackTrace: s,
          );
          return false;
        });

    return confirmed ?? false;
  }

  void _showLoadingDialog(BuildContext context) {
    if (!context.mounted) return;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          _loadingDialogContext = dialogContext;
          return const AlertDialog(
            content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Finalizando carrinho...')]),
          );
        },
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog de carregamento (finalizar carrinho)',
          tag: 'CartItemCard',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _showSuccessDialog(BuildContext context, SaveSeparationCartSuccess success) {
    if (!context.mounted) return;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => CartFinalizeSuccessDialog(
          codCarrinho: widget.cartRouteInternshipConsultation.codCarrinho,
          success: success,
          onOk: () => Navigator.of(dialogContext).pop(),
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog de sucesso ao finalizar carrinho',
          tag: 'CartItemCard',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _showErrorDialog(BuildContext context, AppFailure failure) {
    if (!context.mounted) return;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) =>
            CartFinalizeErrorDialog(failure: failure, onOk: () => Navigator.of(dialogContext).pop()),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog de erro ao finalizar carrinho',
          tag: 'CartItemCard',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final currentCart = _resolveCurrentCart();
    final userModel = await _getUserModel();

    final accessValidation = _coordinator.validateAccess(
      currentUserCode: userModel?.codUsuario,
      cart: currentCart,
      userModel: userModel,
      accessType: CartAccessType.delete,
    );

    if (!accessValidation.canAccess) {
      if (context.mounted && accessValidation.cartOwnerName != null) {
        _showDifferentUserDialog(context, accessValidation.cartOwnerName!, actionLabel: 'cancelar');
      }
      return;
    }

    if (!context.mounted) return;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => CartCancelConfirmationDialog(
          codCarrinho: widget.cartRouteInternshipConsultation.codCarrinho,
          nomeCarrinho: widget.cartRouteInternshipConsultation.nomeCarrinho,
          situacaoDescription: widget.cartRouteInternshipConsultation.situacao.description,
          onKeep: () => Navigator.of(dialogContext).pop(),
          onConfirm: () {
            final messenger = ScaffoldMessenger.of(dialogContext);
            final vm = widget.viewModel ?? dialogContext.read<SeparationItemsViewModel>();
            Navigator.of(dialogContext).pop();
            unawaited(
              CartCancelFlowCoordinator(
                codCarrinho: widget.cartRouteInternshipConsultation.codCarrinho,
                onCancel: widget.onCancel,
              ).cancelCart(messenger, vm).catchError((Object e, StackTrace s) {
                AppLogger.warning(
                  'Falha não tratada ao cancelar carrinho',
                  tag: 'CartItemCard',
                  error: e,
                  stackTrace: s,
                );
              }),
            );
          },
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog de cancelamento de carrinho',
          tag: 'CartItemCard',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  Color _getSituationColor(ExpeditionSituation situacao, ColorScheme colorScheme) {
    final cardSituation = ExpeditionSituation.fromCode(situacao.code);
    return cardSituation?.color ?? AppColors.grey;
  }
}
