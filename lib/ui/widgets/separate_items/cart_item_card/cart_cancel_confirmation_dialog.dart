import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class CartCancelConfirmationDialog extends StatelessWidget {
  final int codCarrinho;
  final String nomeCarrinho;
  final String situacaoDescription;
  final VoidCallback onKeep;
  final VoidCallback onConfirm;

  const CartCancelConfirmationDialog({
    super.key,
    required this.codCarrinho,
    required this.nomeCarrinho,
    required this.situacaoDescription,
    required this.onKeep,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: colorScheme.error),
          const SizedBox(width: 8),
          const Text('Cancelar Carrinho'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deseja realmente cancelar o carrinho?'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(UIConstants.smallPadding),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              border: Border.all(color: colorScheme.error.withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carrinho #$codCarrinho',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(nomeCarrinho, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  'Status: $situacaoDescription',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Esta ação não pode ser desfeita. O carrinho será marcado como CANCELADO.',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onKeep, child: const Text('Não, manter')),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error, foregroundColor: AppColors.white),
          child: const Text('Sim, cancelar'),
        ),
      ],
    );
  }
}
