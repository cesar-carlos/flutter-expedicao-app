import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/ui/widgets/picking_products_list/picking_product_list_item.dart';
import 'package:data7_expedicao/ui/widgets/separated_products/separated_product_item.dart';
import 'package:data7_expedicao/ui/widgets/picking_products_list/pending_products_filter_modal.dart';
import 'package:data7_expedicao/presentation/viewmodels/separated_products_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/separated_products_title_with_connection_status.dart';
import 'package:data7_expedicao/ui/widgets/pending_products_title_with_connection_status.dart';
import 'package:data7_expedicao/ui/widgets/picking_products_list/picking_list_header.dart';
import 'package:data7_expedicao/ui/widgets/picking_products_list/picking_status_views.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class PickingProductsListScreen extends StatefulWidget {
  final String filterType;
  final CardPickingViewModel? viewModel;
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final bool isReadOnly;

  const PickingProductsListScreen({
    super.key,
    required this.filterType,
    this.viewModel,
    required this.cart,
    this.isReadOnly = false,
  });

  @override
  State<PickingProductsListScreen> createState() => _PickingProductsListScreenState();
}

class _PickingProductsListScreenState extends State<PickingProductsListScreen> with WidgetsBindingObserver {
  late SeparatedProductsViewModel _separatedProductsViewModel;
  bool _needsRefresh = false;
  bool _hasLoadedSeparatedProductsSnapshot = false;
  String? _lastSeparatedProductsSnapshot;

  /// Item 4: memoização da lista de pendentes.
  ///
  /// O filtro `items.where(!isItemCompleted)` era recomputado a cada
  /// notificação do ViewModel. Cacheamos o resultado e o recomputamos
  /// apenas quando a assinatura (total de itens + total de completos)
  /// muda. A regra de filtro permanece inalterada.
  List<SeparateItemConsultationModel>? _cachedPendingItems;
  int? _cachedPendingTotal;
  int? _cachedPendingCompleted;

  List<SeparateItemConsultationModel> _computePendingItems(CardPickingViewModel viewModel) {
    final total = viewModel.items.length;
    final completed = viewModel.completedItems;

    final cached = _cachedPendingItems;
    if (cached != null && _cachedPendingTotal == total && _cachedPendingCompleted == completed) {
      return cached;
    }

    final pending = viewModel.items.where((item) => !viewModel.isItemCompleted(item.item)).toList();
    _cachedPendingItems = pending;
    _cachedPendingTotal = total;
    _cachedPendingCompleted = completed;
    return pending;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.filterType == 'completed') {
      _separatedProductsViewModel = SeparatedProductsViewModel();

      _separatedProductsViewModel.addListener(_onSeparatedProductsChanged);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          _separatedProductsViewModel.loadSeparatedProducts(widget.cart, isReadOnly: widget.isReadOnly).catchError((
            Object e,
            StackTrace s,
          ) {
            AppLogger.warning(
              'Falha ao carregar produtos separados (lista)',
              tag: 'PickingProductsListScreen',
              error: e,
              stackTrace: s,
            );
          }),
        );
      });
    }
  }

  void _onSeparatedProductsChanged() {
    if (!_separatedProductsViewModel.isLoading && !_separatedProductsViewModel.isCancelling) {
      final snapshot = _buildSeparatedProductsSnapshot();
      if (!_hasLoadedSeparatedProductsSnapshot) {
        _hasLoadedSeparatedProductsSnapshot = true;
        _lastSeparatedProductsSnapshot = snapshot;
        return;
      }

      if (snapshot != _lastSeparatedProductsSnapshot || _separatedProductsViewModel.hasCartStatusChanged) {
        _needsRefresh = true;
        _lastSeparatedProductsSnapshot = snapshot;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state != AppLifecycleState.resumed || widget.filterType != 'completed') {
      return;
    }

    unawaited(
      _separatedProductsViewModel.resyncVisibleDataSilently().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao sincronizar produtos separados no retorno da tela',
          tag: 'PickingProductsListScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  Future<void> _handleLeadingBack(BuildContext context) async {
    if (context.mounted) {
      context.pop();
    }
  }

  String _buildSeparatedProductsSnapshot() {
    final entries =
        _separatedProductsViewModel.items
            .map(
              (item) => '${item.item}|${item.situacao.code}|${item.quantidade}|${item.dataSeparacao.toIso8601String()}',
            )
            .toList()
          ..sort();
    return entries.join(';');
  }

  Future<void> _refreshParentPickingIfNeeded() async {
    final parentViewModel = widget.viewModel;
    if (!_needsRefresh || widget.filterType != 'completed' || parentViewModel == null) {
      return;
    }

    try {
      await parentViewModel.refresh();
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Falha ao atualizar picking ao sair da lista de separados',
        tag: 'PickingProductsListScreen',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _needsRefresh = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.filterType == 'completed') {
      _separatedProductsViewModel.removeListener(_onSeparatedProductsChanged);
      _separatedProductsViewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isPendingFilter = widget.filterType == 'pending';
    final icon = isPendingFilter ? Icons.pending_actions : Icons.check_circle;
    final iconColor = isPendingFilter ? Colors.orange : Colors.green;

    final scaffold = _buildScaffold(context, theme, colorScheme, icon, iconColor);

    if (widget.filterType == 'completed') {
      return ChangeNotifierProvider<SeparatedProductsViewModel>.value(
        value: _separatedProductsViewModel,
        child: _buildPopScope(scaffold),
      );
    }

    return _buildPopScope(scaffold);
  }

  Widget _buildPopScope(Widget child) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _refreshParentPickingIfNeeded();
        }
      },
      child: child,
    );
  }

  Widget _buildAppBarTitle() {
    switch (widget.filterType) {
      case 'completed':
        return const SeparatedProductsTitleWithConnectionStatus();
      case 'pending':
        return const PendingProductsTitleWithConnectionStatus();
      default:
        return Text(widget.filterType == 'pending' ? 'Produtos Pendentes' : 'Produtos Separados');
    }
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    final actions = <Widget>[];

    if (widget.filterType == 'pending') {
      actions.add(_buildFilterButton(context));
    }

    actions.add(_buildRefreshButton(context));

    return actions;
  }

  Widget _buildFilterButton(BuildContext context) {
    return Consumer<CardPickingViewModel>(
      builder: (context, viewModel, child) {
        return IconButton(
          onPressed: () => _showFilterModal(context),
          icon: Stack(
            children: [
              const Icon(Icons.filter_alt),
              if (viewModel.hasActiveFilters)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          tooltip: 'Filtros de Produtos Pendentes',
        );
      },
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    if (widget.filterType == 'completed') {
      return _buildSeparatedProductsRefreshButton(context);
    } else {
      return _buildPendingProductsRefreshButton(context);
    }
  }

  Widget _buildSeparatedProductsRefreshButton(BuildContext context) {
    return Consumer<SeparatedProductsViewModel>(
      builder: (context, separatedViewModel, child) {
        return IconButton(
          onPressed: separatedViewModel.isLoading
              ? null
              : () {
                  unawaited(
                    separatedViewModel.refresh().catchError((Object e, StackTrace s) {
                      AppLogger.warning(
                        'Falha ao atualizar produtos separados',
                        tag: 'PickingProductsListScreen',
                        error: e,
                        stackTrace: s,
                      );
                    }),
                  );
                },
          icon: separatedViewModel.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                  ),
                )
              : const Icon(Icons.refresh),
          tooltip: 'Atualizar produtos separados',
        );
      },
    );
  }

  Widget _buildPendingProductsRefreshButton(BuildContext context) {
    return Consumer<CardPickingViewModel>(
      builder: (context, viewModel, child) {
        return IconButton(
          onPressed: viewModel.isLoading
              ? null
              : () {
                  unawaited(
                    viewModel.refresh().catchError((Object e, StackTrace s) {
                      AppLogger.warning(
                        'Falha ao atualizar produtos pendentes',
                        tag: 'PickingProductsListScreen',
                        error: e,
                        stackTrace: s,
                      );
                    }),
                  );
                },
          icon: viewModel.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                  ),
                )
              : const Icon(Icons.refresh),
          tooltip: 'Atualizar produtos pendentes',
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    Color iconColor,
  ) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _buildAppBarTitle(),
        showSocketStatus: false,
        leading: IconButton(
          onPressed: () {
            unawaited(
              _handleLeadingBack(context).catchError((Object e, StackTrace s) {
                AppLogger.warning(
                  'Falha não tratada ao voltar da lista de produtos',
                  tag: 'PickingProductsListScreen',
                  error: e,
                  stackTrace: s,
                );
              }),
            );
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
        ),
        actions: _buildAppBarActions(context),
      ),
      body: widget.filterType == 'completed'
          ? Consumer<SeparatedProductsViewModel>(
              builder: (context, separatedViewModel, child) {
                return _buildSeparatedProductsBody(context, theme, colorScheme, icon, iconColor, separatedViewModel);
              },
            )
          : Consumer<CardPickingViewModel>(
              builder: (context, viewModel, child) {
                return _buildPendingProductsBody(context, theme, colorScheme, icon, iconColor);
              },
            ),
    );
  }

  Widget _buildPendingProductsBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    Color iconColor,
  ) {
    final viewModel = widget.viewModel;
    if (viewModel == null) {
      return const Center(child: Text('Picking pendente indisponível'));
    }

    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: UIConstants.defaultPadding),
            Text('Carregando produtos...'),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return PickingErrorView(
        errorMessage: viewModel.errorMessage,
        onRetry: () {
          unawaited(
            viewModel.retry().catchError((Object e, StackTrace s) {
              AppLogger.warning(
                'Falha ao repetir carregamento (pendentes)',
                tag: 'PickingProductsListScreen',
                error: e,
                stackTrace: s,
              );
            }),
          );
        },
      );
    }

    final pendingItems = _computePendingItems(viewModel);

    if (pendingItems.isEmpty) {
      return PickingEmptyView(
        icon: icon,
        iconColor: iconColor,
        title: 'Nenhum produto pendente',
        message: 'Todos os produtos já foram separados!',
      );
    }

    return Column(
      children: [
        PickingListHeader(
          icon: icon,
          iconColor: iconColor,
          title: 'Produtos Pendentes',
          itemCount: pendingItems.length,
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(UIConstants.defaultPadding),
            itemCount: pendingItems.length,
            itemBuilder: (context, index) {
              final item = pendingItems[index];
              return PickingProductListItem(item: item, viewModel: viewModel, isCompleted: false, allowEdit: false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeparatedProductsBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    Color iconColor,
    SeparatedProductsViewModel viewModel,
  ) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: UIConstants.defaultPadding),
            Text('Carregando produtos separados...'),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return PickingErrorView(
        errorMessage: viewModel.errorMessage,
        onRetry: () {
          unawaited(
            viewModel.retry().catchError((Object e, StackTrace s) {
              AppLogger.warning(
                'Falha ao repetir carregamento (separados)',
                tag: 'PickingProductsListScreen',
                error: e,
                stackTrace: s,
              );
            }),
          );
        },
      );
    }

    if (viewModel.items.isEmpty) {
      return PickingEmptyView(
        icon: icon,
        iconColor: iconColor,
        title: 'Nenhum produto separado',
        message: 'Ainda não há produtos separados neste carrinho.',
      );
    }

    return Column(
      children: [
        PickingListHeader(
          icon: icon,
          iconColor: iconColor,
          title: 'Produtos Separados',
          itemCount: viewModel.items.length,
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              try {
                await viewModel.refresh();
              } catch (e, stackTrace) {
                AppLogger.warning(
                  'Falha no pull-to-refresh (separados)',
                  tag: 'PickingProductsListScreen',
                  error: e,
                  stackTrace: stackTrace,
                );
                rethrow;
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(UIConstants.defaultPadding),
              itemCount: viewModel.items.length,
              itemBuilder: (context, index) {
                final item = viewModel.items[index];
                return SeparatedProductItem(item: item, viewModel: viewModel);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterModal(BuildContext context) {
    final viewModel = widget.viewModel;
    if (viewModel == null) {
      return;
    }

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.transparent,
        builder: (_) => PendingProductsFilterModal(viewModel: viewModel),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir modal de filtros de pendentes',
          tag: 'PickingProductsListScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }
}
