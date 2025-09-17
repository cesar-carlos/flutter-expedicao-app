import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:exp/domain/viewmodels/home_viewmodel.dart';

/// Card de menu para a tela inicial
class HomeMenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color? iconColor;
  final Color? cardColor;

  const HomeMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.iconColor,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          // Notifica o ViewModel sobre a navegação
          final homeViewModel = context.read<HomeViewModel>();
          homeViewModel.navigateToFunctionality(title);

          // Navega para a rota
          context.go(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
            gradient: cardColor != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cardColor!.withOpacity(0.1), cardColor!.withOpacity(0.05)],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: iconColor?.withOpacity(0.1) ?? theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(27.5),
                ),
                child: Icon(icon, size: 28, color: iconColor ?? theme.colorScheme.primary),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
