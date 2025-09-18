import 'package:flutter/material.dart';

import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/situation_model.dart';
import 'package:exp/core/theme/app_colors.dart';

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
              style: const TextStyle(fontSize: 16, color: Colors.grey),
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
              ? Colors.grey.shade400
              : user.ativo == Situation.ativo
              ? AppColors.success
              : Colors.grey,
          child: Text(
            user.nomeUsuario.substring(0, 2).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.nomeUsuario,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isBlocked ? Colors.grey.shade600 : null,
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
                style: TextStyle(color: Colors.red.shade600, fontSize: 12, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBlocked) Icon(Icons.link, color: Colors.red.shade600, size: 20),
            if (user.ativo != Situation.ativo) const Icon(Icons.warning, color: Colors.orange),
            if (isAvailable)
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.success : Colors.grey,
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
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text('Carregando mais usuários...', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            )
          : viewModel.hasMoreData
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                SizedBox(width: 8),
                Text('Role para carregar mais', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Todos os usuários foram carregados', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
    );
  }
}
