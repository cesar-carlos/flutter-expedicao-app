import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantitySelectorCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;

  const QuantitySelectorCard({super.key, required this.controller, required this.focusNode, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: enabled ? Colors.orange.withOpacity(0.3) : Colors.grey.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 6),
          _buildQuantityRow(theme, colorScheme),
          const SizedBox(height: 6),
          _buildHelpText(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.inventory_2, color: enabled ? Colors.orange : Colors.grey, size: 20),
        const SizedBox(width: 6),
        Text(
          'Quantidade a Separar',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: enabled ? Colors.orange : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildDecrementButton(),
        const SizedBox(width: 8),
        _buildQuantityField(colorScheme),
        const SizedBox(width: 8),
        _buildIncrementButton(),
      ],
    );
  }

  Widget _buildDecrementButton() {
    return IconButton(
      onPressed: enabled
          ? () {
              final currentValue = int.tryParse(controller.text) ?? 1;
              if (currentValue > 1) {
                controller.text = (currentValue - 1).toString();
              }
            }
          : null,
      icon: Icon(Icons.remove, color: enabled ? Colors.orange : Colors.grey),
      style: IconButton.styleFrom(
        backgroundColor: enabled ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildIncrementButton() {
    return IconButton(
      onPressed: enabled
          ? () {
              final currentValue = int.tryParse(controller.text) ?? 1;
              if (currentValue < 999) {
                controller.text = (currentValue + 1).toString();
              }
            }
          : null,
      icon: Icon(Icons.add, color: enabled ? Colors.orange : Colors.grey),
      style: IconButton.styleFrom(
        backgroundColor: enabled ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildQuantityField(ColorScheme colorScheme) {
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: enabled ? Colors.orange : Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: enabled ? Colors.orange : Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: enabled ? Colors.orange : Colors.grey, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          fillColor: enabled ? null : Colors.grey.withOpacity(0.1),
          filled: !enabled,
        ),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: enabled ? null : Colors.grey),
      ),
    );
  }

  Widget _buildHelpText(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      'Defina a quantidade que será separada quando escanear o produto (máximo: 999)',
      style: theme.textTheme.bodySmall?.copyWith(color: enabled ? colorScheme.onSurfaceVariant : Colors.grey),
    );
  }
}
