import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';

class PickingErrorView extends StatelessWidget {
  const PickingErrorView({super.key, required this.errorMessage, required this.onRetry});

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.extraLargePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: UIConstants.defaultPadding),
            Text(
              'Erro ao carregar produtos',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: UIConstants.smallPadding),
            Text(
              errorMessage ?? 'Erro desconhecido',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.largePadding),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class PickingEmptyView extends StatelessWidget {
  const PickingEmptyView({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.extraLargePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: iconColor.withValues(alpha: 0.5)),
            const SizedBox(height: UIConstants.defaultPadding),
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: UIConstants.smallPadding),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
