import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';

class CartItemTimelineSection extends StatelessWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final bool isFinalized;

  const CartItemTimelineSection({super.key, required this.cart, required this.isFinalized});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(UIConstants.smallPadding),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle),
                child: Icon(Icons.play_arrow, color: AppColors.white, size: UIConstants.smallIconSize),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Iniciado por ${cart.nomeUsuarioInicio}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      '${_formatDate(cart.dataInicio)} às ${cart.horaInicio}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isFinalized && cart.nomeUsuarioFinalizacao != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: Icon(Icons.check, color: AppColors.white, size: UIConstants.smallIconSize),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finalizado por ${cart.nomeUsuarioFinalizacao!}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.green800,
                        ),
                      ),
                      Text(
                        '${_formatDate(cart.dataFinalizacao!)} às ${cart.horaFinalizacao!}',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.green700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
