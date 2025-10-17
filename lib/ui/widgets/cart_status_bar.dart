import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';

/// Widget que exibe a situação do carrinho em uma linha separada
class CartStatusBar extends StatelessWidget {
  const CartStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CardPickingViewModel>(
      builder: (context, viewModel, child) {
        final cart = viewModel.cart;
        final situation = cart?.situacao;

        if (situation == null) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 24,
          width: double.infinity,
          decoration: BoxDecoration(
            color: situation.color.withValues(alpha: 0.1),
            border: Border(
              top: BorderSide(color: situation.color.withValues(alpha: 0.3), width: 1),
              bottom: BorderSide(color: situation.color.withValues(alpha: 0.3), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getSituationIcon(situation.code), size: 14, color: situation.color),
              const SizedBox(width: 6),
              Text(
                situation.description,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: situation.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              if (viewModel.hasCartStatusChanged) ...[
                const SizedBox(width: 8),
                Icon(Icons.update, size: 12, color: situation.color),
                const SizedBox(width: 2),
                Text(
                  'Atualizado',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: situation.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Retorna o ícone apropriado para cada situação
  IconData _getSituationIcon(String situationCode) {
    switch (situationCode.toUpperCase()) {
      case 'LIBERADO':
        return Icons.check_circle_outline;
      case 'EM SEPARACAO':
        return Icons.inventory_2;
      case 'SEPARANDO':
        return Icons.inventory_2;
      case 'SEPARADO':
        return Icons.check_circle;
      case 'EM CONFERENCIA':
        return Icons.visibility;
      case 'CONFERIDO':
        return Icons.visibility_off;
      case 'EM ENTREGA':
        return Icons.local_shipping;
      case 'EM PAUSA':
        return Icons.pause_circle;
      case 'CANCELADA':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
