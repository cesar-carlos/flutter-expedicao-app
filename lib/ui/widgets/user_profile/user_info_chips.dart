import 'package:flutter/material.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/ui/widgets/user_profile/widgets/index.dart';

class UserInfoChips extends StatefulWidget {
  final AppUser user;

  const UserInfoChips({super.key, required this.user});

  @override
  State<UserInfoChips> createState() => _UserInfoChipsState();
}

class _UserInfoChipsState extends State<UserInfoChips> {
  bool _isUserInfoExpanded = true;
  bool _isCompanyInfoExpanded = true;
  bool _isPermissionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildExpandableSection(
          context,
          title: 'Informações do Usuário',
          subtitle: 'Acesso, identificação e status do perfil',
          icon: Icons.person,
          iconBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          iconColor: Theme.of(context).colorScheme.primary,
          isExpanded: _isUserInfoExpanded,
          onTap: () {
            setState(() {
              _isUserInfoExpanded = !_isUserInfoExpanded;
            });
          },
          child: _buildUserBasicInfo(context, user),
        ),
        _buildExpandableSection(
          context,
          title: 'Informações Corporativas',
          subtitle: _buildCorporateSummary(user),
          icon: Icons.business,
          iconBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          iconColor: Theme.of(context).colorScheme.secondary,
          isExpanded: _isCompanyInfoExpanded,
          onTap: () {
            setState(() {
              _isCompanyInfoExpanded = !_isCompanyInfoExpanded;
            });
          },
          child: _buildCompanySection(context, user),
        ),
        _buildExpandableSection(
          context,
          title: 'Permissões e Acessos',
          subtitle: _buildPermissionsSummary(user),
          icon: Icons.security,
          iconBackgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          iconColor: Theme.of(context).colorScheme.tertiary,
          isExpanded: _isPermissionsExpanded,
          onTap: () {
            setState(() {
              _isPermissionsExpanded = !_isPermissionsExpanded;
            });
          },
          child: _buildPermissionsSection(context, user),
        ),
      ],
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return ProfileSectionContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ExpandableSectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconBackgroundColor: iconBackgroundColor,
            iconColor: iconColor,
            isExpanded: isExpanded,
            onTap: onTap,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.transparent,
                                Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                AppColors.transparent,
                              ],
                            ),
                          ),
                        ),
                        child,
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBasicInfo(BuildContext context, AppUser user) {
    final systemData = user.userSystemModel;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DetailedInfoCard(label: 'Nome Completo', value: user.nome, icon: Icons.account_circle),
            ),
          ],
        ),
        if (systemData?.nomeUsuario.isNotEmpty == true && systemData!.nomeUsuario != user.nome) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DetailedInfoCard(label: 'Nome no Sistema', value: systemData.nomeUsuario, icon: Icons.badge),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DetailedInfoCard(label: 'ID Login', value: '${user.codLoginApp}', icon: Icons.key),
            ),
            if (user.codUsuario != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: DetailedInfoCard(
                  label: 'Código do Usuário',
                  value: '${user.codUsuario}',
                  icon: Icons.perm_identity,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatusChip(label: 'Login', status: user.isActive ? 'Ativo' : 'Inativo', isActive: user.isActive),
            ),
            if (systemData != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: StatusChip(
                  label: 'Sistema',
                  status: systemData.ativo == Situation.ativo ? 'Ativo' : 'Inativo',
                  isActive: systemData.ativo == Situation.ativo,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCompanySection(BuildContext context, AppUser user) {
    final systemData = user.userSystemModel;

    if (systemData == null) {
      return Row(
        children: [
          Icon(Icons.warning, color: Theme.of(context).colorScheme.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dados do sistema não carregados. Faça logout e login novamente.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (systemData.codEmpresa != null || systemData.nomeEmpresa != null) ...[
          Row(
            children: [
              if (systemData.codEmpresa != null)
                Expanded(
                  child: DetailedInfoCard(
                    label: 'Código da Empresa',
                    value: '${systemData.codEmpresa}',
                    icon: Icons.tag,
                  ),
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
        if (systemData.nomeSetorEstoque != null ||
            systemData.nomeSetorConferencia != null ||
            systemData.nomeSetorArmazenagem != null) ...[
          _buildSectorInfo(context, systemData),
          const SizedBox(height: 12),
        ],
        if (systemData.nomeVendedor != null || systemData.nomeLocalArmazenagem != null) ...[
          Row(
            children: [
              if (systemData.nomeVendedor != null)
                Expanded(
                  child: DetailedInfoCard(label: 'Vendedor', value: systemData.nomeVendedor!, icon: Icons.person_pin),
                ),
              if (systemData.nomeVendedor != null && systemData.nomeLocalArmazenagem != null) const SizedBox(width: 12),
              if (systemData.nomeLocalArmazenagem != null)
                Expanded(
                  child: DetailedInfoCard(
                    label: 'Local de Armazenagem',
                    value: systemData.nomeLocalArmazenagem!,
                    icon: Icons.place,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
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

  Widget _buildPermissionsSection(BuildContext context, AppUser user) {
    final systemData = user.userSystemModel;

    if (systemData == null) return const SizedBox.shrink();

    final permissions = [
      PermissionData(
        title: 'Separar Fora da Sequência',
        description: 'Permite executar separações sem seguir a ordem padrão',
        icon: Icons.inventory_2,
        hasPermission: systemData.permiteSepararForaSequencia == Situation.ativo,
      ),
      PermissionData(
        title: 'Visualizar Todas as Separações',
        description: 'Permite visualizar separações além da fila operacional',
        icon: Icons.visibility,
        hasPermission: systemData.visualizaTodasSeparacoes == Situation.ativo,
      ),
      PermissionData(
        title: 'Conferir Fora da Sequência',
        description: 'Permite realizar conferências sem seguir a ordem padrão',
        icon: Icons.checklist,
        hasPermission: systemData.permiteConferirForaSequencia == Situation.ativo,
      ),
      PermissionData(
        title: 'Visualizar Todas as Conferências',
        description: 'Permite acompanhar todas as conferências disponíveis',
        icon: Icons.fact_check_outlined,
        hasPermission: systemData.visualizaTodasConferencias == Situation.ativo,
      ),
      PermissionData(
        title: 'Armazenar Fora da Sequência',
        description: 'Permite armazenar itens sem seguir a ordem operacional',
        icon: Icons.warehouse,
        hasPermission: systemData.permiteArmazenarForaSequencia == Situation.ativo,
      ),
      PermissionData(
        title: 'Visualizar Todas as Armazenagens',
        description: 'Permite visualizar armazenagens além da fila padrão',
        icon: Icons.inventory_outlined,
        hasPermission: systemData.visualizaTodasArmazenagem == Situation.ativo,
      ),
      PermissionData(
        title: 'Editar Carrinhos de Outros',
        description: 'Permite editar carrinhos vinculados a outros usuários',
        icon: Icons.shopping_cart,
        hasPermission: systemData.editaCarrinhoOutroUsuario == Situation.ativo,
      ),
      PermissionData(
        title: 'Salvar Carrinhos de Outros',
        description: 'Permite concluir o salvamento de carrinhos de terceiros',
        icon: Icons.save_outlined,
        hasPermission: systemData.salvaCarrinhoOutroUsuario == Situation.ativo,
      ),
      PermissionData(
        title: 'Excluir Carrinhos de Outros',
        description: 'Permite excluir carrinhos vinculados a outros usuários',
        icon: Icons.delete_outline,
        hasPermission: systemData.excluiCarrinhoOutroUsuario == Situation.ativo,
      ),
      PermissionData(
        title: 'Escaneamento de Prateleira',
        description: 'Obrigar escaneamento de prateleira na expedição',
        icon: Icons.qr_code_scanner,
        hasPermission: systemData.expedicaoObrigaEscanearPrateleira == Situation.ativo,
      ),
      PermissionData(
        title: 'Entrega em Balcão Pré-venda',
        description: 'Permite operação de entrega em balcão para pré-venda',
        icon: Icons.storefront_outlined,
        hasPermission: systemData.expedicaoEntregaBalcaoPreVenda == Situation.ativo,
      ),
    ];

    return PermissionsGrid(permissions: permissions);
  }

  String _buildCorporateSummary(AppUser user) {
    final systemData = user.userSystemModel;

    if (systemData == null) {
      return 'Dados corporativos indisponíveis';
    }

    final linkedSectors = _countLinkedSectors(systemData);
    final hasCompany = systemData.codEmpresa != null || systemData.nomeEmpresa != null;

    if (hasCompany) {
      return '$linkedSectors setores vinculados e dados da empresa';
    }

    return '$linkedSectors setores vinculados';
  }

  String _buildPermissionsSummary(AppUser user) {
    final systemData = user.userSystemModel;
    if (systemData == null) {
      return 'Permissões indisponíveis';
    }

    final grantedPermissions = _countGrantedPermissions(systemData);
    return '$grantedPermissions de 11 permissões liberadas';
  }

  int _countLinkedSectors(dynamic systemData) {
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

  int _countGrantedPermissions(dynamic systemData) {
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
