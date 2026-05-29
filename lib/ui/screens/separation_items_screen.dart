import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_items_viewmodel.dart';
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
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_usecase.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_usecase.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/usecases/get_default_printer/get_default_printer_usecase.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_usecase.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_success.dart';
import 'package:data7_expedicao/presentation/coordinators/separation_print_coordinator.dart';
import 'package:data7_expedicao/presentation/coordinators/separation_user_link_coordinator.dart';
import 'package:data7_expedicao/presentation/coordinators/add_cart_flow_coordinator.dart';

class SeparationItemsScreen extends StatefulWidget {
  final SeparateConsultationModel separation;

  const SeparationItemsScreen({super.key, required this.separation});

  @override
  State<SeparationItemsScreen> createState() => _SeparationItemsScreenState();
}

class _SeparationItemsScreenState extends State<SeparationItemsScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _cartsScrollController = ScrollController();
  final _itemsScrollController = ScrollController();
  bool _isPrinting = false;
  bool _isValidatingAddCart = false;

  /// Bug QQQQQQQ: cache do viewModel para uso seguro no dispose().
  /// Mesmo padrao do Bug WWWWWW corrigido em CardPickingScreen.
  /// Sem isso, dispose() chamava context.read e PODIA falhar com
  /// ProviderNotFoundException → stopCartEventMonitoring nao executava
  /// → listener vazado no socket repository.
  SeparationItemsViewModel? _vmRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      // Item 7: evita setState a cada tick da animação de troca de aba.
      // Só reage quando o índice final é confirmado (não durante a animação).
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _initializeAfterFirstFrame().catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha na inicialização da tela de itens de separação',
            tag: 'SeparationItemsScreen',
            error: e,
            stackTrace: s,
          );
        }),
      );
    });
  }

  Future<void> _initializeAfterFirstFrame() async {
    final viewModel = context.read<SeparationItemsViewModel>();

    final userSessionService = locator<IUserSessionService>();
    final appUser = await userSessionService.loadUserSession();
    final currentUserId = appUser?.userSystemModel?.codUsuario;
    final userSectorStock = appUser?.userSystemModel?.codSetorEstoque;

    if (currentUserId == null) {
      _showErrorAndGoBack('Usuário não identificado');
      return;
    }

    if (userSectorStock != null && userSectorStock > 0) {
      final linkCoordinator = SeparationUserLinkCoordinator(
        resolveSeparationUserLinkUseCase: locator<ResolveSeparationUserLinkUseCase>(),
      );
      final linkResult = await linkCoordinator.resolveLink(
        separation: widget.separation,
        codUsuario: currentUserId,
        codSetorEstoque: userSectorStock,
      );
      if (!mounted) return;
      if (linkResult == SeparationLinkResult.checkFailed) {
        _showErrorAndGoBack(UIConstants.separationLinkCheckFailedMessage);
        return;
      }
      if (linkResult == SeparationLinkResult.notAssigned && mounted) {
        _showErrorAndGoBack(UIConstants.separationNotAssignedToUserMessage);
        return;
      }
    }

    viewModel.loadSeparationItems(widget.separation);
    viewModel.loadSeparationCarts(widget.separation);

    viewModel.startCartEventMonitoring();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vmRef = context.read<SeparationItemsViewModel>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state != AppLifecycleState.resumed) {
      return;
    }

    final viewModel = _vmRef;
    if (viewModel == null) {
      return;
    }

    unawaited(
      viewModel.resyncVisibleDataSilently().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao sincronizar itens da separacao no retorno da tela',
          tag: 'SeparationItemsScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _vmRef?.stopCartEventMonitoring();
    } catch (e, stackTrace) {
      AppLogger.debug(
        'Erro ao parar monitoramento de eventos',
        tag: 'SeparationItemsScreen',
        error: e,
        stackTrace: stackTrace,
      );
    }
    _vmRef = null;

    _tabController.dispose();
    _searchController.dispose();
    _cartsScrollController.dispose();
    _itemsScrollController.dispose();
    super.dispose();
  }

  void _showErrorAndGoBack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error, duration: const Duration(seconds: 3)),
    );
    if (mounted) {
      context.pop();
    }
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
            // Item 8: Selector por campo em vez de Consumer amplo. As ações
            // da AppBar só dependem dos flags de filtros ativos do ViewModel.
            Selector<SeparationItemsViewModel, ({bool hasActiveItemsFilters, bool hasActiveCartsFilters})>(
              selector: (_, vm) => (
                hasActiveItemsFilters: vm.hasActiveItemsFilters,
                hasActiveCartsFilters: vm.hasActiveCartsFilters,
              ),
              builder: (context, filters, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _isPrinting ? null : () => _onPrintTicket(context),
                      icon: _isPrinting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.print_outlined),
                      tooltip: 'Imprimir lista de separação',
                    ),

                    IconButton(
                      onPressed: () => _showFilterModal(context),
                      icon: Stack(
                        children: [
                          const Icon(Icons.filter_alt),
                          if ((_tabController.index == 1 && filters.hasActiveItemsFilters) ||
                              (_tabController.index == 0 && filters.hasActiveCartsFilters))
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      tooltip: _tabController.index == 1 ? 'Filtros de Produtos' : 'Filtros de Carrinhos',
                    ),

                    IconButton(
                      onPressed: () => _refreshData(context.read<SeparationItemsViewModel>()),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Selector<SeparationItemsViewModel, ExpeditionSituation?>(
        // Item 8: o FAB só depende da situação da separação atual.
        selector: (_, vm) => vm.separation?.situacao,
        builder: (context, situacao, child) {
          if (_tabController.index == 2) return const SizedBox.shrink();
          if (_tabController.index != 0) return const SizedBox.shrink();
          if (!_canAddCartSituacao(situacao)) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Semantics(
              button: true,
              label: 'Incluir Carrinho',
              hint: 'Adicionar novo carrinho à separação',
              child: FloatingActionButton.extended(
                heroTag: 'addCart',
                onPressed: _isValidatingAddCart ? null : () => _onAddCart(context),
                icon: _isValidatingAddCart
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add_shopping_cart),
                label: Text(_isValidatingAddCart ? 'Verificando...' : 'Incluir Carrinho'),
                tooltip: 'Incluir novo carrinho na separação',
              ),
            ),
          );
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
    unawaited(
      viewModel.refresh().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao atualizar itens da separação',
          tag: 'SeparationItemsScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  Future<void> _onPrintTicket(BuildContext context) async {
    if (_isPrinting) return;

    setState(() => _isPrinting = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      final coordinator = SeparationPrintCoordinator(
        getDefaultPrinterUseCase: locator<GetDefaultPrinterUseCase>(),
        userSessionService: locator<IUserSessionService>(),
        printExpeditionTicketUseCase: locator<PrintExpeditionTicketUseCase>(),
      );

      final result = await coordinator.printSeparationTicket(
        codEmpresa: widget.separation.codEmpresa,
        codSepararEstoque: widget.separation.codSepararEstoque,
      );

      if (!mounted) return;

      switch (result) {
        case PrintTicketNoPrinterConfigured():
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Nenhuma impressora padrão configurada para impressão.'),
              backgroundColor: AppColors.warning,
              action: SnackBarAction(label: 'Configurar', onPressed: () => context.push(AppRouter.printerConfig)),
            ),
          );
        case PrintTicketSent(:final printer):
          messenger.showSnackBar(
            SnackBar(
              content: Text('Impressão enviada para ${printer.name} (${printer.ip}:${printer.port}).'),
              backgroundColor: AppColors.info,
            ),
          );
        case PrintTicketFailed(:final message):
          messenger.showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.warning));
        case PrintTicketError():
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Erro ao imprimir separação. Tente novamente.'),
              backgroundColor: AppColors.error,
            ),
          );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao imprimir separação', tag: 'SeparationItemsScreen', error: e, stackTrace: stackTrace);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Erro ao imprimir separação. Tente novamente.'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  void _showFilterModal(BuildContext context) {
    final viewModel = context.read<SeparationItemsViewModel>();

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (modalContext) {
          if (_tabController.index == 1) {
            return SeparateItemsFilterModal(viewModel: viewModel);
          }
          return CartsFilterModal(viewModel: viewModel);
        },
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir filtro de itens/carrinhos',
          tag: 'SeparationItemsScreen',
          error: e,
          stackTrace: s,
        );
      }),
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

    final separation = viewModel.separation;
    if (separation == null) return;

    setState(() => _isValidatingAddCart = true);

    try {
      final coordinator = AddCartFlowCoordinator(
        getSeparationConsultationUseCase: locator<GetSeparationConsultationUseCase>(),
        userSessionService: locator<IUserSessionService>(),
        resolveSeparationUserLinkUseCase: locator<ResolveSeparationUserLinkUseCase>(),
        checkSeparationUserSectorCompletionUseCase: locator<CheckSeparationUserSectorCompletionUseCase>(),
      );

      final result = await coordinator.validate(separation);

      if (!context.mounted) return;

      switch (result) {
        case AddCartConsultFailed(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
        case AddCartSeparationNotFound():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Separação não encontrada'),
              backgroundColor: AppColors.error,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
        case AddCartSituationNotAllowed(:final freshSeparation):
          viewModel.updateSeparation(freshSeparation);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Não é possível adicionar carrinho. Situação atual: ${freshSeparation.situacao.description}\n'
                  'Permitido apenas em: Aguardando ou Separando',
                ),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                duration: UIConstants.snackBarLongDuration,
              ),
            );
          }
        case AddCartUserNotIdentified():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Usuário não identificado. Por favor, faça login novamente.'),
              backgroundColor: AppColors.error,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
        case AddCartLinkCheckFailed():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(UIConstants.separationLinkCheckFailedMessage),
              backgroundColor: AppColors.error,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
        case AddCartNotAssigned():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(UIConstants.separationNotAssignedToUserMessage),
              backgroundColor: AppColors.error,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
        case AddCartCompletionCheckFailed():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Nao foi possivel validar se o setor ja foi concluido. Tente novamente.'),
              backgroundColor: AppColors.error,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
        case AddCartSectorAlreadyCompleted():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Seu setor de estoque ja esta concluido nesta separacao. Nao e permitido incluir novos carrinhos.',
              ),
              backgroundColor: AppColors.warning,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
        case AddCartAllowed(:final freshSeparation):
          viewModel.updateSeparation(freshSeparation);

          final pushResult = await context.push<AddCartSuccess?>(
            AppRouter.addCart,
            extra: {'codEmpresa': freshSeparation.codEmpresa, 'codSepararEstoque': freshSeparation.codSepararEstoque},
          );

          if (pushResult != null) {
            AppLogger.debug(
              'Carrinho adicionado com sucesso, iniciando abertura do carrinho exato...',
              tag: 'SeparationItemsScreen',
            );
            if (!context.mounted) return;
            await _handleAddedCartAutoOpen(context, viewModel, pushResult);
          }
      }
    } finally {
      if (mounted) {
        setState(() => _isValidatingAddCart = false);
      }
    }
  }

  bool _canAddCartSituacao(ExpeditionSituation? situacao) {
    return situacao == ExpeditionSituation.aguardando || situacao == ExpeditionSituation.separando;
  }

  Future<void> _handleAddedCartAutoOpen(
    BuildContext context,
    SeparationItemsViewModel viewModel,
    AddCartSuccess addCartResult,
  ) async {
    const retryDelays = <Duration>[Duration.zero, Duration(milliseconds: 250), Duration(milliseconds: 500)];

    for (final retryDelay in retryDelays) {
      if (!context.mounted) {
        return;
      }

      if (retryDelay > Duration.zero) {
        await Future.delayed(retryDelay);
        if (!context.mounted) {
          return;
        }
      }

      await viewModel.refresh();
      if (!context.mounted) {
        return;
      }

      final cartOpened = await _openSeparationForAddedCart(context, viewModel, addCartResult);
      if (cartOpened) {
        return;
      }
    }

    if (context.mounted) {
      AppLogger.warning(
        'Carrinho ${addCartResult.addedCart.codCarrinho} adicionado, mas nao foi encontrado para abertura automatica',
        tag: 'SeparationItemsScreen',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Carrinho adicionado, mas não foi possível abrir automaticamente. Tente abrir manualmente.',
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          duration: UIConstants.snackBarMediumDuration,
        ),
      );
    }
  }

  Future<bool> _openSeparationForAddedCart(
    BuildContext context,
    SeparationItemsViewModel viewModel,
    AddCartSuccess addCartResult,
  ) async {
    try {
      final userSessionService = locator<IUserSessionService>();
      final appUser = await userSessionService.loadUserSession();
      final userModel = appUser?.userSystemModel;

      if (!context.mounted) {
        return false;
      }

      final addedCart = _findAddedCartForAutoOpen(viewModel, addCartResult);
      if (addedCart == null) {
        AppLogger.debug(
          'Carrinho adicionado ${addCartResult.addedCart.codCarrinho} ainda nao disponivel para abertura. '
          'Total atual: ${viewModel.carts.length}',
          tag: 'SeparationItemsScreen',
        );
        return false;
      }

      AppLogger.debug(
        'Abrindo carrinho adicionado: ${addedCart.codCarrinho} '
        '(${addedCart.nomeCarrinho}), situação: ${addedCart.situacao.description}',
        tag: 'SeparationItemsScreen',
      );

      if (!context.mounted) {
        return false;
      }

      unawaited(
        context.push<Object?>(AppRouter.cardPicking, extra: {'cart': addedCart, 'userModel': userModel}).then((result) {
          if (result == 'save_cart' && context.mounted) {
            context.go(AppRouter.separation);
          }
        }),
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
            content: const Text('Erro ao abrir separação. Tente novamente.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return false;
    }
  }

  ExpeditionCartRouteInternshipConsultationModel? _findAddedCartForAutoOpen(
    SeparationItemsViewModel viewModel,
    AddCartSuccess addCartResult,
  ) {
    final matchingCarts = viewModel.carts.where((cart) {
      final matchesCart = cart.codCarrinho == addCartResult.addedCart.codCarrinho;
      final matchesRoute =
          addCartResult.codCarrinhoPercurso == null || cart.codCarrinhoPercurso == addCartResult.codCarrinhoPercurso;
      return matchesCart && matchesRoute && _isCartAvailableForAutoOpen(cart);
    }).toList();

    if (matchingCarts.isEmpty) {
      return null;
    }

    matchingCarts.sort((a, b) => b.dataInicio.compareTo(a.dataInicio));
    return matchingCarts.first;
  }

  bool _isCartAvailableForAutoOpen(ExpeditionCartRouteInternshipConsultationModel cart) {
    return cart.situacao == ExpeditionSituation.aguardando ||
        cart.situacao == ExpeditionSituation.separado ||
        cart.situacao == ExpeditionSituation.conferido ||
        cart.situacao == ExpeditionSituation.separando;
  }
}
