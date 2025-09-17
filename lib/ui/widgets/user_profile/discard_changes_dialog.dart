import 'package:flutter/material.dart';

import 'package:exp/core/theme/app_colors.dart';

class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(context: context, builder: (context) => const DiscardChangesDialog());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
          const SizedBox(width: 12),
          const Text('Descartar Alterações?'),
        ],
      ),
      content: const Text('Você possui alterações não salvas. Deseja descartar essas alterações e voltar?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancelar', style: TextStyle(color: theme.colorScheme.primary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning, foregroundColor: AppColors.white),
          child: const Text('Descartar'),
        ),
      ],
    );
  }
}
