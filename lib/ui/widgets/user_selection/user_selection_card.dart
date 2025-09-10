import 'package:flutter/material.dart';
import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/core/theme/app_colors.dart';

class UserSelectionCard extends StatelessWidget {
  final UserSelectionViewModel viewModel;

  const UserSelectionCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final user = viewModel.selectedUser!;

    return Card(
      color: AppColors.successWithOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 8),
                Text(
                  'Usuário Selecionado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user.nomeUsuario,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Código: ${user.codUsuario}'),
            if (user.nomeContaFinanceira != null)
              Text('Conta: ${user.nomeContaFinanceira}'),
          ],
        ),
      ),
    );
  }
}
