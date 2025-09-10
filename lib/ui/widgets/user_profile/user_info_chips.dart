import 'package:flutter/material.dart';
import 'package:exp/domain/models/user/app_user.dart';

class UserInfoChips extends StatelessWidget {
  final AppUser user;

  const UserInfoChips({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fontSize = 11.0;
    final sizeIcon = 15.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: sizeIcon,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ID: ${user.codLoginApp}',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        if (user.codUsuario != null)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.badge,
                        size: sizeIcon,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Código: ${user.codUsuario}',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
