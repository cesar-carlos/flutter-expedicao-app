import 'package:flutter/material.dart';

class DrawerMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool isPlaceholder;
  final bool showNotification;

  const DrawerMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.isPlaceholder = false,
    this.showNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color:
            iconColor ??
            (isPlaceholder ? theme.colorScheme.onSurfaceVariant.withOpacity(0.6) : theme.colorScheme.onSurfaceVariant),
      ),
      title: Text(
        title,
        style: TextStyle(
          color:
              textColor ??
              (isPlaceholder ? theme.colorScheme.onSurfaceVariant.withOpacity(0.6) : theme.colorScheme.onSurface),
          fontSize: 16,
        ),
      ),
      trailing: showNotification
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
            )
          : null,
      onTap: isPlaceholder ? null : onTap,
      enabled: !isPlaceholder,
    );
  }
}
