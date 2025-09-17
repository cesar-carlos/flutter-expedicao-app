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
import 'package:exp/ui/widgets/separate_items/separation_info_dialog.dart';
import 'package:exp/ui/widgets/separate_items/carts_list_view.dart';
import 'package:exp/ui/widgets/separate_items/separate_items_error_state.dart';
import 'package:exp/ui/widgets/separate_items/separation_info_view.dart';
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
          // Separar todos os itens (equivalente ao F7 do desktop)
          IconButton(
            onPressed: () => _separateAllItems(context),
            icon: const Icon(Icons.select_all),
            tooltip: 'Separar Todos',
          ),
          IconButton(
            onPressed: () => _showSeparationInfo(context),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informações',
          ),
          IconButton(onPressed: () => _refreshData(context), icon: const Icon(Icons.refresh), tooltip: 'Atualizar'),
          // Menu de opções
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_cart',
                child: Row(children: [Icon(Icons.add_shopping_cart), SizedBox(width: 8), Text('Adicionar Carrinho')]),
              ),
              const PopupMenuItem(
                value: 'add_observation',
                child: Row(children: [Icon(Icons.note_add), SizedBox(width: 8), Text('Adicionar Observação')]),
              ),
              const PopupMenuItem(
                value: 'recover_cart',
                child: Row(children: [Icon(Icons.restore), SizedBox(width: 8), Text('Recuperar Carrinho')]),
              ),
              const PopupMenuItem(
                value: 'finalize',
                child: Row(children: [Icon(Icons.check_circle), SizedBox(width: 8), Text('Finalizar Separação')]),
              ),
            ],
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
      return SeparateItemsErrorState(viewModel: viewModel, onRefresh: () => _refreshData(context));
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
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.items.length,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return SeparateItemCard(item: item, onSeparate: () => _onSeparateItem(context, item, viewModel));
      },
    );
  }

  void _showSeparationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SeparationInfoDialog(separation: widget.separation),
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

  void _refreshData(BuildContext context) {
    context.read<SeparateItemsViewModel>().refresh();
  }

  void _separateAllItems(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Separar Todos os Itens'),
        content: const Text('Deseja separar automaticamente todos os itens pendentes desta separação?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SeparateItemsViewModel>().separateAllItems();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Separando todos os itens...'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: const Text('Separar Todos'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'add_cart':
        _showAddCartDialog(context);
        break;
      case 'add_observation':
        _showAddObservationDialog(context);
        break;
      case 'recover_cart':
        _showRecoverCartDialog(context);
        break;
      case 'finalize':
        _showFinalizeSeparationDialog(context);
        break;
    }
  }

  void _showAddCartDialog(BuildContext context) {
    // TODO: Implementar dialog de adicionar carrinho
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Adicionar Carrinho - Em desenvolvimento'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showAddObservationDialog(BuildContext context) {
    final observationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Observação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Separação ${widget.separation.codSepararEstoque}'),
            const SizedBox(height: 16),
            TextField(
              controller: observationController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observação',
                border: OutlineInputBorder(),
                hintText: 'Digite uma observação sobre esta separação...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar salvamento da observação
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Observação adicionada - Em desenvolvimento'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showRecoverCartDialog(BuildContext context) {
    // TODO: Implementar dialog de recuperar carrinho
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recuperar Carrinho - Em desenvolvimento'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  void _showFinalizeSeparationDialog(BuildContext context) {
    final viewModel = context.read<SeparateItemsViewModel>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Separação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Separação ${widget.separation.codSepararEstoque}'),
            const SizedBox(height: 8),
            Text('Total de itens: ${viewModel.totalItems}'),
            Text('Progresso: ${viewModel.percentualConcluido.toStringAsFixed(0)}%'),
            const SizedBox(height: 16),
            if (!viewModel.isSeparationComplete)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Theme.of(context).colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Atenção: Nem todos os itens foram separados!',
                        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: viewModel.isSeparationComplete
                ? () {
                    Navigator.of(context).pop();
                    // TODO: Implementar finalização da separação
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Separação finalizada - Em desenvolvimento'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }
                : null,
            child: const Text('Finalizar'),
          ),
        ],
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
