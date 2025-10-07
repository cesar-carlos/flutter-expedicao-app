import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'package:exp/domain/models/separation_item_consultation_model.dart';
import 'package:exp/domain/models/situation/expedition_item_situation_model.dart';
import 'package:exp/domain/viewmodels/separated_products_viewmodel.dart';
import 'package:exp/ui/widgets/common/custom_flat_button.dart';

class SeparatedProductItem extends StatelessWidget {
  final SeparationItemConsultationModel item;
  final SeparatedProductsViewModel? viewModel;

  const SeparatedProductItem({super.key, required this.item, this.viewModel});

  // === CONSTANTES ===
  static const EdgeInsets _dialogSpacing = EdgeInsets.only(top: 8);
  static const double _warningIconSize = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header com endereço
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.situacao.color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: item.situacao.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.enderecoDescricao ?? 'Endereço não definido',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: item.situacao.color,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: item.situacao.color, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getSituationIcon(item.situacao), color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            item.situacao.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Removido o botão pequeno - agora temos o botão principal na parte inferior
                  ],
                ),
              ],
            ),
          ),

          // Conteúdo do produto
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do produto
                Text(item.nomeProduto, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Informações do produto
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        context,
                        icon: Icons.inventory_2,
                        label: 'Quantidade',
                        value: '${item.quantidade.toStringAsFixed(2)} ${item.codUnidadeMedida}',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        context,
                        icon: Icons.warehouse,
                        label: 'Setor',
                        value: item.nomeSetorEstoque ?? 'N/A',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Informações de separação
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Separado por: ${item.nomeSeparador}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            _formatDateTime(item.dataSeparacao, item.horaSeparacao),
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Códigos de barras (se existirem)
                if (item.codigoBarras != null && item.codigoBarras!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.qr_code, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.codigoBarras!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Botão de cancelamento na parte inferior
          if (item.situacao == ExpeditionItemSituation.separado && viewModel != null && viewModel!.canCancelItems)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: CustomFlatButtonVariations.outlined(
                text: 'Excluir Item',
                onPressed: (viewModel!.isItemBeingCancelled(item.item) || !viewModel!.isCartInSeparationStatus)
                    ? null
                    : () => _showDeleteDialog(context),
                isLoading: viewModel!.isItemBeingCancelled(item.item),
                textColor: viewModel!.isCartInSeparationStatus ? theme.colorScheme.error : Colors.grey,
                borderColor: viewModel!.isCartInSeparationStatus ? theme.colorScheme.error : Colors.grey,
                icon: Icons.delete_outline,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date, String time) {
    final dateFormat = intl.DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormat.format(date);
    return '$formattedDate às $time';
  }

  IconData _getSituationIcon(ExpeditionItemSituation situation) {
    switch (situation) {
      case ExpeditionItemSituation.separado:
        return Icons.check;
      case ExpeditionItemSituation.cancelado:
        return Icons.cancel;
      case ExpeditionItemSituation.pendente:
        return Icons.pending;
      case ExpeditionItemSituation.conferido:
        return Icons.verified;
      case ExpeditionItemSituation.embalado:
        return Icons.inventory;
      case ExpeditionItemSituation.entregue:
        return Icons.local_shipping;
      case ExpeditionItemSituation.expedido:
        return Icons.send;
      case ExpeditionItemSituation.pausado:
        return Icons.pause;
      case ExpeditionItemSituation.reiniciado:
        return Icons.refresh;
      case ExpeditionItemSituation.finalizado:
        return Icons.done_all;
      case ExpeditionItemSituation.armazenar:
        return Icons.warehouse;
      case ExpeditionItemSituation.vazio:
        return Icons.remove_circle_outline;
    }
  }

  /// Mostra diálogo de confirmação de exclusão
  void _showDeleteDialog(BuildContext context) {
    if (viewModel == null) return;

    showDialog(context: context, builder: (context) => _buildDeleteDialog(context));
  }

  /// Constrói o diálogo de exclusão
  Widget _buildDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: _buildDialogTitle(context, colorScheme),
      content: _buildDialogContent(context, theme),
      actions: _buildDialogActions(context, colorScheme),
    );
  }

  /// Constrói o título do diálogo
  Widget _buildDialogTitle(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.warning, color: colorScheme.error, size: _warningIconSize),
        const SizedBox(width: 8),
        const Text('Excluir Item'),
      ],
    );
  }

  /// Constrói o conteúdo do diálogo
  Widget _buildDialogContent(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deseja realmente excluir este item?'),
        Padding(
          padding: _dialogSpacing,
          child: Text(
            'Esta ação não pode ser desfeita.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: _dialogSpacing,
          child: Text(
            'Produto: ${item.nomeProduto}',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          'Quantidade: ${item.quantidade.toStringAsFixed(2)} ${item.codUnidadeMedida}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Constrói as ações do diálogo
  List<Widget> _buildDialogActions(BuildContext context, ColorScheme colorScheme) {
    return [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Não')),
      FilledButton.tonal(
        onPressed: () => _handleDeleteConfirmation(context),
        style: FilledButton.styleFrom(backgroundColor: colorScheme.errorContainer, foregroundColor: colorScheme.error),
        child: const Text('Sim, Excluir'),
      ),
    ];
  }

  /// Manipula a confirmação de exclusão
  Future<void> _handleDeleteConfirmation(BuildContext context) async {
    Navigator.of(context).pop();

    final success = await viewModel!.deleteItem(item);

    if (!context.mounted) return;

    if (success) {
      _showSuccessMessage(context);
    } else {
      _showErrorMessage(context);
    }
  }

  /// Mostra mensagem de sucesso
  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item excluído com sucesso!'), backgroundColor: Colors.green));
  }

  /// Mostra mensagem de erro
  void _showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(viewModel!.errorMessage ?? 'Erro ao excluir item'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
