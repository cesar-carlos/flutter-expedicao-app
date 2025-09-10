import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final IconData? icon;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const ErrorMessage({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (message.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
