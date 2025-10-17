import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/viewmodels/separation_items_viewmodel.dart';

class SeparateItemsErrorState extends StatelessWidget {
  final SeparationItemsViewModel viewModel;
  final VoidCallback onRefresh;

  const SeparateItemsErrorState({super.key, required this.viewModel, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar itens',
              style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Ocorreu um erro inesperado',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
