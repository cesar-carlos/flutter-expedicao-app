import 'package:flutter/material.dart';
import 'package:exp/core/theme/app_colors.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryWithOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.secondary),
                const SizedBox(width: 12),
                Text(
                  'Vincular Usuário do Sistema',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Seu login não possui um usuário do sistema vinculado. '
              'Busque e selecione seu usuário para continuar usando o aplicativo.',
              style: TextStyle(fontSize: 14, color: AppColors.fontDark),
            ),
          ],
        ),
      ),
    );
  }
}
