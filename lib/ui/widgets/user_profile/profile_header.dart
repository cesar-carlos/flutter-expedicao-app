import 'package:flutter/material.dart';

import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'package:exp/domain/models/situation/situation_model.dart';
import 'package:exp/ui/widgets/user_profile/editable_avatar.dart';
import 'package:exp/ui/widgets/user_profile/widgets/index.dart';

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
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header com gradiente sutil
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primaryContainer.withValues(alpha: 0.1), colorScheme.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Avatar com design limpo
                _buildAvatar(user, colorScheme),

                const SizedBox(height: 20),

                // Nome do usuário
                Text(
                  user.nome,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Nome do sistema (se diferente)
                if (user.userSystemModel?.nomeUsuario.isNotEmpty == true &&
                    user.userSystemModel!.nomeUsuario != user.nome) ...[
                  Text(
                    user.userSystemModel!.nomeUsuario,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],

                // Função/Cargo
                if (user.userSystemModel?.nomeContaFinanceira != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      user.userSystemModel!.nomeContaFinanceira!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          // Seção de informações básicas
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // IDs em grid responsivo
                Row(
                  children: [
                    Expanded(
                      child: InfoCard(label: 'ID Login', value: '${user.codLoginApp}', icon: Icons.badge),
                    ),
                    const SizedBox(width: 12),
                    if (user.codUsuario != null)
                      Expanded(
                        child: InfoCard(label: 'Código', value: '${user.codUsuario}', icon: Icons.person),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Status em linha
                Row(
                  children: [
                    Expanded(
                      child: StatusChip(
                        label: 'Login',
                        status: user.ativo == Situation.ativo ? 'Ativo' : 'Inativo',
                        isActive: user.ativo == Situation.ativo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (user.userSystemModel != null)
                      Expanded(
                        child: StatusChip(
                          label: 'Sistema',
                          status: user.userSystemModel!.ativo == Situation.ativo ? 'Ativo' : 'Inativo',
                          isActive: user.userSystemModel!.ativo == Situation.ativo,
                        ),
                      ),
                  ],
                ),

                // Empresa (se disponível)
                if (user.userSystemModel?.codEmpresa != null) ...[
                  const SizedBox(height: 12),
                  InfoCard(
                    label: 'Empresa',
                    value: '${user.userSystemModel!.codEmpresa}',
                    icon: Icons.business,
                    fullWidth: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(dynamic user, ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: user.isActive ? Colors.green.shade100 : Colors.grey.shade200,
            border: Border.all(color: user.isActive ? Colors.green.shade300 : Colors.grey.shade400, width: 2),
          ),
          child: EditableAvatar(viewModel: viewModel),
        ),
        // Badge de status mais discreto
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: user.isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
            ),
            child: Icon(user.isActive ? Icons.check : Icons.close, size: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
