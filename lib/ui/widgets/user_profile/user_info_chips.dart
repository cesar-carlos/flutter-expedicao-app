import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/ui/widgets/user_profile/widgets/index.dart';

class UserInfoChips extends StatelessWidget {
  final AppUser user;

  const UserInfoChips({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informações básicas do usuário
        _buildUserBasicInfo(context),

        // Informações da empresa e setores
        _buildCompanySection(context),

        // Permissões e acessos
        _buildPermissionsSection(context),
      ],
    );
  }

  Widget _buildUserBasicInfo(BuildContext context) {
    final systemData = user.userSystemModel;

    return PrimaryProfileSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Informações do Usuário', icon: Icons.person),

          const SizedBox(height: 16),

          // Grid de informações básicas
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DetailedInfoCard(label: 'Nome Completo', value: user.nome, icon: Icons.account_circle),
                  ),
                ],
              ),

              if (systemData?.nomeUsuario.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DetailedInfoCard(
                        label: 'Nome no Sistema',
                        value: systemData!.nomeUsuario,
                        icon: Icons.badge,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DetailedInfoCard(
                      label: 'Status',
                      value: user.isActive ? 'Ativo' : 'Inativo',
                      icon: user.isActive ? Icons.check_circle : Icons.cancel,
                      statusColor: user.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DetailedInfoCard(label: 'ID Login', value: '${user.codLoginApp}', icon: Icons.key),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySection(BuildContext context) {
    final systemData = user.userSystemModel;

    if (systemData == null) {
      return ErrorProfileSection(
        child: Row(
          children: [
            Icon(Icons.warning, color: Theme.of(context).colorScheme.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dados do sistema não carregados. Faça logout e login novamente.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SecondaryProfileSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Informações Corporativas',
            icon: Icons.business,
            iconBackgroundColor: Theme.of(context).colorScheme.secondary,
            iconColor: Theme.of(context).colorScheme.onSecondary,
          ),

          const SizedBox(height: 16),

          // Grid de informações corporativas
          Column(
            children: [
              if (systemData.codEmpresa != null || systemData.nomeEmpresa != null) ...[
                Row(
                  children: [
                    if (systemData.codEmpresa != null)
                      Expanded(
                        child: DetailedInfoCard(label: 'Código', value: '${systemData.codEmpresa}', icon: Icons.tag),
                      ),
                    if (systemData.codEmpresa != null && systemData.nomeEmpresa != null) const SizedBox(width: 12),
                    if (systemData.nomeEmpresa != null)
                      Expanded(
                        child: DetailedInfoCard(
                          label: 'Nome da Empresa',
                          value: systemData.nomeEmpresa!,
                          icon: Icons.corporate_fare,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Setores
              if (systemData.nomeSetorEstoque != null ||
                  systemData.nomeSetorConferencia != null ||
                  systemData.nomeSetorArmazenagem != null) ...[
                _buildSectorInfo(context, systemData),
                const SizedBox(height: 12),
              ],

              // Vendedor e Local de Armazenagem
              if (systemData.nomeVendedor != null || systemData.nomeLocalArmazenagem != null) ...[
                Row(
                  children: [
                    if (systemData.nomeVendedor != null)
                      Expanded(
                        child: DetailedInfoCard(
                          label: 'Vendedor',
                          value: systemData.nomeVendedor!,
                          icon: Icons.person_pin,
                        ),
                      ),
                    if (systemData.nomeVendedor != null && systemData.nomeLocalArmazenagem != null)
                      const SizedBox(width: 12),
                    if (systemData.nomeLocalArmazenagem != null)
                      Expanded(
                        child: DetailedInfoCard(
                          label: 'Local Armazenagem',
                          value: systemData.nomeLocalArmazenagem!,
                          icon: Icons.place,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Conta financeira e operador
              if (systemData.nomeContaFinanceira != null || systemData.nomeCaixaOperador != null) ...[
                if (systemData.nomeContaFinanceira != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: DetailedInfoCard(
                          label: 'Conta Financeira',
                          value: systemData.nomeContaFinanceira!,
                          icon: Icons.account_balance,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                if (systemData.nomeCaixaOperador != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: DetailedInfoCard(
                          label: 'Operador de Caixa',
                          value: systemData.nomeCaixaOperador!,
                          icon: Icons.point_of_sale,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectorInfo(BuildContext context, dynamic systemData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sectors = <Map<String, dynamic>>[];

    if (systemData.nomeSetorEstoque != null) {
      final value = systemData.codSetorEstoque != null
          ? '${systemData.nomeSetorEstoque} (${systemData.codSetorEstoque})'
          : systemData.nomeSetorEstoque!;
      sectors.add({'name': value, 'icon': Icons.inventory_2, 'type': 'Estoque'});
    }

    if (systemData.nomeSetorConferencia != null) {
      final value = systemData.codSetorConferencia != null
          ? '${systemData.nomeSetorConferencia} (${systemData.codSetorConferencia})'
          : systemData.nomeSetorConferencia!;
      sectors.add({'name': value, 'icon': Icons.checklist, 'type': 'Conferência'});
    }

    if (systemData.nomeSetorArmazenagem != null) {
      final value = systemData.codSetorArmazenagem != null
          ? '${systemData.nomeSetorArmazenagem} (${systemData.codSetorArmazenagem})'
          : systemData.nomeSetorArmazenagem!;
      sectors.add({'name': value, 'icon': Icons.warehouse, 'type': 'Armazenagem'});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Setores Vinculados',
          style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...sectors.map(
          (sector) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DetailedInfoCard(label: sector['type'], value: sector['name'], icon: sector['icon']),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection(BuildContext context) {
    final systemData = user.userSystemModel;

    if (systemData == null) return const SizedBox.shrink();

    final permissions = [
      PermissionData(
        title: 'Separações',
        description: 'Gerenciar separação de estoque',
        icon: Icons.inventory_2,
        hasPermission: systemData.permiteSepararForaSequencia == Situation.ativo,
      ),
      PermissionData(
        title: 'Conferências',
        description: 'Realizar conferências',
        icon: Icons.checklist,
        hasPermission: systemData.permiteConferirForaSequencia == Situation.ativo,
      ),
      PermissionData(
        title: 'Visualizar Todas',
        description: 'Ver todas as separações',
        icon: Icons.visibility,
        hasPermission: systemData.visualizaTodasSeparacoes == Situation.ativo,
      ),
      PermissionData(
        title: 'Gerenciar Carrinhos',
        description: 'Editar carrinhos de outros',
        icon: Icons.shopping_cart,
        hasPermission: systemData.editaCarrinhoOutroUsuario == Situation.ativo,
      ),
      PermissionData(
        title: 'Escaneamento de Prateleira',
        description: 'Obrigar escaneamento de prateleira na expedição',
        icon: Icons.qr_code_scanner,
        hasPermission: systemData.expedicaoObrigaEscanearPrateleira == Situation.ativo,
      ),
    ];

    return TertiaryProfileSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Permissões e Acessos',
            icon: Icons.security,
            iconBackgroundColor: Theme.of(context).colorScheme.tertiary,
            iconColor: Theme.of(context).colorScheme.onTertiary,
          ),

          const SizedBox(height: 16),

          PermissionsGrid(permissions: permissions),
        ],
      ),
    );
  }
}
