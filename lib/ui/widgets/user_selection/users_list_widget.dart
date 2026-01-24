import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class UsersListWidget extends StatelessWidget {
  final UserSelectionViewModel viewModel;
  final ScrollController scrollController;
  final TextEditingController searchController;

  const UsersListWidget({
    super.key,
    required this.viewModel,
    required this.scrollController,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    switch (viewModel.state) {
      case UserSelectionState.initial:
        return _buildEmptyState(icon: Icons.person_search, message: 'Digite o nome do usuário para buscar');

      case UserSelectionState.loading:
        return _buildLoadingState('Buscando usuários...');

      case UserSelectionState.loaded:
        final filteredUsers = viewModel.filteredUsers;

        if (filteredUsers.isEmpty) {
          return _buildEmptyState(icon: Icons.person_off, message: 'Nenhum usuário encontrado');
        }

        return ListView.builder(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          cacheExtent: 200,
          itemCount: filteredUsers.length + (viewModel.hasMoreData && !viewModel.isSearchMode ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == filteredUsers.length) {
              return _buildLoadingMoreIndicator();
            }

            final user = filteredUsers[index];
            return _buildUserListTile(user);
          },
        );

      case UserSelectionState.selecting:
        return _buildLoadingState('Vinculando usuário...');

      case UserSelectionState.selected:
        // Estado não mais usado, mas mantido para compatibilidade
        return _buildLoadingState('Processando...');
    }
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.inter(fontSize: 16, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(message)],
        ),
      ),
    );
  }

  Widget _buildUserListTile(UserSystemModel user) {
    final isSelected = viewModel.selectedUser == user;
    final isAvailable = viewModel.isUserAvailable(user);
    final isBlocked = !isAvailable;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isBlocked
              ? AppColors.grey400
              : user.ativo == Situation.ativo
              ? AppColors.success
              : AppColors.grey,
          child: Text(
            user.nomeUsuario.substring(0, 2).toUpperCase(),
            style: AppFonts.inter(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.nomeUsuario,
          style: AppFonts.inter(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isBlocked ? AppColors.grey600 : null,
          ).copyWith(
            decoration: isBlocked ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${user.codUsuario}'),
            if (user.codContaFinanceira != null) Text('Conta: ${user.nomeContaFinanceira}'),
            if (isBlocked)
              Text(
                'Vinculado (ID: ${user.codLoginApp})',
                style: AppFonts.inter(color: AppColors.red600, fontSize: 12, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBlocked) Icon(Icons.link, color: AppColors.red600, size: 20),
            if (user.ativo != Situation.ativo) const Icon(Icons.warning, color: AppColors.warning),
            if (isAvailable)
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.success : AppColors.grey,
              ),
          ],
        ),
        selected: isSelected,
        selectedTileColor: AppColors.primaryWithOpacity(0.1),
        enabled: isAvailable,
        onTap: () => viewModel.selectUser(user),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: viewModel.isLoadingMore
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Text('Carregando mais usuários...', style: AppFonts.inter(fontSize: 14, color: AppColors.grey)),
              ],
            )
          : viewModel.hasMoreData
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
                const SizedBox(width: 8),
                Text('Role para carregar mais', style: AppFonts.inter(fontSize: 12, color: AppColors.grey)),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Text('Todos os usuários foram carregados', style: AppFonts.inter(fontSize: 12, color: AppColors.grey)),
              ],
            ),
    );
  }
}
