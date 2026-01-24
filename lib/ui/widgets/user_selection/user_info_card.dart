import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.secondary),
                const SizedBox(width: 12),
                Text(
                  'Vincular Usuário do Sistema',
                  style: AppFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Seu login não possui um usuário do sistema vinculado. '
              'Busque e selecione seu usuário para continuar usando o aplicativo.',
              style: AppFonts.inter(
                fontSize: 14,
                color: theme.isDark ? AppColors.light : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
