import 'package:flutter/material.dart';
import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/core/theme/app_colors.dart';

class UserSearchField extends StatelessWidget {
  final TextEditingController searchController;
  final UserSelectionViewModel viewModel;
  final VoidCallback onPerformSearch;

  const UserSearchField({
    super.key,
    required this.searchController,
    required this.viewModel,
    required this.onPerformSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: 'Digite o nome do usuário',
            hintText: 'Ex: João Silva',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      viewModel.clearSelection();
                    },
                  )
                : null,
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              onPerformSearch();
            }
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: viewModel.state == UserSelectionState.loading
                ? null
                : onPerformSearch,
            icon: viewModel.state == UserSelectionState.loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(
              viewModel.state == UserSelectionState.loading
                  ? 'Carregando...'
                  : searchController.text.trim().isNotEmpty
                  ? 'Buscar no Servidor'
                  : 'Carregar Todos os Usuários',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
