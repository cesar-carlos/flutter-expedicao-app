import 'package:flutter/material.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class PickingDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget content;
  final List<Widget>? actions;
  final bool showCloseButton;

  const PickingDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.content,
    this.actions,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
          ],
          content,
        ],
      ),
      actions:
          actions ??
          [if (showCloseButton) TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
    );
  }
}

class PickingDialogs {
  static Widget wrongProduct({
    required String scannedBarcode,
    required String expectedAddress,
    required String expectedProduct,
    String? expectedBarcode,
  }) {
    return PickingDialog(
      title: 'Produto Incorreto',
      icon: Icons.warning,
      iconColor: AppColors.warning,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Código escaneado: $scannedBarcode'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próximo produto esperado:',
                  style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.blue700),
                ),
                const SizedBox(height: 6),
                Text('📍 $expectedAddress'),
                Text('📦 $expectedProduct'),
                if (expectedBarcode != null) Text('🏷️ $expectedBarcode'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Escaneie o produto correto da sequência de separação.'),
        ],
      ),
    );
  }

  static Widget addItemError({required String barcode, required String productName, required String errorMessage}) {
    return PickingDialog(
      title: 'Erro ao Adicionar',
      icon: Icons.error,
      iconColor: AppColors.error,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Código: $barcode', style: AppFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Produto: $productName'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Text(errorMessage, style: AppFonts.inter(color: AppColors.red700)),
          ),
        ],
      ),
    );
  }

  static Widget quantityExceeded({
    required String barcode,
    required String productName,
    required int requestedQuantity,
    required int availableQuantity,
  }) {
    return PickingDialog(
      title: 'Quantidade Excedida',
      icon: Icons.warning,
      iconColor: AppColors.warning,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Código: $barcode', style: AppFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Produto: $productName'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantidade solicitada excede o disponível:',
                  style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.orange700),
                ),
                const SizedBox(height: 6),
                Text('Solicitado: $requestedQuantity'),
                Text('Disponível: $availableQuantity', style: AppFonts.inter(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Ajuste a quantidade para não exceder o máximo permitido.'),
        ],
      ),
    );
  }

  static Widget wrongSector({
    required String scannedBarcode,
    required String productName,
    required String productSector,
    required int userSectorCode,
  }) {
    return PickingDialog(
      title: 'Setor Incorreto',
      icon: Icons.block,
      iconColor: AppColors.error,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Código escaneado: $scannedBarcode'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produto de outro setor:',
                  style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.red700),
                ),
                const SizedBox(height: 6),
                Text('📦 $productName'),
                Text('🏢 $productSector'),
                const SizedBox(height: 8),
                Text(
                  'Seu setor: Setor $userSectorCode',
                  style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.blue700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Você só pode separar produtos do seu setor ou produtos sem setor definido.'),
        ],
      ),
    );
  }

  static Widget noItemsForSector({
    required int userSectorCode,
    required VoidCallback onFinish,
    required VoidCallback onCancel,
  }) {
    return PickingDialog(
      title: 'Separação Finalizada',
      icon: Icons.info_outline,
      iconColor: AppColors.info,
      showCloseButton: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✓ Todos os itens do seu setor foram separados!',
                  style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.blue700),
                ),
                const SizedBox(height: 8),
                Text('Seu setor: Setor $userSectorCode', style: AppFonts.inter(color: AppColors.blue600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Não há mais produtos do seu setor neste carrinho para separar.'),
          const SizedBox(height: 8),
          Text(
            'Os itens restantes pertencem a outros setores e serão separados por outros usuários.',
            style: AppFonts.inter(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Continuar Escaneando')),
        ElevatedButton.icon(
          onPressed: onFinish,
          icon: const Icon(Icons.check),
          label: const Text('Finalizar Separação'),
        ),
      ],
    );
  }

  static Widget separationComplete() {
    return PickingDialog(
      title: 'Separação Completa!',
      icon: Icons.check_circle,
      iconColor: AppColors.success,
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎉 Parabéns! Todos os itens foram separados com sucesso.'),
          SizedBox(height: 12),
          Text('Você pode:'),
          Text('• Revisar os itens separados no menu'),
          Text('• Finalizar a separação'),
        ],
      ),
    );
  }

  static Widget loading({String message = 'Processando...'}) {
    return PickingDialog(
      title: message,
      icon: Icons.hourglass_empty,
      iconColor: AppColors.info,
      showCloseButton: false,
      content: const Center(
        child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
      ),
    );
  }
}
