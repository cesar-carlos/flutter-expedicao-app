import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/constants/app_strings.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';

class FloatingConfigButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? tooltip;
  final EdgeInsets? margin;

  const FloatingConfigButton({super.key, this.onPressed, this.tooltip, this.margin = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: margin?.top ?? 16,
      right: margin?.right ?? 16,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: IconButton(
          onPressed:
              onPressed ??
              () {
                context.go(AppRouter.config);
              },
          icon: const Icon(Icons.settings),
          tooltip: tooltip ?? AppStrings.settingsTooltip,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
            foregroundColor: theme.colorScheme.onSurface,
            side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2), width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
