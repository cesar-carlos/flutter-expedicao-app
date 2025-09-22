import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/core/routing/app_router.dart';
import 'package:exp/domain/viewmodels/separate_items_viewmodel.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/ui/widgets/common/custom_app_bar.dart';
import 'package:exp/ui/widgets/separate_items/separate_item_card.dart';
import 'package:exp/ui/widgets/separate_items/separate_items_bottom_navigation.dart';
import 'package:exp/ui/widgets/separate_items/carts_list_view.dart';
import 'package:exp/ui/widgets/separate_items/separate_items_error_state.dart';
import 'package:exp/ui/widgets/separate_items/separation_info_view.dart';
import 'package:exp/ui/widgets/separate_items/separate_items_filter_modal.dart';
import 'package:exp/ui/widgets/separate_items/carts_filter_modal.dart';
import 'package:exp/ui/screens/add_cart_screen.dart';

class SeparateItemsScreen extends StatefulWidget {
  final SeparateConsultationModel separation;

  const SeparateItemsScreen({super.key, required this.separation});

  @override
  State<SeparateItemsScreen> createState() => _SeparateItemsScreenState();
}

class _SeparateItemsScreenState extends State<SeparateItemsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Listener para atualizar o FAB quando trocar de aba
    _tabController.addListener(() {
      setState(() {});
    });

    // Carrega os itens e carrinhos quando a tela é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SeparateItemsViewModel>();
      viewModel.loadSeparationItems(widget.separation);
      viewModel.loadSeparationCarts(widget.separation);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Separar Itens',
        leading: IconButton(
          onPressed: () => context.go(AppRouter.separation),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
        ),
        actions: [
          // Botão de filtro baseado na aba ativa
          Consumer<SeparateItemsViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                onPressed: () => _showFilterModal(context),
                icon: Stack(
                  children: [
                    const Icon(Icons.filter_alt),
                    if ((_tabController.index == 0 && viewModel.hasActiveItemsFilters) ||
                        (_tabController.index == 1 && viewModel.hasActiveCartsFilters))
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
                tooltip: _tabController.index == 0 ? 'Filtros de Produtos' : 'Filtros de Carrinhos',
              );
            },
          ),
        ],
      ),
      body: Consumer<SeparateItemsViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(context, viewModel);
        },
      ),
      bottomNavigationBar: SeparateItemsBottomNavigation(tabController: _tabController),
      floatingActionButton:
          _tabController.index ==
              1 // Apenas na aba de carrinhos
          ? FloatingActionButton.extended(
              onPressed: () => _onAddCart(context),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Incluir Carrinho'),
              tooltip: 'Incluir novo carrinho na separação',
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, SeparateItemsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Carregando itens da separação...')],
        ),
      );
    }

    if (viewModel.hasError) {
      return SeparateItemsErrorState(viewModel: viewModel, onRefresh: () => viewModel.refresh());
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildWaitingItemsView(context, viewModel),
        CartsListView(viewModel: viewModel),
        SeparationInfoView(separation: widget.separation, viewModel: viewModel),
      ],
    );
  }

  Widget _buildWaitingItemsView(BuildContext context, SeparateItemsViewModel viewModel) {
    if (!viewModel.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'Nenhum item encontrado',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Não há itens para separar nesta separação.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Aumenta padding inferior para 100px
      itemCount: viewModel.items.length,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return SeparateItemCard(item: item, onSeparate: () => _onSeparateItem(context, item, viewModel));
      },
    );
  }

  void _showFilterModal(BuildContext context) {
    final viewModel = context.read<SeparateItemsViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (_tabController.index == 0) {
          // Aba de produtos
          return SeparateItemsFilterModal(viewModel: viewModel);
        } else {
          // Aba de carrinhos
          return CartsFilterModal(viewModel: viewModel);
        }
      },
    );
  }

  void _onSeparateItem(BuildContext context, SeparateItemConsultationModel item, SeparateItemsViewModel viewModel) {
    // TODO: Implementar ação de separar item específico
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Separar item ${item.codProduto} - Em desenvolvimento'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _onAddCart(BuildContext context) async {
    final viewModel = context.read<SeparateItemsViewModel>();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddCartScreen(
          codEmpresa: viewModel.separation?.codEmpresa ?? 1,
          codSepararEstoque: viewModel.separation?.codSepararEstoque ?? 0,
        ),
      ),
    );

    // Se o carrinho foi adicionado com sucesso, atualizar a lista
    if (result == true) {
      await viewModel.refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carrinho adicionado com sucesso!'), backgroundColor: Colors.green),
        );
      }
    }
  }
}
