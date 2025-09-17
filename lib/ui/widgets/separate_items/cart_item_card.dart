import 'package:flutter/material.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';

class CartItemCard extends StatelessWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final VoidCallback? onTap;

  const CartItemCard({super.key, required this.cart, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isActive = cart.ativo.code == 'S';
    final isFinalized = cart.dataFinalizacao != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do carrinho
              _buildHeader(context, theme, colorScheme, isActive, isFinalized),

              const SizedBox(height: 12),

              // Informações do carrinho
              _buildCartInfo(context, theme, colorScheme),

              const SizedBox(height: 12),

              // Informações do usuário
              _buildUserInfo(context, theme, colorScheme, isFinalized),

              if (cart.nomeSetorEstoque != null) ...[
                const SizedBox(height: 12),
                _buildSectorInfo(context, theme, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isActive,
    bool isFinalized,
  ) {
    return Row(
      children: [
        // Código do carrinho
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${cart.codCarrinho}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Nome do carrinho
        Expanded(
          child: Text(
            cart.nomeCarrinho,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Status visual
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isFinalized
                ? Colors.green.withOpacity(0.1)
                : isActive
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFinalized
                    ? Icons.check_circle
                    : isActive
                    ? Icons.play_circle
                    : Icons.pause_circle,
                color: isFinalized
                    ? Colors.green
                    : isActive
                    ? colorScheme.primary
                    : colorScheme.error,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isFinalized
                    ? 'Finalizado'
                    : isActive
                    ? 'Ativo'
                    : 'Inativo',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isFinalized
                      ? Colors.green
                      : isActive
                      ? colorScheme.primary
                      : colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartInfo(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        // Código de barras do carrinho
        if (cart.codigoBarrasCarrinho.isNotEmpty) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Código de Barras',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          cart.codigoBarrasCarrinho,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        // Situação
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSituationColor(
                cart.situacao,
                colorScheme,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  size: 16,
                  color: _getSituationColor(cart.situacao, colorScheme),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Situação',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getSituationColor(cart.situacao, colorScheme),
                        ),
                      ),
                      Text(
                        cart.situacao.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getSituationColor(cart.situacao, colorScheme),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isFinalized,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoColumn(
            context,
            'Usuário Início',
            cart.nomeUsuarioInicio,
            Icons.person,
            colorScheme.primary,
          ),
        ),
        Expanded(
          child: _buildInfoColumn(
            context,
            'Data Início',
            _formatDate(cart.dataInicio),
            Icons.schedule,
            colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectorInfo(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: colorScheme.onTertiaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setor de Estoque',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cart.nomeSetorEstoque!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Color _getSituationColor(
    ExpeditionCartSituation situacao,
    ColorScheme colorScheme,
  ) {
    switch (situacao.code) {
      case 'SEPARADO':
      case 'CONFERIDO':
        return Colors.green;
      case 'EM SEPARACAO':
      case 'SEPARANDO':
        return colorScheme.primary;
      case 'EM CONFERENCIA':
      case 'CONFERINDO':
        return colorScheme.secondary;
      case 'LIBERADO':
      case 'AGRUPADO':
        return colorScheme.tertiary;
      case 'CANCELADO':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}
