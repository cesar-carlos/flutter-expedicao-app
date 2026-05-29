import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';

class CartItemCardHeader extends StatelessWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final bool isActive;
  final bool isFinalized;
  final Color situationColor;

  const CartItemCardHeader({
    super.key,
    required this.cart,
    required this.isActive,
    required this.isFinalized,
    required this.situationColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(UIConstants.smallPadding),
          decoration: BoxDecoration(
            color: situationColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          ),
          child: Icon(Icons.shopping_cart, color: situationColor, size: UIConstants.mediumIconSize),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: situationColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    ),
                    child: Text(
                      '#${cart.codCarrinho}',
                      style: theme.textTheme.labelMedium?.copyWith(color: situationColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),

                  _CartItemStatusChip(
                    cart: cart,
                    isFinalized: isFinalized,
                    isActive: isActive,
                    situationColor: situationColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Text(
                cart.nomeCarrinho,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartItemStatusChip extends StatelessWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final bool isFinalized;
  final bool isActive;
  final Color situationColor;

  const _CartItemStatusChip({
    required this.cart,
    required this.isFinalized,
    required this.isActive,
    required this.situationColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: situationColor,
        borderRadius: BorderRadius.circular(UIConstants.extraLargeBorderRadius),
        boxShadow: [BoxShadow(color: situationColor.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFinalized
                ? Icons.check_circle_outline
                : isActive
                ? Icons.play_circle_outline
                : Icons.pause_circle_outline,
            color: AppColors.white,
            size: UIConstants.smallIconSize,
          ),
          const SizedBox(width: 4),
          Text(
            cart.situacao.description,
            style: theme.textTheme.labelSmall?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
