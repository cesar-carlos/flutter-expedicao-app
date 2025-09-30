import 'package:flutter/material.dart';

import 'package:exp/ui/widgets/card_picking/widgets/connection_status_indicator.dart';

class BarcodeScannerCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool keyboardEnabled;
  final VoidCallback onToggleKeyboard;
  final ValueChanged<String> onSubmitted;

  const BarcodeScannerCard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.keyboardEnabled,
    required this.onToggleKeyboard,
    required this.onSubmitted,
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
        border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 2),
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
        Icon(Icons.barcode_reader, color: colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          'Escaneie o código de barras',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
        ),
        const Spacer(),
        const ConnectionStatusIndicator(),
      ],
    );
  }

  Widget _buildScannerField(ThemeData theme, ColorScheme colorScheme) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      // Remover readOnly para permitir que o scanner físico insira dados
      // readOnly: !keyboardEnabled,
      keyboardType: keyboardEnabled ? TextInputType.number : TextInputType.none,
      // Desabilitar o teclado virtual quando não estiver em modo teclado
      enableInteractiveSelection: keyboardEnabled,
      showCursor: true, // Sempre mostrar cursor para indicar que está ativo
      decoration: InputDecoration(
        hintText: keyboardEnabled ? 'Digite o código...' : 'Aguardando scanner',
        prefixIcon: IconButton(
          icon: Icon(keyboardEnabled ? Icons.keyboard : Icons.qr_code_scanner, color: colorScheme.primary),
          onPressed: onToggleKeyboard,
          tooltip: keyboardEnabled ? 'Usar scanner' : 'Usar teclado',
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
          onPressed: () {
            controller.clear();
            focusNode.requestFocus();
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildHelpText(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      keyboardEnabled
          ? 'Digite o código de barras e pressione Enter'
          : 'Posicione o produto no scanner ou toque no ícone para usar o teclado',
      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}
