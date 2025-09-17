import 'package:flutter/material.dart';

import 'package:exp/domain/models/separate_item_consultation_model.dart';

class SeparateItemCard extends StatelessWidget {
  final SeparateItemConsultationModel item;
  final VoidCallback? onSeparate;

  const SeparateItemCard({super.key, required this.item, this.onSeparate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isCompleted = item.quantidadeSeparacao >= item.quantidade;
    final isPartiallyCompleted = item.quantidadeSeparacao > 0 && !isCompleted;
    final completionColor = isCompleted
        ? Colors.green
        : isPartiallyCompleted
        ? colorScheme.primary
        : colorScheme.outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCompleted ? 3 : 0,
      shadowColor: isCompleted ? Colors.green.withOpacity(0.3) : null,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: completionColor.withOpacity(isCompleted ? 0.6 : 0.3),
          width: isCompleted
              ? 3
              : isPartiallyCompleted
              ? 2
              : 1,
        ),
      ),
      child: Container(
        decoration: isCompleted
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.withOpacity(0.08),
                    Colors.green.withOpacity(0.03),
                  ],
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do item com código e nome
              _buildHeader(context, theme, colorScheme),

              const SizedBox(height: 12),

              // Código de barras e status
              _buildCodeAndStatus(context, theme, colorScheme, isCompleted),

              const SizedBox(height: 8),

              // Localização e grupo
              _buildLocationRow(context, theme, colorScheme),

              const SizedBox(height: 12),

              // Informações de quantidade e grupo
              _buildQuantityRow(context, theme, colorScheme, isCompleted),

              // Botão de ação (se não estiver completo)
              if (!isCompleted && onSeparate != null) ...[
                const SizedBox(height: 16),
                _buildActionButton(context, theme, colorScheme),
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.nomeProduto,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.nomeMarca != null) ...[
          const SizedBox(height: 2),
          Text(
            '${item.nomeMarca}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCodeAndStatus(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isCompleted,
  ) {
    return Row(
      children: [
        if (item.codigoBarras != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Código: ${item.codigoBarras}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        // Status visual (movido para cá)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.withOpacity(0.15)
                : colorScheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.hourglass_empty,
                color: isCompleted ? Colors.green : colorScheme.error,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isCompleted ? 'Separado' : 'Pendente',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isCompleted ? Colors.green : colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        if (item.nomeSetorEstoque != null) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Setor',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                        Text(
                          '${item.nomeSetorEstoque}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onTertiaryContainer,
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
          const SizedBox(width: 8),
        ],
        if (item.endereco != null || item.enderecoDescricao != null) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place,
                    size: 16,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Endereço',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        Text(
                          item.enderecoDescricao ?? item.endereco ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
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
      ],
    );
  }

  Widget _buildQuantityRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isCompleted,
  ) {
    final quantidadeRestante = item.quantidade - item.quantidadeSeparacao;

    return Row(
      children: [
        Expanded(
          child: _buildInfoColumn(context, 'UN', item.nomeUnidadeMedida),
        ),
        Expanded(
          child: _buildInfoColumn(
            context,
            'Qtd. Total',
            item.quantidade.toStringAsFixed(2),
          ),
        ),
        Expanded(
          child: _buildInfoColumn(
            context,
            'Qtd. Separada',
            item.quantidadeSeparacao.toStringAsFixed(2),
            color: isCompleted ? Colors.green : colorScheme.error,
          ),
        ),
        Expanded(
          child: _buildInfoColumn(
            context,
            'Qtd. Restante',
            quantidadeRestante.toStringAsFixed(2),
            color: quantidadeRestante > 0
                ? colorScheme.tertiary
                : colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    int? maxLines,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onSeparate,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.shopping_cart, size: 20),
        label: const Text(
          'Separar Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
