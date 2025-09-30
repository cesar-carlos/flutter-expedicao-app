import 'package:flutter/material.dart';

/// Widget reutilizável para exibir permissões com ícone e status
/// Usado em UserInfoChips para mostrar permissões do usuário
class PermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool hasPermission;

  const PermissionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.hasPermission,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final color = hasPermission ? Colors.green : colorScheme.onSurfaceVariant;
    final backgroundColor = hasPermission
        ? Colors.green.withOpacity(0.1)
        : colorScheme.surfaceContainerHighest.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: hasPermission
            ? [BoxShadow(color: Colors.green.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 4)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(hasPermission ? Icons.check_circle : Icons.cancel, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(color: color.withOpacity(0.8), fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Lista de permissões em grid responsivo
class PermissionsGrid extends StatelessWidget {
  final List<PermissionData> permissions;

  const PermissionsGrid({
    super.key,
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < permissions.length; i += 2) ...[
          Row(
            children: [
              Expanded(
                child: PermissionCard(
                  title: permissions[i].title,
                  description: permissions[i].description,
                  icon: permissions[i].icon,
                  hasPermission: permissions[i].hasPermission,
                ),
              ),
              const SizedBox(width: 12),
              if (i + 1 < permissions.length)
                Expanded(
                  child: PermissionCard(
                    title: permissions[i + 1].title,
                    description: permissions[i + 1].description,
                    icon: permissions[i + 1].icon,
                    hasPermission: permissions[i + 1].hasPermission,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
          if (i + 2 < permissions.length) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Classe de dados para permissões
class PermissionData {
  final String title;
  final String description;
  final IconData icon;
  final bool hasPermission;

  const PermissionData({
    required this.title,
    required this.description,
    required this.icon,
    required this.hasPermission,
  });
}
