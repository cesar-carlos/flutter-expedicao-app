import 'dart:async';

import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/theme/app_text_styles.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';

class PickingItemCard extends StatelessWidget {
  final SeparateItemConsultationModel item;
  final CardPickingViewModel viewModel;
  final VoidCallback onPick;

  const PickingItemCard({super.key, required this.item, required this.viewModel, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final itemId = item.item;
    final isCompleted = viewModel.isItemCompleted(itemId);
    final statusColor = isCompleted ? AppColors.success : colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: statusColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.4), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [statusColor.withValues(alpha: 0.05), statusColor.withValues(alpha: 0.02)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationHeader(context, theme, colorScheme),

            const SizedBox(height: 16),

            _buildProductInfo(context, theme, colorScheme),

            const SizedBox(height: 16),

            _buildBarcodeAndBatch(context, theme, colorScheme),

            const SizedBox(height: 16),

            _buildQuantityAndActions(context, theme, colorScheme, statusColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final locationColor = theme.adaptiveSecondaryColor(colorScheme);
    final productCodeColor = theme.adaptiveSecondary(colorScheme);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: locationColor, size: 20),
          const SizedBox(width: 8),
          Text(
            item.enderecoDescricao ?? 'Localização não definida',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: locationColor),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.codProduto.toString(),
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: productCodeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produto',
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(item.nomeProduto, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBarcodeAndBatch(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final sectorColor = theme.isDark ? AppColors.orange700 : AppColors.orange800;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Código de Barras', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Text(
                  item.codigoBarras ?? 'Não informado',
                  style: AppTextStyles.code(
                    context,
                  ).copyWith(fontSize: theme.textTheme.bodyMedium?.fontSize, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Setor', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.nomeSetorEstoque ?? 'N/A',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: sectorColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityAndActions(BuildContext context, ThemeData theme, ColorScheme colorScheme, Color statusColor) {
    final itemId = item.item;
    final isCompleted = viewModel.isItemCompleted(itemId);
    final pickedQuantity = viewModel.getPickedQuantity(itemId);
    final totalQuantity = item.quantidade.toInt();
    final unidade = item.nomeUnidadeMedida;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantidade a Separar',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalQuantity $unidade',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Separado', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.2)
                          : statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$pickedQuantity/$totalQuantity',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? AppColors.green700 : statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              if (!isCompleted) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Separar'),
                    style: ElevatedButton.styleFrom(backgroundColor: statusColor, foregroundColor: AppColors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showQuantityDialog(context, itemId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(48, 36),
                  ),
                  child: const Icon(Icons.edit, size: 18),
                ),
              ] else ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.green700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Item Completado',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.green700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, String itemId) {
    final totalQuantity = item.quantidade.toInt();
    final currentQuantity = viewModel.getPickedQuantity(itemId);
    int newQuantity = currentQuantity;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (statefulContext, setState) => AlertDialog(
          title: const Text('Ajustar Quantidade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Quantidade a separar: $totalQuantity'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: newQuantity > 0 ? () => setState(() => newQuantity--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$newQuantity',
                      style: AppFonts.inter(fontSize: UIConstants.largeFontSize, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: newQuantity < totalQuantity ? () => setState(() => newQuantity++) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(statefulContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                unawaited(
                  _confirmQuantityChange(statefulContext, itemId, newQuantity).catchError((Object e, StackTrace s) {
                    AppLogger.warning(
                      'Falha ao confirmar quantidade no picking',
                      tag: 'PickingItemCard',
                      error: e,
                      stackTrace: s,
                    );
                  }),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog de quantidade',
          tag: 'PickingItemCard',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  Future<void> _confirmQuantityChange(BuildContext context, String itemId, int newQuantity) async {
    final result = await viewModel.updatePickedQuantityWithSync(itemId, newQuantity);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    final message = result.isSuccess ? result.message : result.message;
    final color = result.isSuccess ? AppColors.success : AppColors.error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: UIConstants.snackBarShortDuration),
    );
  }
}
