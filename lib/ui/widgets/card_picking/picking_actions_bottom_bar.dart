import 'package:flutter/material.dart';

import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/core/theme/app_colors.dart';

class PickingActionsBottomBar extends StatelessWidget {
  final CardPickingViewModel viewModel;
  final ExpeditionCartRouteInternshipConsultationModel cart;

  const PickingActionsBottomBar({super.key, required this.viewModel, required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(color: AppColors.withOpacity(colorScheme.shadow, 0.1), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: _buildProgressInfo(context, theme, colorScheme),
        ),
      ),
    );
  }

  Widget _buildProgressInfo(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final progress = viewModel.progress;
    final completedItems = viewModel.completedItems;
    final totalItems = viewModel.totalItems;
    final isComplete = viewModel.isPickingComplete;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.withOpacity(AppColors.success, 0.1)
            : AppColors.withOpacity(colorScheme.primaryContainer, 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isComplete
              ? AppColors.withOpacity(AppColors.success, 0.3)
              : AppColors.withOpacity(colorScheme.primary, 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.inventory_2,
            color: isComplete ? AppColors.success : colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isComplete ? 'Picking Concluído!' : 'Progresso do Picking',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isComplete ? AppColors.success : colorScheme.primary,
                  ),
                ),
                Text(
                  '$completedItems de $totalItems itens separados',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isComplete ? AppColors.success : colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
