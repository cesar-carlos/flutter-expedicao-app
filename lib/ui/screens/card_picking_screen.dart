import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/picking_actions_bottom_bar.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/picking_card_scan.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/cart_status_warning.dart';
import 'package:data7_expedicao/ui/widgets/cart_title_with_connection_status.dart';
import 'package:data7_expedicao/ui/widgets/cart_status_bar.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class CardPickingScreen extends StatefulWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final UserSystemModel? userModel;

  const CardPickingScreen({super.key, required this.cart, this.userModel});

  @override
  State<CardPickingScreen> createState() => _CardPickingScreenState();
}

class _CardPickingBodyState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  const _CardPickingBodyState({required this.isLoading, required this.hasError, required this.errorMessage});

  factory _CardPickingBodyState.fromViewModel(CardPickingViewModel vm) {
    return _CardPickingBodyState(isLoading: vm.isLoading, hasError: vm.hasError, errorMessage: vm.errorMessage);
  }
}

class _CardPickingScreenState extends State<CardPickingScreen> with WidgetsBindingObserver {
  /// Bug WWWWWW: cache do viewModel para uso no dispose().
  ///
  /// Antes, dispose() chamava `context.read<CardPickingViewModel>()` que
  /// PODIA falhar com ProviderNotFoundException quando o
  /// ChangeNotifierProvider ja havia sido desmontado da arvore. O
  /// try/catch escondia o erro mas o resultado era pior: o listener
  /// de eventos do carrinho ficava VAZADO no socket — cada navegacao
  /// para outra tela e volta acumulava listeners, e cada evento de
  /// carrinho era processado N vezes.
  ///
  /// Capturamos a referencia em didChangeDependencies (que roda APOS
  /// o tree estar pronto) e usamos a referencia direta no dispose,
  /// garantindo que stopCartEventMonitoring sempre execute.
  CardPickingViewModel? _vmRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<CardPickingViewModel>();
      unawaited(
        viewModel.initializeCart(widget.cart, userModel: widget.userModel).catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha ao inicializar carrinho no picking',
            tag: 'CardPickingScreen',
            error: e,
            stackTrace: s,
          );
        }),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vmRef = context.read<CardPickingViewModel>();
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
          'Falha ao sincronizar picking no retorno da tela',
          tag: 'CardPickingScreen',
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
    } catch (e) {
      AppLogger.error('Error stopping cart event monitoring: $e', tag: 'CardPickingScreen');
    }
    _vmRef = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: CartTitleWithConnectionStatus(cartName: widget.cart.nomeCarrinho),
        showSocketStatus: false,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), tooltip: 'Voltar'),
        actions: [
          Consumer<CardPickingViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        unawaited(
                          viewModel.refresh().catchError((Object e, StackTrace s) {
                            AppLogger.warning(
                              'Falha ao atualizar picking',
                              tag: 'CardPickingScreen',
                              error: e,
                              stackTrace: s,
                            );
                          }),
                        );
                      },
                icon: viewModel.isLoading ? child! : const Icon(Icons.refresh),
                tooltip: 'Atualizar dados',
              );
            },
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) => _onMenuItemSelected(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.pending_actions, color: AppColors.warning, size: 20),
                    SizedBox(width: 12),
                    Text('Produtos Pendentes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    SizedBox(width: 12),
                    Text('Produtos Separados'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'cart_info',
                child: Row(
                  children: [Icon(Icons.info_outline, size: 20), SizedBox(width: 12), Text('Informações do Carrinho')],
                ),
              ),
              const PopupMenuItem(
                value: 'progress',
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Progresso da Separação'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
            tooltip: 'Mais opções',
          ),
        ],
      ),
      body: Column(
        children: [
          const CartStatusBar(),
          const CartStatusWarning(),
          Expanded(
            child: Selector<CardPickingViewModel, _CardPickingBodyState>(
              selector: (_, vm) => _CardPickingBodyState.fromViewModel(vm),
              builder: (context, state, _) {
                final viewModel = context.read<CardPickingViewModel>();
                return _buildBody(context, viewModel, state);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          Selector<CardPickingViewModel, ({double progress, int completed, int total, bool isComplete})>(
            selector: (_, vm) => (
              progress: vm.progress,
              completed: vm.completedItems,
              total: vm.totalItems,
              isComplete: vm.isPickingComplete,
            ),
            builder: (context, data, _) {
              final viewModel = context.read<CardPickingViewModel>();
              return PickingActionsBottomBar(viewModel: viewModel, cart: widget.cart);
            },
          ),
    );
  }

  Widget _buildBody(BuildContext context, CardPickingViewModel viewModel, _CardPickingBodyState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Carregando dados do picking...')],
        ),
      );
    }

    if (state.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar dados',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Erro desconhecido',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  unawaited(
                    viewModel.retry().catchError((Object e, StackTrace s) {
                      AppLogger.warning(
                        'Falha ao repetir carregamento do picking',
                        tag: 'CardPickingScreen',
                        error: e,
                        stackTrace: s,
                      );
                    }),
                  );
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PickingCardScan(cart: widget.cart, viewModel: viewModel),
        ),
      ],
    );
  }

  void _onMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'pending':
        _showProductList(context, 'pending');
        break;
      case 'completed':
        _showProductList(context, 'completed');
        break;
      case 'cart_info':
        _showCartInfo(context);
        break;
      case 'progress':
        _showProgressInfo(context);
        break;
    }
  }

  Future<void> _showProductList(BuildContext context, String filter) async {
    final viewModel = context.read<CardPickingViewModel>();

    await context.push(
      '/home/picking-products-list',
      extra: {'filterType': filter, 'viewModel': viewModel, 'cart': widget.cart},
    );

    if (context.mounted) {
      await viewModel.refresh();
    }
  }

  void _showCartInfo(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: Theme.of(dialogContext).colorScheme.primary),
              const SizedBox(width: 8),
              const Expanded(child: Text('Informações do Carrinho', overflow: TextOverflow.ellipsis)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Código:', '#${widget.cart.codCarrinho}'),
              _buildInfoRow('Nome:', widget.cart.nomeCarrinho),
              _buildInfoRow('Status:', widget.cart.situacao.description),
              if (widget.cart.nomeSetorEstoque != null) _buildInfoRow('Setor:', widget.cart.nomeSetorEstoque!),
              if (widget.cart.carrinhoAgrupadorCode.isNotEmpty)
                _buildInfoRow('Agrupador:', widget.cart.carrinhoAgrupadorCode),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Fechar'))],
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning('Falha ao exibir informações do carrinho', tag: 'CardPickingScreen', error: e, stackTrace: s);
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showProgressInfo(BuildContext context) {
    final viewModel = context.read<CardPickingViewModel>();
    final totalItems = viewModel.items.length;
    final completedItems = viewModel.items.where((item) => viewModel.isItemCompleted(item.item)).length;
    final pendingItems = totalItems - completedItems;
    final progress = totalItems > 0 ? (completedItems / totalItems) : 0.0;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.analytics_outlined, color: Theme.of(dialogContext).colorScheme.primary),
              const SizedBox(width: 8),
              const Expanded(child: Text('Progresso da Separação', overflow: TextOverflow.ellipsis, maxLines: 1)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progresso Geral',
                          style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: progress >= 1.0 ? AppColors.success : Theme.of(dialogContext).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(dialogContext).colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? AppColors.success : Theme.of(dialogContext).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            '$completedItems',
                            style: Theme.of(
                              dialogContext,
                            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                          Text(
                            'Separados',
                            style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(color: AppColors.green700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.pending_actions, color: AppColors.warning, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            '$pendingItems',
                            style: Theme.of(
                              dialogContext,
                            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.warning),
                          ),
                          Text(
                            'Pendentes',
                            style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(dialogContext).colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações do Carrinho',
                      style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Código: ${widget.cart.codCarrinho}'),
                    Text('Nome: ${widget.cart.nomeCarrinho}'),
                    Text('Origem: ${widget.cart.origem.description}'),
                    Text('Situação: ${widget.cart.situacao.description}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Fechar'))],
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning('Falha ao exibir progresso da separação', tag: 'CardPickingScreen', error: e, stackTrace: s);
      }),
    );
  }
}
