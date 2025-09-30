import 'package:flutter/material.dart';

import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';

class PickingProductListItem extends StatelessWidget {
  final SeparateItemConsultationModel item;
  final CardPickingViewModel viewModel;
  final bool isCompleted;
  final bool allowEdit;

  const PickingProductListItem({
    super.key,
    required this.item,
    required this.viewModel,
    required this.isCompleted,
    this.allowEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = isCompleted ? Colors.green : Colors.orange;
    final pickedQuantity = viewModel.getPickedQuantity(item.item);
    final totalQuantity = item.quantidade.toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: statusColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [statusColor.withOpacity(0.05), statusColor.withOpacity(0.02)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com endereço e status
            _buildHeader(context, theme, colorScheme, statusColor),

            const SizedBox(height: 12),

            // Informações do produto
            _buildProductInfo(context, theme, colorScheme),

            const SizedBox(height: 12),

            // Quantidades e ações
            _buildQuantityAndActions(context, theme, colorScheme, statusColor, pickedQuantity, totalQuantity),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme, Color statusColor) {
    return Row(
      children: [
        // Ícone de status
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(isCompleted ? Icons.check_circle : Icons.pending_actions, color: statusColor, size: 20),
        ),

        const SizedBox(width: 12),

        // Endereço
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Endereço',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                item.enderecoDescricao ?? 'Não informado',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: statusColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
          child: Text(
            isCompleted ? 'Separado' : 'Pendente',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome do produto
        Text(
          'Produto',
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          item.nomeProduto,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Informações adicionais
        Row(
          children: [
            // Código do produto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Código',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text('${item.codProduto}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            // Setor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setor',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    item.nomeSetorEstoque ?? 'Não informado',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Unidade
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unidade',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(item.codUnidadeMedida, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityAndActions(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Color statusColor,
    int pickedQuantity,
    int totalQuantity,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Quantidades
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantidades',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Separado: ',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      '$pickedQuantity',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: statusColor),
                    ),
                    Text(
                      ' / $totalQuantity ${item.codUnidadeMedida}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ações (apenas para produtos separados)
          if (allowEdit && isCompleted) ...[
            const SizedBox(width: 12),
            Column(
              children: [
                IconButton(
                  onPressed: () => _showEditQuantityDialog(context),
                  icon: const Icon(Icons.edit),
                  iconSize: 20,
                  tooltip: 'Editar quantidade',
                  style: IconButton.styleFrom(
                    backgroundColor: statusColor.withOpacity(0.1),
                    foregroundColor: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: () => _showDeleteDialog(context),
                  icon: const Icon(Icons.delete),
                  iconSize: 20,
                  tooltip: 'Remover separação',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showEditQuantityDialog(BuildContext context) {
    final controller = TextEditingController(text: viewModel.getPickedQuantity(item.item).toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Quantidade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produto: ${item.nomeProduto}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade separada',
                suffixText: item.codUnidadeMedida,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final newQuantity = int.tryParse(controller.text) ?? 0;
              if (newQuantity >= 0 && newQuantity <= item.quantidade.toInt()) {
                viewModel.updatePickedQuantity(item.item, newQuantity);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Quantidade atualizada para $newQuantity ${item.codUnidadeMedida}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Quantidade inválida'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Separação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja remover a separação deste produto?'),
            const SizedBox(height: 8),
            Text('Produto: ${item.nomeProduto}'),
            Text('Quantidade separada: ${viewModel.getPickedQuantity(item.item)} ${item.codUnidadeMedida}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              viewModel.updatePickedQuantity(item.item, 0);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Separação removida'), backgroundColor: Colors.orange));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
