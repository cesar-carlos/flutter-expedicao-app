import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/viewmodels/separation_items_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/separate_item_card.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/separate_items_bottom_navigation.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/separate_items_filter_modal.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/separate_items_error_state.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/separation_info_view.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/carts_filter_modal.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/carts_list_view.dart';
import 'package:data7_expedicao/ui/widgets/separation_title_with_connection_status.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

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

    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SeparationItemsViewModel>();
      viewModel.loadSeparationItems(widget.separation);
      viewModel.loadSeparationCarts(widget.separation);

      viewModel.startCartEventMonitoring();
    });
  }

  @override
  void dispose() {
    try {
      final viewModel = context.read<SeparationItemsViewModel>();
      viewModel.stopCartEventMonitoring();
    } catch (e, stackTrace) {
      AppLogger.debug(
        'Erro ao parar monitoramento de eventos (contexto pode não estar mais disponível)',
        tag: 'SeparationItemsScreen',
        error: e,
        stackTrace: stackTrace,
      );
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
          if (_tabController.index != 2)
            Consumer<SeparationItemsViewModel>(
              builder: (context, viewModel, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                                decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                      tooltip: _tabController.index == 1 ? 'Filtros de Produtos' : 'Filtros de Carrinhos',
                    ),

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
          if (_tabController.index == 2) return const SizedBox.shrink();

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: screenHeight * 0.7,
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
            );
          },
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
        ),
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
          return SeparateItemsFilterModal(viewModel: viewModel);
        } else {
          return CartsFilterModal(viewModel: viewModel);
        }
      },
    );
  }

  void _onSeparateItem(BuildContext context, SeparateItemConsultationModel item, SeparationItemsViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Separar item ${item.codProduto} - Em desenvolvimento'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _onAddCart(BuildContext context) async {
    final viewModel = context.read<SeparationItemsViewModel>();

    if (!_canAddCart(viewModel.separation)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não é possível adicionar carrinho. Situação atual: ${viewModel.separation?.situacao.description ?? 'Desconhecida'}\n'
              'Permitido apenas em: Aguardando, Separando ou Em Separação',
            ),
            backgroundColor: AppColors.warning,
            duration: UIConstants.snackBarLongDuration,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    final result = await context.push<bool>(
      AppRouter.addCart,
      extra: {
        'codEmpresa': viewModel.separation?.codEmpresa ?? 1,
        'codSepararEstoque': viewModel.separation?.codSepararEstoque ?? 0,
      },
    );

    if (result == true) {
      AppLogger.debug(
        'Carrinho adicionado com sucesso, iniciando processo de abertura...',
        tag: 'SeparationItemsScreen',
      );

      await viewModel.refresh();

      await Future.delayed(const Duration(milliseconds: 500));

      int retryCount = 0;
      while (!viewModel.cartsLoaded && retryCount < 5 && context.mounted) {
        await Future.delayed(const Duration(milliseconds: 200));
        retryCount++;
      }

      if (!context.mounted) {
        AppLogger.warning('Context não está mais montado, abortando navegação', tag: 'SeparationItemsScreen');
        return;
      }

      AppLogger.debug(
        'Carrinhos carregados: ${viewModel.carts.length}, tentando abrir o mais recente...',
        tag: 'SeparationItemsScreen',
      );

      final cartOpened = await _openSeparationForNewestCart(context, viewModel);

      if (!cartOpened && context.mounted) {
        AppLogger.debug('Primeira tentativa falhou, tentando novamente após refresh...', tag: 'SeparationItemsScreen');
        await Future.delayed(const Duration(milliseconds: 500));
        await viewModel.refresh();
        
        if (!context.mounted) {
          AppLogger.warning('Context não está mais montado após refresh', tag: 'SeparationItemsScreen');
          return;
        }
        
        final retryOpened = await _openSeparationForNewestCart(context, viewModel);

        if (!retryOpened && context.mounted) {
          AppLogger.warning(
            'Não foi possível abrir o carrinho após múltiplas tentativas',
            tag: 'SeparationItemsScreen',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Carrinho adicionado, mas não foi possível abrir automaticamente. Tente abrir manualmente.',
              ),
              backgroundColor: AppColors.warning,
              duration: UIConstants.snackBarMediumDuration,
            ),
          );
        }
      }
    }
  }

  bool _canAddCart(SeparateConsultationModel? separation) {
    if (separation == null) return false;

    return separation.situacao == ExpeditionSituation.aguardando ||
        separation.situacao == ExpeditionSituation.separando;
  }

  Future<bool> _openSeparationForNewestCart(BuildContext context, SeparationItemsViewModel viewModel) async {
    try {
      final userSessionService = locator<UserSessionService>();
      final appUser = await userSessionService.loadUserSession();
      final userModel = appUser?.userSystemModel;

      if (!context.mounted) {
        return false;
      }

      final availableCarts = viewModel.carts
          .where(
            (cart) =>
                cart.situacao == ExpeditionSituation.aguardando ||
                cart.situacao == ExpeditionSituation.separado ||
                cart.situacao == ExpeditionSituation.conferido ||
                cart.situacao == ExpeditionSituation.separando,
          )
          .toList();

      if (availableCarts.isEmpty) {
        AppLogger.debug(
          'Nenhum carrinho disponível para separação. Total de carrinhos: ${viewModel.carts.length}',
          tag: 'SeparationItemsScreen',
        );
        return false;
      }

      availableCarts.sort((a, b) {
        if (a.situacao == ExpeditionSituation.separando && b.situacao != ExpeditionSituation.separando) {
          return -1;
        }
        if (a.situacao != ExpeditionSituation.separando && b.situacao == ExpeditionSituation.separando) {
          return 1;
        }

        return b.dataInicio.compareTo(a.dataInicio);
      });

      final newestCart = availableCarts.first;

      AppLogger.debug(
        'Abrindo carrinho: ${newestCart.codCarrinho} (${newestCart.nomeCarrinho}), situação: ${newestCart.situacao.description}',
        tag: 'SeparationItemsScreen',
      );

      if (!context.mounted) {
        return false;
      }

      context.push(
        AppRouter.cardPicking,
        extra: {
          'cart': newestCart,
          'userModel': userModel,
        },
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao abrir separação do carrinho mais recente',
        tag: 'SeparationItemsScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir separação: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return false;
    }
  }
}
