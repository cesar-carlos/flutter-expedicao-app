import 'package:flutter/material.dart';

import 'package:exp/domain/models/user/app_user.dart';
import 'package:exp/domain/models/situation_model.dart';

class UserInfoChips extends StatelessWidget {
  final AppUser user;

  const UserInfoChips({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informações da empresa
        _buildCompanySection(context, colorScheme, theme),

        const SizedBox(height: 20),

        // Permissões e acessos
        _buildPermissionsSection(context, colorScheme, theme),
      ],
    );
  }

  Widget _buildCompanySection(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    final systemData = user.userSystemModel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.business, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Informações Corporativas',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Grid de informações
          Row(
            children: [
              if (systemData?.codEmpresa != null) ...[
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Empresa',
                    '${systemData!.codEmpresa}',
                    Icons.corporate_fare,
                    colorScheme,
                    theme,
                  ),
                ),
              ],
              if (systemData?.codEmpresa != null && systemData?.nomeContaFinanceira != null) const SizedBox(width: 12),
              if (systemData?.nomeContaFinanceira != null) ...[
                Expanded(
                  flex: 2,
                  child: _buildInfoCard(
                    context,
                    'Conta Financeira',
                    systemData!.nomeContaFinanceira!,
                    Icons.account_balance,
                    colorScheme,
                    theme,
                  ),
                ),
              ],
            ],
          ),

          if (systemData?.nomeCaixaOperador != null) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              'Operador de Caixa',
              systemData!.nomeCaixaOperador!,
              Icons.point_of_sale,
              colorScheme,
              theme,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionsSection(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colorScheme.secondary, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.security, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Permissões e Acessos',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Grid de permissões
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildPermissionCard(
                      context,
                      'Separações',
                      'Gerenciar separação de estoque',
                      Icons.inventory_2,
                      user.userSystemModel?.canWorkWithSeparations ?? false,
                      colorScheme,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPermissionCard(
                      context,
                      'Conferências',
                      'Realizar conferências',
                      Icons.checklist,
                      user.userSystemModel?.canWorkWithConferences ?? false,
                      colorScheme,
                      theme,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildPermissionCard(
                      context,
                      'Carrinhos',
                      'Gerenciar carrinhos de outros',
                      Icons.shopping_cart,
                      user.userSystemModel?.canManageOtherCarts ?? false,
                      colorScheme,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPermissionCard(
                      context,
                      'Fora Sequência',
                      'Trabalhar fora da sequência',
                      Icons.shuffle,
                      user.userSystemModel?.permiteSepararForaSequencia == Situation.ativo,
                      colorScheme,
                      theme,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
    ThemeData theme, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.05), offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool hasPermission,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
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
        boxShadow: hasPermission ? [BoxShadow(color: Colors.green.withOpacity(0.1), offset: const Offset(0, 2))] : null,
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
