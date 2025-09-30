import 'package:flutter/material.dart';

import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/viewmodels/separate_items_viewmodel.dart';

class SeparationInfoView extends StatelessWidget {
  final SeparateConsultationModel separation;
  final SeparateItemsViewModel viewModel;

  const SeparationInfoView({super.key, required this.separation, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status da separação
          _buildStatusCard(context, theme, colorScheme),

          const SizedBox(height: 16),

          // Informações da entidade
          _buildEntityCard(context, theme, colorScheme),

          const SizedBox(height: 16),

          // Informações da operação
          _buildOperationCard(context, theme, colorScheme),

          const SizedBox(height: 16),

          // Estatísticas da separação
          if (viewModel.hasData) ...[_buildStatsCard(context, theme, colorScheme), const SizedBox(height: 16)],

          // Informações adicionais
          _buildAdditionalInfoCard(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: separation.situacao.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: separation.situacao.color.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: separation.situacao.color, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Status da Separação',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: separation.situacao.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Código', '#${separation.codSepararEstoque}', icon: Icons.tag),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Situação',
              separation.situacao.description.toUpperCase(),
              icon: Icons.circle,
              valueColor: separation.situacao.color,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Prioridade', separation.nomePrioridade, icon: Icons.priority_high),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Data de Emissão', _formatDate(separation.dataEmissao), icon: Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityCard(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Informações da Entidade',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Entidade', separation.nomeEntidade, icon: Icons.account_circle),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Código da Entidade', '${separation.codEntidade}', icon: Icons.badge),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Tipo de Entidade', separation.tipoEntidade.description, icon: Icons.category),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCard(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.tertiaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: colorScheme.tertiary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Operação',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Tipo de Operação',
              separation.nomeTipoOperacaoExpedicao,
              icon: Icons.local_shipping,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Código da Operação',
              '${separation.codTipoOperacaoExpedicao}',
              icon: Icons.confirmation_number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.secondaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: colorScheme.secondary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Estatísticas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    context,
                    'Total de Itens',
                    '${viewModel.totalItems}',
                    Icons.inventory,
                    colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatColumn(
                    context,
                    'Itens Separados',
                    '${viewModel.itemsSeparados}',
                    Icons.check_circle,
                    colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    context,
                    'Progresso',
                    '${viewModel.percentualConcluido.toStringAsFixed(0)}%',
                    Icons.trending_up,
                    colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: _buildStatColumn(
                    context,
                    'Status',
                    viewModel.isSeparationComplete ? 'Completa' : 'Em Andamento',
                    viewModel.isSeparationComplete ? Icons.done_all : Icons.hourglass_empty,
                    viewModel.isSeparationComplete ? Colors.green : colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: colorScheme.onSurfaceVariant, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Informações Adicionais',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (separation.observacao != null && separation.observacao!.isNotEmpty) ...[
              _buildInfoRow(context, 'Observação', separation.observacao!, icon: Icons.note),
              const SizedBox(height: 12),
            ],
            _buildInfoRow(context, 'Código da Empresa', '${separation.codEmpresa}', icon: Icons.business_center),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {IconData? icon, Color? valueColor}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[Icon(icon, size: 20, color: colorScheme.onSurfaceVariant), const SizedBox(width: 8)],
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
