import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/ui/widgets/card_picking/picking_actions_bottom_bar.dart';
import 'package:exp/ui/widgets/card_picking/picking_card_scan.dart';
import 'package:exp/ui/screens/picking_products_list_screen.dart';
import 'package:exp/ui/widgets/common/custom_app_bar.dart';
import 'package:exp/ui/widgets/card_picking/cart_status_warning.dart';
import 'package:exp/ui/widgets/cart_title_with_connection_status.dart';
import 'package:exp/ui/widgets/cart_status_bar.dart';

class CardPickingScreen extends StatefulWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final UserSystemModel? userModel;

  const CardPickingScreen({super.key, required this.cart, this.userModel});

  @override
  State<CardPickingScreen> createState() => _CardPickingScreenState();
}

class _CardPickingScreenState extends State<CardPickingScreen> {
  @override
  void initState() {
    super.initState();

    // Inicializar dados do carrinho quando a tela é carregada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<CardPickingViewModel>();
      viewModel.initializeCart(widget.cart, userModel: widget.userModel);
    });
  }

  @override
  void dispose() {
    // Para o monitoramento de eventos de carrinho
    try {
      final viewModel = context.read<CardPickingViewModel>();
      viewModel.stopCartEventMonitoring();
    } catch (e) {
      // Ignora erro se o contexto não estiver mais disponível
    }
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
          // Botão de atualização
          Consumer<CardPickingViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        await viewModel.refresh();
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
                tooltip: 'Atualizar dados',
              );
            },
          ),
          // Menu de três pontos
          PopupMenuButton<String>(
            onSelected: (value) => _onMenuItemSelected(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.pending_actions, color: Colors.orange, size: 20),
                    SizedBox(width: 12),
                    Text('Produtos Pendentes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
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
          // Barra de status do carrinho
          const CartStatusBar(),

          // Aviso de status do carrinho
          const CartStatusWarning(),

          // Conteúdo principal
          Expanded(
            child: Consumer<CardPickingViewModel>(
              builder: (context, viewModel, child) {
                return _buildBody(context, viewModel);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<CardPickingViewModel>(
        builder: (context, viewModel, child) {
          return PickingActionsBottomBar(viewModel: viewModel, cart: widget.cart);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CardPickingViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Carregando dados do picking...')],
        ),
      );
    }

    if (viewModel.hasError) {
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
                viewModel.errorMessage ?? 'Erro desconhecido',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => viewModel.retry(), child: const Text('Tentar Novamente')),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Card com informações do picking
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

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: viewModel,
          child: PickingProductsListScreen(filterType: filter, viewModel: viewModel, cart: widget.cart),
        ),
      ),
    );

    // Recarregar dados do carrinho quando retornar da tela de produtos
    if (context.mounted) {
      await viewModel.refresh();
    }
  }

  void _showCartInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.primary),
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
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics_outlined, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('Progresso da Separação', overflow: TextOverflow.ellipsis, maxLines: 1)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso Geral',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progress >= 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Estatísticas
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          '$completedItems',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        Text(
                          'Separados',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green.shade700),
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
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.pending_actions, color: Colors.orange, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          '$pendingItems',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                        Text(
                          'Pendentes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Informações do carrinho
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações do Carrinho',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
      ),
    );
  }
}
