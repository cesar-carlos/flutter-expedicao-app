import 'package:flutter/material.dart';

import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'editable_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileViewModel viewModel;

  const ProfileHeader({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final user = viewModel.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header principal com avatar e nome
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.15),
                  colorScheme.primary.withOpacity(0.08),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Avatar com anel de status
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: user.isActive
                              ? [Colors.green.shade400, Colors.green.shade600]
                              : [Colors.grey.shade400, Colors.grey.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: EditableAvatar(viewModel: viewModel),
                    ),
                    // Badge de status
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: user.isActive ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          user.isActive ? Icons.check : Icons.close,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Nome do usuário
                Text(
                  user.nome.toUpperCase(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Cargo/Função (se disponível)
                if (user.userSystemModel?.nomeContaFinanceira != null)
                  Text(
                    user.userSystemModel!.nomeContaFinanceira!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 16),

                // IDs profissionais
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIdChip(
                      context,
                      'ID',
                      '${user.codLoginApp}',
                      Icons.badge,
                      colorScheme,
                    ),
                    if (user.codUsuario != null) ...[
                      const SizedBox(width: 12),
                      _buildIdChip(
                        context,
                        'CÓDIGO',
                        '${user.codUsuario}',
                        Icons.person,
                        colorScheme,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
