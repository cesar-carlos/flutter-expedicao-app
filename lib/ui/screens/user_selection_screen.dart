import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exp/core/theme/app_colors.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/ui/widgets/user_selection/index.dart';
import 'package:exp/ui/widgets/common/index.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isNearBottom = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final viewModel = context.read<UserSelectionViewModel>();
    viewModel.updateSearchQuery(_searchController.text);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final currentPosition = _scrollController.position.pixels;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final isNearBottom = currentPosition >= maxExtent - 100;

    final viewModel = context.read<UserSelectionViewModel>();

    if (isNearBottom &&
        !_isNearBottom &&
        viewModel.hasMoreData &&
        !viewModel.isLoadingMore &&
        !viewModel.isSearchMode) {
      _isNearBottom = true;
      viewModel.loadMoreUsers();
    } else if (!isNearBottom && _isNearBottom) {
      _isNearBottom = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.withoutSocket(
        title: 'Selecionar Usuário do Sistema',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: Consumer<UserSelectionViewModel>(
        builder: (context, viewModel, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const UserInfoCard(),
                      const SizedBox(height: 16),
                      UserSearchField(
                        searchController: _searchController,
                        viewModel: viewModel,
                        onPerformSearch: () => _performSearch(viewModel),
                      ),
                      const SizedBox(height: 12),
                      SearchStatusInfo(viewModel: viewModel),
                      const SizedBox(height: 16),
                      // Mostrar lista apenas quando nenhum usuário estiver selecionado
                      if (viewModel.selectedUser == null)
                        SizedBox(
                          height: constraints.maxHeight * 0.5,
                          child: UsersListWidget(
                            viewModel: viewModel,
                            scrollController: _scrollController,
                            searchController: _searchController,
                          ),
                        )
                      else ...[
                        // Mostrar cartão e botão quando usuário estiver selecionado
                        UserSelectionCard(viewModel: viewModel),
                        const SizedBox(height: 16),
                        UserConfirmButton(
                          viewModel: viewModel,
                          onConfirm: () => _confirmSelection(viewModel),
                        ),
                        const SizedBox(height: 16),
                        // Botão para voltar à lista
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _clearSelection(viewModel),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Escolher Outro Usuário',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _performSearch(UserSelectionViewModel viewModel) {
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      viewModel.searchUsers(searchText);
    } else {
      viewModel.loadAllUsers();
    }
  }

  void _clearSelection(UserSelectionViewModel viewModel) {
    viewModel.clearSelection();
    // Carregar automaticamente os primeiros 20 usuários
    viewModel.loadAllUsers();
  }

  Future<void> _confirmSelection(UserSelectionViewModel viewModel) async {
    try {
      final success = await viewModel.confirmUserSelection();

      if (!mounted) return;

      if (success) {
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          final authViewModel = context.read<AuthViewModel>();
          authViewModel.updateUserAfterSelection(viewModel.currentAppUser!);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(viewModel.errorMessage ?? 'Erro ao vincular usuário'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
