import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_scan_state.dart';

/// Card de scanner de código de barras otimizado com Provider
///
/// Este widget usa Consumer do Provider para atualizar APENAS o scanner
/// quando o estado muda, evitando rebuilds desnecessários de outros componentes.
class BarcodeScannerCardOptimized extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onToggleKeyboard;
  final ValueChanged<String> onSubmitted;
  // Habilitação agora é lida do Provider (PickingScanState.enabled)

  const BarcodeScannerCardOptimized({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onToggleKeyboard,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEnabled = context.select<PickingScanState, bool>((s) => s.enabled);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? colorScheme.primary.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, colorScheme, isEnabled),
          const SizedBox(height: 6),
          // 🚀 CONSUMER ESPECÍFICO - Atualiza APENAS o campo do scanner
          Consumer<PickingScanState>(
            builder: (context, scanState, child) {
              return _buildScannerField(
                theme,
                colorScheme,
                isEnabled,
                scanState.keyboardEnabled,
                scanState.isProcessingScan,
              );
            },
          ),
          const SizedBox(height: 6),
          // 🚀 CONSUMER ESPECÍFICO - Atualiza APENAS o texto de ajuda
          Consumer<PickingScanState>(
            builder: (context, scanState, child) {
              return _buildHelpText(
                theme,
                colorScheme,
                isEnabled,
                scanState.keyboardEnabled,
                scanState.isProcessingScan,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, bool isEnabled) {
    return Row(
      children: [
        Icon(Icons.qr_code_scanner, color: isEnabled ? colorScheme.primary : Colors.grey, size: 20),
        const SizedBox(width: 6),
        Text(
          'Escaneie o código de barras',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isEnabled ? colorScheme.primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildScannerField(
    ThemeData theme,
    ColorScheme colorScheme,
    bool enabled,
    bool keyboardEnabled,
    bool isProcessing,
  ) {
    // 🔒 Bloquear campo quando estiver processando
    final isFieldEnabled = enabled && !isProcessing;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: isFieldEnabled,
      onSubmitted: isFieldEnabled ? onSubmitted : null,
      // Permitir entrada do scanner embutido sempre, mas controlar seleção interativa
      enableInteractiveSelection: isFieldEnabled && keyboardEnabled,
      // Permitir teclado no modo manual, suprimir apenas no modo scanner
      keyboardType: isFieldEnabled && keyboardEnabled
          ? TextInputType.numberWithOptions(decimal: false)
          : TextInputType.none,
      inputFormatters: isFieldEnabled && keyboardEnabled ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        hintText: isProcessing
            ? 'Processando...'
            : (enabled
                  ? (keyboardEnabled ? 'Digite o código de barras' : 'Aguardando scanner')
                  : 'Scanner desabilitado'),
        prefixIcon: isProcessing
            ? SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
              )
            : (enabled
                  ? IconButton(
                      onPressed: onToggleKeyboard,
                      icon: Icon(keyboardEnabled ? Icons.qr_code_scanner : Icons.keyboard, color: colorScheme.primary),
                      tooltip: keyboardEnabled ? 'Usar Scanner' : 'Usar Teclado',
                    )
                  : Icon(Icons.qr_code, color: Colors.grey)),
        suffixIcon: isProcessing
            ? null
            : (enabled
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                        focusNode.requestFocus();
                      },
                      icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                    )
                  : null),
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
        fillColor: enabled ? null : Colors.grey.withValues(alpha: 0.1),
        filled: !enabled,
      ),
      style: TextStyle(color: enabled ? null : Colors.grey),
    );
  }

  Widget _buildHelpText(
    ThemeData theme,
    ColorScheme colorScheme,
    bool enabled,
    bool keyboardEnabled,
    bool isProcessing,
  ) {
    return Text(
      isProcessing
          ? 'Aguarde, processando item...'
          : (enabled
                ? (keyboardEnabled
                      ? 'Digite o código de barras manualmente ou toque no ícone para usar o scanner'
                      : 'Posicione o produto no scanner ou toque no ícone para usar o teclado')
                : 'Scanner desabilitado - carrinho não está em situação de separação'),
      style: theme.textTheme.bodySmall?.copyWith(
        color: isProcessing ? colorScheme.primary : (enabled ? colorScheme.onSurfaceVariant : Colors.grey),
      ),
    );
  }
}
