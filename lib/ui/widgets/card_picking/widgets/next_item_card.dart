import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/picking_state.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/widgets/product_detail_item.dart';

class NextItemCard extends StatelessWidget {
  final SeparateItemConsultationModel? nextItem;
  final int completedCount;
  final int totalCount;
  final int? userSectorCode;
  final int pickedQuantity;
  final PickingItemState? itemState;
  final bool hasItemsForUserSector;

  const NextItemCard({
    super.key,
    required this.nextItem,
    required this.completedCount,
    required this.totalCount,
    required this.userSectorCode,
    required this.pickedQuantity,
    required this.itemState,
    required this.hasItemsForUserSector,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, colorScheme, completedCount, totalCount),
          const SizedBox(height: 4),
          if (nextItem != null) ...[
            _buildNextItemContent(theme, colorScheme, nextItem!),
          ] else ...[
            _buildCompletionMessage(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, int completedCount, int totalCount) {
    return Row(
      children: [
        Icon(Icons.my_location, color: colorScheme.primary, size: 20),
        const SizedBox(width: 6),
        Text(
          'Próximo Item',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: completedCount == totalCount
                ? Colors.green.withValues(alpha: 0.2)
                : colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$completedCount/$totalCount',
            style: theme.textTheme.bodySmall?.copyWith(
              color: completedCount == totalCount ? Colors.green.shade700 : colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextItemContent(ThemeData theme, ColorScheme colorScheme, SeparateItemConsultationModel nextItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _buildAddressHighlight(theme, colorScheme, nextItem),
        const SizedBox(height: 4),
        _buildProductInfo(theme, colorScheme, nextItem),
        const SizedBox(height: 4),
        _buildProductDetails(theme, colorScheme, nextItem),
        const SizedBox(height: 4),
        if (nextItem.codigoBarras != null && nextItem.codigoBarras!.isNotEmpty)
          _buildBarcodeInfo(theme, colorScheme, nextItem),
      ],
    );
  }

  Widget _buildAddressHighlight(ThemeData theme, ColorScheme colorScheme, SeparateItemConsultationModel nextItem) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              nextItem.enderecoDescricao ?? 'Endereço não definido',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(ThemeData theme, ColorScheme colorScheme, SeparateItemConsultationModel nextItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produto',
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          nextItem.nomeProduto,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProductDetails(ThemeData theme, ColorScheme colorScheme, SeparateItemConsultationModel nextItem) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: ProductDetailItem(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Unidade',
              value: nextItem.codUnidadeMedida,
              icon: Icons.straighten,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 1,
            child: ProductDetailItem(
              theme: theme,
              colorScheme: colorScheme,
              label: 'Quantidade',
              value: '$pickedQuantity/${nextItem.quantidade}',
              icon: Icons.inventory_2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncBadge(PickingItemState? itemState) {
    IconData icon;
    Color color;
    String tooltip;

    if (itemState == null || !itemState.hasPendingSync) {
      // Estado normal: conectado e sincronizado
      icon = Icons.cloud_done;
      color = Colors.green;
      tooltip = 'Conectado';
    } else {
      final pendingOps = itemState.pendingOperations;
      final hasFailed = pendingOps.any((op) => op.status == PendingOperationStatus.failed);
      final isSyncing = pendingOps.any((op) => op.status == PendingOperationStatus.syncing);

      if (hasFailed) {
        icon = Icons.sync_problem;
        color = Colors.red;
        tooltip = 'Erro ao sincronizar';
      } else if (isSyncing) {
        icon = Icons.sync;
        color = Colors.blue;
        tooltip = 'Sincronizando...';
      } else {
        icon = Icons.cloud_upload;
        color = Colors.orange;
        tooltip = 'Aguardando sincronização';
      }
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 1),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _buildBarcodeInfo(ThemeData theme, ColorScheme colorScheme, SeparateItemConsultationModel nextItem) {
    // Se tem múltiplas unidades de medida, mostrar dropdown
    if (nextItem.unidadeMedidas.length > 1) {
      return _buildBarcodeDropdown(theme, colorScheme, nextItem, itemState);
    }

    // Caso contrário, mostrar como antes
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code, color: colorScheme.onSurfaceVariant, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              nextItem.codigoBarras!,
              style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 8),
          _buildSyncBadge(itemState),
        ],
      ),
    );
  }

  Widget _buildBarcodeDropdown(
    ThemeData theme,
    ColorScheme colorScheme,
    SeparateItemConsultationModel nextItem,
    PickingItemState? itemState,
  ) {
    // Encontrar a unidade padrão primeiro
    final unidadePadrao = nextItem.unidadeMedidas.firstWhere(
      (unidade) => unidade.unidadeMedidaPadrao == Situation.ativo,
      orElse: () => nextItem.unidadeMedidas.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code, color: colorScheme.onSurfaceVariant, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SeparateItemUnidadeMedidaConsultationModel>(
                value: unidadePadrao,
                isExpanded: true,
                isDense: true,
                items: nextItem.unidadeMedidas.map((unidade) {
                  return DropdownMenuItem<SeparateItemUnidadeMedidaConsultationModel>(
                    value: unidade,
                    child: _buildDropdownItem(theme, colorScheme, unidade),
                  );
                }).toList(),
                onChanged: (value) {
                  // Por enquanto, não implementamos ação ao trocar o dropdown
                  // Isso pode ser implementado posteriormente se necessário
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildSyncBadge(itemState),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(
    ThemeData theme,
    ColorScheme colorScheme,
    SeparateItemUnidadeMedidaConsultationModel unidade,
  ) {
    final isPadrao = unidade.unidadeMedidaPadrao == Situation.ativo;

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontWeight: isPadrao ? FontWeight.bold : FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
          height: 1.2,
        ),
        children: [
          TextSpan(text: '${unidade.codUnidadeMedida}/${unidade.fatorConversao.toStringAsFixed(0)} '),
          TextSpan(
            text: unidade.codigoBarras ?? '',
            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionMessage(ThemeData theme) {
    if (!hasItemsForUserSector && userSectorCode != null) {
      // Usuário tem setor definido mas não há itens para ele
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 48),
            const SizedBox(height: 6),
            Text(
              'Sem Itens para Separar',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 6),
            Text(
              'Não há itens do seu setor (Setor $userSectorCode) neste carrinho para separar.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Os itens deste carrinho pertencem a outros setores.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Todos os itens foram separados
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 6),
          Text(
            'Separação Concluída!',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade700),
          ),
          const SizedBox(height: 6),
          Text(
            'Todos os itens foram separados com sucesso.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
