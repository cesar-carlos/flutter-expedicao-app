import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/user_selection/index.dart';
import 'package:data7_expedicao/ui/widgets/common/index.dart';

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
    // Bug GGGGGGG: TextEditingController listeners podem disparar APOS
    // dispose se o controller for modificado externamente entre o
    // `removeListener` e o `dispose`. context.read em widget desmontado
    // lanca ProviderNotFoundException.
    if (!mounted) return;
    final viewModel = context.read<UserSelectionViewModel>();
    viewModel.updateSearchQuery(_searchController.text);
  }

  void _onScroll() {
    // Bug HHHHHHH: ScrollController listeners idem — podem disparar
    // durante a janela entre removeListener e dispose.
    if (!mounted) return;
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
      unawaited(
        viewModel.loadMoreUsers().catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha ao carregar mais usuários',
            tag: 'UserSelectionScreen',
            error: e,
            stackTrace: s,
          );
        }),
      );
    } else if (!isNearBottom && _isNearBottom) {
      _isNearBottom = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.withoutSocket(title: 'Selecionar Usuário do Sistema', elevation: 0),
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
                        UserConfirmButton(viewModel: viewModel, onConfirm: () => _confirmSelection(viewModel)),
                        const SizedBox(height: 16),
                        // Botão para voltar à lista
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _clearSelection(viewModel),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'Escolher Outro Usuário',
                              style: AppFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
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
      unawaited(
        viewModel.searchUsers(searchText).catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha na busca de usuários',
            tag: 'UserSelectionScreen',
            error: e,
            stackTrace: s,
          );
        }),
      );
    } else {
      unawaited(
        viewModel.loadAllUsers().catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha ao carregar lista de usuários',
            tag: 'UserSelectionScreen',
            error: e,
            stackTrace: s,
          );
        }),
      );
    }
  }

  void _clearSelection(UserSelectionViewModel viewModel) {
    viewModel.clearSelection();
    unawaited(
      viewModel.loadAllUsers().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao recarregar usuários após limpar seleção',
          tag: 'UserSelectionScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  Future<void> _confirmSelection(UserSelectionViewModel viewModel) async {
    try {
      final success = await viewModel.confirmUserSelection();

      if (!mounted) return;

      if (success) {
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          // Bug IIIIIII: viewModel.currentAppUser! era null assertion.
          // Em race rara (outro fluxo zerou currentAppUser entre o
          // confirm e o delayed), crashava com NullCheckError. Agora
          // validamos explicitamente.
          final appUser = viewModel.currentAppUser;
          if (appUser != null) {
            final authViewModel = context.read<AuthViewModel>();
            await authViewModel.updateUserAfterSelection(appUser);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(viewModel.errorMessage ?? 'Erro ao vincular usuário'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }
}
