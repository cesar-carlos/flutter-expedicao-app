import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/di/locator.dart';
import 'package:exp/ui/screens/add_cart_screen.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/viewmodels/separation_items_viewmodel.dart';
import 'package:exp/ui/widgets/separate_items/separate_item_card.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/models/situation/expedition_situation_model.dart';
import 'package:exp/ui/widgets/separate_items/separate_items_bottom_navigation.dart';
import 'package:exp/ui/widgets/separate_items/separate_items_filter_modal.dart';
import 'package:exp/ui/widgets/separate_items/separate_items_error_state.dart';
import 'package:exp/ui/widgets/separate_items/separation_info_view.dart';
import 'package:exp/ui/widgets/separate_items/carts_filter_modal.dart';
import 'package:exp/ui/widgets/separate_items/carts_list_view.dart';
import 'package:exp/ui/widgets/separation_title_with_connection_status.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/ui/widgets/common/custom_app_bar.dart';
import 'package:exp/ui/screens/card_picking_screen.dart';
import 'package:exp/core/constants/ui_constants.dart';

class SeparationItemsScreen extends StatefulWidget {
  final SeparateConsultationModel separation;

  const SeparationItemsScreen({super.key, required this.separation});

  @override
  State<SeparationItemsScreen> createState() => _SeparationItemsScreenState();
}

class _SeparationItemsScreenState extends State<SeparationItemsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _cartsScrollController = ScrollController();
  final _itemsScrollController = ScrollController();

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
      final viewModel = context.read<SeparationItemsViewModel>();
      viewModel.loadSeparationItems(widget.separation);
      viewModel.loadSeparationCarts(widget.separation);

      // Inicia o monitoramento de eventos de carrinho
      viewModel.startCartEventMonitoring();
    });
  }

  @override
  void dispose() {
    // Para o monitoramento de eventos de carrinho
    try {
      final viewModel = context.read<SeparationItemsViewModel>();
      viewModel.stopCartEventMonitoring();
    } catch (e) {
      // Ignora erro se o contexto não estiver mais disponível
    }

    _tabController.dispose();
    _searchController.dispose();
    _cartsScrollController.dispose();
    _itemsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const SeparationTitleWithConnectionStatus(),
        showSocketStatus: false,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), tooltip: 'Voltar'),
        actions: [
          // Botões de ação baseados na aba ativa (não mostrar na aba Informações)
          if (_tabController.index != 2) // Não mostrar filtro na aba Informações
            Consumer<SeparationItemsViewModel>(
              builder: (context, viewModel, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão de filtro
                    IconButton(
                      onPressed: () => _showFilterModal(context),
                      icon: Stack(
                        children: [
                          const Icon(Icons.filter_alt),
                          if ((_tabController.index == 1 && viewModel.hasActiveItemsFilters) ||
                              (_tabController.index == 0 && viewModel.hasActiveCartsFilters))
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
                      tooltip: _tabController.index == 1 ? 'Filtros de Produtos' : 'Filtros de Carrinhos',
                    ),
                    // Botão de atualizar
                    IconButton(
                      onPressed: () => _refreshData(viewModel),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Atualizar dados',
                    ),
                  ],
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Conteúdo principal
          Expanded(
            child: Consumer<SeparationItemsViewModel>(
              builder: (context, viewModel, child) {
                return _buildBody(context, viewModel);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SeparateItemsBottomNavigation(tabController: _tabController),
      floatingActionButton: Consumer<SeparationItemsViewModel>(
        builder: (context, viewModel, child) {
          // Na aba de informações (índice 2), não mostrar nenhum FAB
          if (_tabController.index == 2) return const SizedBox.shrink();

          // Mostrar FAB de adicionar carrinho apenas na aba de carrinhos
          if (_tabController.index == 0) {
            final canAddCart = _canAddCart(viewModel.separation);
            return FloatingActionButton.extended(
              heroTag: 'addCart',
              onPressed: canAddCart ? () => _onAddCart(context) : null,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Incluir Carrinho'),
              tooltip: canAddCart
                  ? 'Incluir novo carrinho na separação'
                  : 'Não é possível adicionar carrinho na situação atual',
              backgroundColor: canAddCart ? null : Colors.grey,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SeparationItemsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: UIConstants.defaultPadding),
            Text('Carregando itens da separação...'),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return SeparateItemsErrorState(viewModel: viewModel, onRefresh: () => viewModel.refresh());
    }

    return TabBarView(
      controller: _tabController,
      children: [
        CartsListView(viewModel: viewModel, scrollController: _cartsScrollController),
        _buildWaitingItemsView(context, viewModel),
        SeparationInfoView(separation: widget.separation, viewModel: viewModel),
      ],
    );
  }

  Widget _buildWaitingItemsView(BuildContext context, SeparationItemsViewModel viewModel) {
    if (!viewModel.hasData) {
      return RefreshIndicator(
        onRefresh: () async {
          await viewModel.refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.extraLargePadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: UIConstants.extraLargeIconSize,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: UIConstants.defaultPadding),
                    Text(
                      'Nenhum item encontrado',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: UIConstants.smallPadding),
                    Text(
                      'Não há itens para separar nesta separação.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: UIConstants.defaultPadding),
                    Text(
                      'Puxe para atualizar',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refresh();
      },
      child: ListView.builder(
        controller: _itemsScrollController,
        padding: const EdgeInsets.fromLTRB(
          UIConstants.defaultPadding,
          UIConstants.defaultPadding,
          UIConstants.defaultPadding,
          100,
        ), // Aumenta padding inferior para 100px
        itemCount: viewModel.items.length,
        itemBuilder: (context, index) {
          final item = viewModel.items[index];
          return SeparateItemCard(item: item, onSeparate: () => _onSeparateItem(context, item, viewModel));
        },
      ),
    );
  }

  void _refreshData(SeparationItemsViewModel viewModel) {
    viewModel.refresh();
  }

  void _showFilterModal(BuildContext context) {
    final viewModel = context.read<SeparationItemsViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (_tabController.index == 1) {
          // Aba de produtos
          return SeparateItemsFilterModal(viewModel: viewModel);
        } else {
          // Aba de carrinhos
          return CartsFilterModal(viewModel: viewModel);
        }
      },
    );
  }

  void _onSeparateItem(BuildContext context, SeparateItemConsultationModel item, SeparationItemsViewModel viewModel) {
    // TODO: Implementar ação de separar item específico
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Separar item ${item.codProduto} - Em desenvolvimento'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _onAddCart(BuildContext context) async {
    final viewModel = context.read<SeparationItemsViewModel>();

    // Verificar se a separação permite adicionar carrinho
    if (!_canAddCart(viewModel.separation)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não é possível adicionar carrinho. Situação atual: ${viewModel.separation?.situacao.description ?? 'Desconhecida'}\n'
              'Permitido apenas em: Aguardando, Separando ou Em Separação',
            ),
            backgroundColor: Colors.orange,
            duration: UIConstants.snackBarLongDuration,
          ),
        );
      }
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddCartScreen(
          codEmpresa: viewModel.separation?.codEmpresa ?? 1,
          codSepararEstoque: viewModel.separation?.codSepararEstoque ?? 0,
        ),
      ),
    );

    // Se o carrinho foi adicionado com sucesso, atualizar a lista e abrir separação
    if (result == true) {
      await viewModel.refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carrinho adicionado com sucesso!'), backgroundColor: Colors.green),
        );

        // Aguardar um pouco para o usuário ver o SnackBar
        await Future.delayed(UIConstants.mediumDelay);

        // Buscar o carrinho recém-adicionado e abrir a separação
        if (context.mounted) {
          await _openSeparationForNewestCart(context, viewModel);
        }
      }
    }
  }

  /// Verifica se é possível adicionar carrinho baseado na situação da separação
  bool _canAddCart(SeparateConsultationModel? separation) {
    if (separation == null) return false;

    // Permitir apenas nas situações: Aguardando, Separando, Em Separação
    return separation.situacao == ExpeditionSituation.aguardando ||
        separation.situacao == ExpeditionSituation.separando ||
        separation.situacao == ExpeditionSituation.aguardando;
  }

  /// Abre a separação do carrinho mais recente (recém-adicionado)
  Future<void> _openSeparationForNewestCart(BuildContext context, SeparationItemsViewModel viewModel) async {
    try {
      // Obter o userModel da sessão
      final userSessionService = locator<UserSessionService>();
      final appUser = await userSessionService.loadUserSession();
      final userModel = appUser?.userSystemModel;

      if (!context.mounted) return;

      // Buscar o carrinho mais recente que pode ser separado
      final newestCart =
          viewModel.carts
              .where(
                (cart) =>
                    cart.situacao == ExpeditionSituation.aguardando ||
                    cart.situacao == ExpeditionSituation.separado ||
                    cart.situacao == ExpeditionSituation.conferido ||
                    cart.situacao == ExpeditionSituation.separando,
              )
              .toList()
            ..sort((a, b) => b.dataInicio.compareTo(a.dataInicio)); // Ordenar por data mais recente

      if (newestCart.isNotEmpty) {
        final cart = newestCart.first;

        // Navegar para a tela de separação do carrinho
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => CardPickingViewModel(),
              child: CardPickingScreen(
                cart: cart,
                userModel: userModel, // ✅ Agora passa o userModel correto
              ),
            ),
          ),
        );
      } else {
        // Se não encontrou carrinho adequado, mostrar mensagem
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum carrinho disponível para separação'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      // Em caso de erro, mostrar mensagem
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir separação: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
