import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_items_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_flat_button.dart';

class CartItemActionsBar extends StatelessWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final Color situationColor;
  final bool isSaving;
  final SeparationItemsViewModel? viewModel;
  final VoidCallback onSeparate;
  final VoidCallback onViewReadOnly;
  final VoidCallback onView;
  final VoidCallback onFinalize;
  final VoidCallback onShowCancelDialog;

  const CartItemActionsBar({
    super.key,
    required this.cart,
    required this.situationColor,
    required this.isSaving,
    required this.viewModel,
    required this.onSeparate,
    required this.onViewReadOnly,
    required this.onView,
    required this.onFinalize,
    required this.onShowCancelDialog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(UIConstants.smallPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: situationColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          if (_shouldShowSeparateButton()) ...[
            Row(
              children: [
                Expanded(
                  child: CustomFlatButtonVariations.outlined(
                    text: 'Separar',
                    icon: Icons.play_arrow,
                    textColor: theme.adaptivePrimary(colorScheme),
                    borderColor: colorScheme.primary.withValues(alpha: 0.3),
                    onPressed: onSeparate,
                  ),
                ),
                const SizedBox(width: 8),

                _CartItemViewIconButton(onTap: onViewReadOnly),

                if (cart.situacao == ExpeditionSituation.separando) ...[
                  const SizedBox(width: 8),
                  viewModel != null
                      ? _CartItemCancelIconButton(
                          cart: cart,
                          viewModel: viewModel!,
                          isSaveInProgress: isSaving,
                          onTap: onShowCancelDialog,
                        )
                      : Consumer<SeparationItemsViewModel>(
                          builder: (context, vm, child) {
                            return _CartItemCancelIconButton(
                              cart: cart,
                              viewModel: vm,
                              isSaveInProgress: isSaving,
                              onTap: onShowCancelDialog,
                            );
                          },
                        ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],

          if (cart.situacao == ExpeditionSituation.separando) ...[
            SizedBox(
              width: double.infinity,
              child: CustomFlatButtonVariations.outlined(
                text: 'Salvar',
                icon: Icons.check_circle,
                textColor: AppColors.success,
                borderColor: AppColors.success.withValues(alpha: 0.3),
                onPressed: isSaving ? null : onFinalize,
              ),
            ),
          ],

          if (_shouldShowViewButton()) ...[
            SizedBox(
              width: double.infinity,
              child: CustomFlatButtonVariations.outlined(
                text: 'Visualizar',
                icon: Icons.visibility,
                textColor: colorScheme.tertiary,
                borderColor: colorScheme.tertiary.withValues(alpha: 0.3),
                onPressed: onView,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _shouldShowSeparateButton() {
    if (cart.situacao == ExpeditionSituation.cancelada ||
        cart.situacao == ExpeditionSituation.separado ||
        cart.situacao == ExpeditionSituation.conferido ||
        cart.situacao == ExpeditionSituation.entregue ||
        cart.situacao == ExpeditionSituation.embalado) {
      return false;
    }

    return true;
  }

  bool _shouldShowViewButton() {
    return cart.situacao == ExpeditionSituation.separado ||
        cart.situacao == ExpeditionSituation.conferido ||
        cart.situacao == ExpeditionSituation.entregue ||
        cart.situacao == ExpeditionSituation.embalado ||
        cart.situacao == ExpeditionSituation.cancelada;
  }
}

class _CartItemCancelIconButton extends StatelessWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final SeparationItemsViewModel viewModel;
  final bool isSaveInProgress;
  final VoidCallback onTap;

  const _CartItemCancelIconButton({
    required this.cart,
    required this.viewModel,
    required this.isSaveInProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCancelling = viewModel.isCartBeingCancelled(cart.codCarrinho);
    final isBusy = isCancelling || isSaveInProgress;

    return Container(
      width: UIConstants.defaultButtonHeight,
      height: UIConstants.defaultButtonHeight,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        color: AppColors.transparent,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          onTap: isBusy ? null : onTap,
          child: Center(
            child: isBusy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isCancelling ? colorScheme.error : colorScheme.primary,
                    ),
                  )
                : Icon(Icons.delete_outline, color: colorScheme.error, size: UIConstants.defaultIconSize),
          ),
        ),
      ),
    );
  }
}

class _CartItemViewIconButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CartItemViewIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: UIConstants.defaultButtonHeight,
      height: UIConstants.defaultButtonHeight,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        color: AppColors.transparent,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          onTap: onTap,
          child: Center(
            child: Icon(Icons.visibility, color: colorScheme.tertiary, size: UIConstants.defaultIconSize),
          ),
        ),
      ),
    );
  }
}
