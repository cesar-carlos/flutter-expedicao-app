import 'package:flutter/material.dart';

import 'package:exp/ui/widgets/common/adaptive_logo.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double logoSize;
  final double spacing;

  const AppHeader({super.key, required this.title, required this.subtitle, this.logoSize = 230, this.spacing = 24});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AdaptiveLogoContainer(
          width: logoSize,
          height: logoSize,
          borderRadius: 16,
          showShadow: false,
          padding: const EdgeInsets.all(0),
        ),

        SizedBox(height: spacing),

        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
