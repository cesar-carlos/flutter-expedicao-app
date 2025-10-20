import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_status.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

class SeparateItemCard extends StatelessWidget {
  final SeparateItemConsultationModel item;
  final VoidCallback? onSeparate;

  const SeparateItemCard({super.key, required this.item, this.onSeparate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Usar a situação real do item
    final situacao = item.situacaoSeparacao;
    final situacaoColor = situacao.color;
    final isCompleted = situacao == SeparationItemStatus.separado;
    final isPartiallyCompleted = situacao == SeparationItemStatus.parcial;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCompleted ? 3 : 0,
      shadowColor: isCompleted ? situacaoColor.withValues(alpha: 0.3) : null,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: situacaoColor.withValues(alpha: isCompleted ? 0.6 : 0.3),
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
                  colors: [situacaoColor.withValues(alpha: 0.08), situacaoColor.withValues(alpha: 0.03)],
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

              // Botão de ação removido conforme solicitado
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.nomeProduto,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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

  Widget _buildCodeAndStatus(BuildContext context, ThemeData theme, ColorScheme colorScheme, bool isCompleted) {
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
                Icon(Icons.qr_code, size: 16, color: colorScheme.onSurfaceVariant),
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
            color: isCompleted ? Colors.green.withValues(alpha: 0.15) : colorScheme.error.withValues(alpha: 0.1),
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

  Widget _buildLocationRow(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        if (item.nomeSetorEstoque != null) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: colorScheme.onTertiaryContainer),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Setor',
                          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onTertiaryContainer),
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
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.place, size: 16, color: colorScheme.onSecondaryContainer),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Endereço',
                          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSecondaryContainer),
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

  Widget _buildQuantityRow(BuildContext context, ThemeData theme, ColorScheme colorScheme, bool isCompleted) {
    final quantidadeRestante = item.quantidade - item.quantidadeSeparacao;

    return Row(
      children: [
        Expanded(child: _buildUnitColumn(context, theme, colorScheme)),
        Expanded(child: _buildInfoColumn(context, 'Qtd. Total', item.quantidade.toStringAsFixed(2))),
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
            color: quantidadeRestante > 0 ? colorScheme.tertiary : colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitColumn(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final unidadePadrao = item.unidadeMedidaPadrao;
    final temVariasUnidades = item.unidadeMedidas.length > 1;

    return GestureDetector(
      onTap: temVariasUnidades ? () => _showUnitsModal(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: temVariasUnidades
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3), width: 1),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'UN',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (temVariasUnidades) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more, size: 16, color: colorScheme.onSurfaceVariant),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              unidadePadrao?.unidadeMedidaDescricao ?? item.nomeUnidadeMedida,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UnitsModal(title: item.nomeProduto, units: item.unidadeMedidas),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value, {Color? color, int? maxLines}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
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
}

class _UnitsModal extends StatelessWidget {
  final String title;
  final List<SeparateItemUnidadeMedidaConsultationModel> units;

  const _UnitsModal({required this.title, required this.units});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header do modal
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Unidades de Medida',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Lista de unidades
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                final isDefault = unit.unidadeMedidaPadrao == Situation.ativo;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDefault
                        ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                        : colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDefault
                          ? colorScheme.primary.withValues(alpha: 0.5)
                          : colorScheme.outline.withValues(alpha: 0.2),
                      width: isDefault ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDefault ? colorScheme.primary : colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isDefault ? Icons.star : Icons.straighten,
                        color: isDefault ? colorScheme.onPrimary : colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                unit.codUnidadeMedida,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                unit.unidadeMedidaDescricao,
                                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'PADRÃO',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildUnitInfo(context, 'Fator Conversão', unit.fatorConversao.toStringAsFixed(4)),
                            ),
                            Expanded(child: _buildUnitInfo(context, 'Tipo Fator', unit.tipoFatorConversao.description)),
                          ],
                        ),
                        if (unit.codigoBarras != null) ...[
                          const SizedBox(height: 8),
                          _buildUnitInfo(context, 'Código de Barras', unit.codigoBarras!),
                        ],
                        if (unit.observacao != null && unit.observacao!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildUnitInfo(context, 'Observação', unit.observacao!),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitInfo(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
