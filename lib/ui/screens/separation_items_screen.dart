import 'dart:async';

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
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_params.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_params.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_usecase.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_params.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_usecase.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/utils/print_failure_message_helper.dart';
import 'package:data7_expedicao/domain/usecases/get_default_printer/get_default_printer_usecase.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_params.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_usecase.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

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
      setState(() {});
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
      final resolveUseCase = locator<ResolveSeparationUserLinkUseCase>();
      final result = await resolveUseCase.call(
        ResolveSeparationUserLinkParams(
          separation: widget.separation,
          codUsuario: currentUserId,
          codSetorEstoque: userSectorStock,
        ),
      );
      if (!mounted) return;
      if (result.isError()) {
        _showErrorAndGoBack(UIConstants.separationLinkCheckFailedMessage);
        return;
      }
      if (result.getOrNull() != true && mounted) {
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
            Consumer<SeparationItemsViewModel>(
              builder: (context, viewModel, child) {
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
                          if ((_tabController.index == 1 && viewModel.hasActiveItemsFilters) ||
                              (_tabController.index == 0 && viewModel.hasActiveCartsFilters))
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Consumer<SeparationItemsViewModel>(
        builder: (context, viewModel, child) {
          if (_tabController.index == 2) return const SizedBox.shrink();
          if (_tabController.index != 0) return const SizedBox.shrink();
          if (!_canAddCart(viewModel.separation)) return const SizedBox.shrink();

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
      final printer = await locator<GetDefaultPrinterUseCase>().call();
      if (!mounted) return;

      if (printer == null) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Nenhuma impressora padrão configurada para impressão.'),
            backgroundColor: AppColors.warning,
            action: SnackBarAction(label: 'Configurar', onPressed: () => context.push(AppRouter.printerConfig)),
          ),
        );
        return;
      }

      final appUser = await locator<IUserSessionService>().loadUserSession();
      if (!mounted) return;

      final separatorName = appUser?.userSystemModel?.nomeUsuario ?? appUser?.nome;
      final userSectorStock = appUser?.userSystemModel?.codSetorEstoque;
      final userSectorName = appUser?.userSystemModel?.nomeSetorEstoque;

      final printUseCase = locator<PrintExpeditionTicketUseCase>();
      final result = await printUseCase.call(
        PrintExpeditionTicketParams(
          codEmpresa: widget.separation.codEmpresa,
          codSepararEstoque: widget.separation.codSepararEstoque,
          printer: printer,
          separatorName: separatorName,
          codSetorEstoque: (userSectorStock != null && userSectorStock > 0) ? userSectorStock : null,
          codUsuario: appUser?.userSystemModel?.codUsuario,
        ),
      );

      if (!mounted) return;

      final success = result.getOrNull();
      if (success != null) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Impressão enviada para ${printer.name} (${printer.ip}:${printer.port}).'),
            backgroundColor: AppColors.info,
          ),
        );
        return;
      }

      final failure = result.exceptionOrNull();

      String errorMessage;
      if (failure is DataFailure && failure.code == 'NOT_FOUND') {
        if (userSectorStock != null && userSectorStock > 0) {
          errorMessage =
              'Não existem itens do setor $userSectorStock ($userSectorName) para imprimir nesta separação.\n'
              'Usuário: $separatorName';
        } else {
          errorMessage =
              'Não existem itens para imprimir nesta separação.\n'
              'Usuário: $separatorName';
        }
      } else {
        errorMessage = const PrintFailureMessageHelper().build(failure, context: PrintFailureContext.separation);
      }

      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: AppColors.warning));
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
      final getSeparationUseCase = locator<GetSeparationConsultationUseCase>();
      final freshResult = await getSeparationUseCase.call(
        GetSeparationConsultationParams(
          codEmpresa: separation.codEmpresa,
          codSepararEstoque: separation.codSepararEstoque,
        ),
      );

      if (!context.mounted) return;

      if (freshResult.isError()) {
        final failure = freshResult.exceptionOrNull();
        final message = failure is AppFailure
            ? failure.userMessage
            : (failure?.toString() ?? 'Erro ao consultar separação');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
            duration: UIConstants.snackBarLongDuration,
          ),
        );
        return;
      }

      final freshSeparation = freshResult.getOrNull();
      if (freshSeparation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Separação não encontrada'),
            backgroundColor: AppColors.error,
            duration: UIConstants.snackBarLongDuration,
          ),
        );
        return;
      }

      if (!_canAddCart(freshSeparation)) {
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
        return;
      }

      final userSessionService = locator<IUserSessionService>();
      final appUser = await userSessionService.loadUserSession();
      final codUsuario = appUser?.userSystemModel?.codUsuario;
      final codSetorEstoque = appUser?.userSystemModel?.codSetorEstoque;

      if (codUsuario == null || codUsuario <= 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Usuário não identificado. Por favor, faça login novamente.'),
              backgroundColor: AppColors.error,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
        }
        return;
      }

      if (codSetorEstoque != null && codSetorEstoque > 0) {
        final resolveUseCase = locator<ResolveSeparationUserLinkUseCase>();
        final resolveResult = await resolveUseCase.call(
          ResolveSeparationUserLinkParams(
            separation: freshSeparation,
            codUsuario: codUsuario,
            codSetorEstoque: codSetorEstoque,
          ),
        );
        if (!context.mounted) return;
        if (resolveResult.isError()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(UIConstants.separationLinkCheckFailedMessage),
              backgroundColor: AppColors.error,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
          return;
        }
        if (resolveResult.getOrNull() != true) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(UIConstants.separationNotAssignedToUserMessage),
                backgroundColor: AppColors.error,
                duration: UIConstants.snackBarLongDuration,
              ),
            );
          }
          return;
        }

        final completionUseCase = locator<CheckSeparationUserSectorCompletionUseCase>();
        final completionResult = await completionUseCase.call(
          CheckSeparationUserSectorCompletionParams(
            codEmpresa: freshSeparation.codEmpresa,
            codSepararEstoque: freshSeparation.codSepararEstoque,
            codSetorEstoque: codSetorEstoque,
            codUsuario: codUsuario,
          ),
        );
        if (!context.mounted) return;
        if (completionResult.isError()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Nao foi possivel validar se o setor ja foi concluido. Tente novamente.'),
              backgroundColor: AppColors.error,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
          return;
        }

        if (completionResult.getOrNull() == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Seu setor de estoque ja esta concluido nesta separacao. Nao e permitido incluir novos carrinhos.',
              ),
              backgroundColor: AppColors.warning,
              duration: UIConstants.snackBarLongDuration,
            ),
          );
          return;
        }
      }

      if (!context.mounted) return;

      viewModel.updateSeparation(freshSeparation);

      final result = await context.push<bool>(
        AppRouter.addCart,
        extra: {'codEmpresa': freshSeparation.codEmpresa, 'codSepararEstoque': freshSeparation.codSepararEstoque},
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
          AppLogger.debug(
            'Primeira tentativa falhou, tentando novamente após refresh...',
            tag: 'SeparationItemsScreen',
          );
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
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                duration: UIConstants.snackBarMediumDuration,
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isValidatingAddCart = false);
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
      final userSessionService = locator<IUserSessionService>();
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

      unawaited(
        context.push<Object?>(AppRouter.cardPicking, extra: {'cart': newestCart, 'userModel': userModel}).then((
          result,
        ) {
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
}
