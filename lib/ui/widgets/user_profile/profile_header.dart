import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/profile_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/user_profile/editable_avatar.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileViewModel viewModel;

  const ProfileHeader({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final AppUser? user = viewModel.currentUser;
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
                _buildAvatar(user, colorScheme),

                const SizedBox(height: 20),

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

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSummaryChip(
                      context,
                      icon: Icons.business,
                      label: 'Empresa',
                      value: _buildCompanyLabel(user.userSystemModel),
                    ),
                    _buildSummaryChip(
                      context,
                      icon: Icons.account_tree_outlined,
                      label: 'Setores',
                      value: '${_countLinkedSectors(user.userSystemModel)} vinculados',
                    ),
                    _buildSummaryChip(
                      context,
                      icon: Icons.verified_user_outlined,
                      label: 'Acessos',
                      value: '${_countGrantedPermissions(user.userSystemModel)} liberados',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(AppUser user, ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: user.isActive
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: user.isActive
                  ? AppColors.success.withValues(alpha: 0.5)
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: EditableAvatar(viewModel: viewModel),
        ),

        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: user.isActive ? AppColors.success : AppColors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
            ),
            child: Icon(user.isActive ? Icons.check : Icons.close, size: 10, color: colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildCompanyLabel(UserSystemModel? systemData) {
    if (systemData == null) {
      return 'Não vinculada';
    }

    final String? companyName = systemData.nomeEmpresa;
    final int? companyCode = systemData.codEmpresa;

    if (companyName != null && companyName.isNotEmpty) {
      return companyCode != null ? '$companyName ($companyCode)' : companyName;
    }

    if (companyCode != null) {
      return '$companyCode';
    }

    return 'Não vinculada';
  }

  int _countLinkedSectors(UserSystemModel? systemData) {
    if (systemData == null) {
      return 0;
    }

    int total = 0;

    if (systemData.nomeSetorEstoque != null) {
      total++;
    }

    if (systemData.nomeSetorConferencia != null) {
      total++;
    }

    if (systemData.nomeSetorArmazenagem != null) {
      total++;
    }

    return total;
  }

  int _countGrantedPermissions(UserSystemModel? systemData) {
    if (systemData == null) {
      return 0;
    }

    final permissions = [
      systemData.permiteSepararForaSequencia,
      systemData.visualizaTodasSeparacoes,
      systemData.permiteConferirForaSequencia,
      systemData.visualizaTodasConferencias,
      systemData.permiteArmazenarForaSequencia,
      systemData.visualizaTodasArmazenagem,
      systemData.editaCarrinhoOutroUsuario,
      systemData.salvaCarrinhoOutroUsuario,
      systemData.excluiCarrinhoOutroUsuario,
      systemData.expedicaoObrigaEscanearPrateleira,
      systemData.expedicaoEntregaBalcaoPreVenda,
    ];

    return permissions.where((permission) => permission == Situation.ativo).length;
  }
}
