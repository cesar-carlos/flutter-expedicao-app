import 'package:flutter/material.dart';

class BarcodeScannerCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool keyboardEnabled;
  final VoidCallback onToggleKeyboard;
  final ValueChanged<String> onSubmitted;
  final bool enabled;

  const BarcodeScannerCard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.keyboardEnabled,
    required this.onToggleKeyboard,
    required this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? colorScheme.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, colorScheme),
          const SizedBox(height: 6),
          _buildScannerField(theme, colorScheme),
          const SizedBox(height: 6),
          _buildHelpText(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.qr_code_scanner, color: enabled ? colorScheme.primary : Colors.grey, size: 20),
        const SizedBox(width: 6),
        Text(
          'Escaneie o código de barras',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: enabled ? colorScheme.primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildScannerField(ThemeData theme, ColorScheme colorScheme) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      onSubmitted: enabled ? onSubmitted : null,
      decoration: InputDecoration(
        hintText: enabled
            ? (keyboardEnabled ? 'Digite o código de barras' : 'Aguardando scanner')
            : 'Scanner desabilitado',
        prefixIcon: enabled
            ? IconButton(
                onPressed: onToggleKeyboard,
                icon: Icon(keyboardEnabled ? Icons.qr_code_scanner : Icons.keyboard, color: colorScheme.primary),
                tooltip: keyboardEnabled ? 'Usar Scanner' : 'Usar Teclado',
              )
            : Icon(Icons.qr_code, color: Colors.grey),
        suffixIcon: enabled
            ? IconButton(
                onPressed: () {
                  controller.clear();
                  focusNode.requestFocus();
                },
                icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: enabled ? colorScheme.outline : Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: enabled ? colorScheme.outline : Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: enabled ? colorScheme.primary : Colors.grey, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        fillColor: enabled ? null : Colors.grey.withOpacity(0.1),
        filled: !enabled,
      ),
      style: TextStyle(color: enabled ? null : Colors.grey),
    );
  }

  Widget _buildHelpText(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      enabled
          ? (keyboardEnabled
                ? 'Digite o código de barras manualmente ou toque no ícone para usar o scanner'
                : 'Posicione o produto no scanner ou toque no ícone para usar o teclado')
          : 'Scanner desabilitado - carrinho não está em situação de separação',
      style: theme.textTheme.bodySmall?.copyWith(color: enabled ? colorScheme.onSurfaceVariant : Colors.grey),
    );
  }
}
