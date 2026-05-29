import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';

class PickingListHeader extends StatelessWidget {
  const PickingListHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.itemCount,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: iconColor.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '$itemCount ${itemCount == 1 ? 'produto' : 'produtos'}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: iconColor.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(UIConstants.largeBorderRadius),
            ),
            child: Text(
              '$itemCount',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
