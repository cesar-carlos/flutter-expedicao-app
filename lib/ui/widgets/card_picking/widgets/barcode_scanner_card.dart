import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';

class BarcodeScannerCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool keyboardEnabled;
  final VoidCallback onToggleKeyboard;
  final ValueChanged<String> onSubmitted;
  final bool enabled;
  final bool isProcessing;

  const BarcodeScannerCard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.keyboardEnabled,
    required this.onToggleKeyboard,
    required this.onSubmitted,
    this.enabled = true,
    this.isProcessing = false,
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
          color: enabled ? colorScheme.primary.withValues(alpha: 0.3) : AppColors.grey.withValues(alpha: 0.3),
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
    final headerColor = enabled 
        ? theme.adaptivePrimary(colorScheme)
        : AppColors.grey;

    return Row(
      children: [
        Icon(Icons.qr_code_scanner, color: headerColor, size: 20),
        const SizedBox(width: 6),
        Text(
          'Escaneie o código de barras',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: headerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildScannerField(ThemeData theme, ColorScheme colorScheme) {
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
                      icon: Icon(
                        keyboardEnabled ? Icons.qr_code_scanner : Icons.keyboard,
                        color: theme.adaptivePrimary(colorScheme),
                      ),
                      tooltip: keyboardEnabled ? 'Usar Scanner' : 'Usar Teclado',
                    )
                  : Icon(Icons.qr_code, color: AppColors.grey)),
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
          borderSide: BorderSide(color: enabled ? colorScheme.outline : AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: enabled ? colorScheme.outline : AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: enabled ? colorScheme.primary : AppColors.grey, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        fillColor: enabled ? null : AppColors.grey.withValues(alpha: 0.1),
        filled: !enabled,
      ),
      style: AppFonts.inter(color: enabled ? null : AppColors.grey),
    );
  }

  Widget _buildHelpText(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      isProcessing
          ? 'Aguarde, processando item...'
          : (enabled
                ? (keyboardEnabled
                      ? 'Digite o código de barras manualmente ou toque no ícone para usar o scanner'
                      : 'Posicione o produto no scanner ou toque no ícone para usar o teclado')
                : 'Scanner desabilitado - carrinho não está em situação de separação'),
      style: theme.textTheme.bodySmall?.copyWith(
        color: isProcessing ? colorScheme.primary : (enabled ? colorScheme.onSurfaceVariant : AppColors.grey),
      ),
    );
  }
}
