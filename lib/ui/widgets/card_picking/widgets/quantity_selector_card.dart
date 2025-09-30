import 'package:flutter/material.dart';

class QuantitySelectorCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const QuantitySelectorCard({super.key, required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
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
        Icon(Icons.inventory, color: Colors.orange, size: 20),
        const SizedBox(width: 8),
        Text(
          'Quantidade a Separar',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
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
      onPressed: () {
        final currentValue = int.tryParse(controller.text) ?? 1;
        if (currentValue > 1) {
          controller.text = (currentValue - 1).toString();
        }
      },
      icon: Icon(Icons.remove, color: Colors.orange),
      style: IconButton.styleFrom(backgroundColor: Colors.orange.withOpacity(0.1), shape: CircleBorder()),
    );
  }

  Widget _buildIncrementButton() {
    return IconButton(
      onPressed: () {
        final currentValue = int.tryParse(controller.text) ?? 1;
        controller.text = (currentValue + 1).toString();
      },
      icon: Icon(Icons.add, color: Colors.orange),
      style: IconButton.styleFrom(backgroundColor: Colors.orange.withOpacity(0.1), shape: CircleBorder()),
    );
  }

  Widget _buildQuantityField(ColorScheme colorScheme) {
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: '1',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.orange, width: 2),
          ),
          filled: true,
          fillColor: Colors.orange.withOpacity(0.05),
        ),
        onChanged: (value) {
          // Validar que seja um número positivo
          final intValue = int.tryParse(value);
          if (intValue == null || intValue < 1) {
            controller.text = '1';
            controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
          }
        },
      ),
    );
  }

  Widget _buildHelpText(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      'Defina a quantidade que será separada quando escanear o produto',
      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}
