import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/ui/widgets/common/custom_app_bar.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/ui/widgets/picking_products_list/picking_product_list_item.dart';
import 'package:exp/ui/widgets/separated_products/separated_product_item.dart';
import 'package:exp/ui/widgets/picking_products_list/pending_products_filter_modal.dart';
import 'package:exp/domain/viewmodels/separated_products_viewmodel.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/ui/widgets/separated_products/separated_products_cart_status_warning.dart';
import 'package:exp/ui/widgets/separated_products_title_with_connection_status.dart';
import 'package:exp/ui/widgets/pending_products_title_with_connection_status.dart';

class PickingProductsListScreen extends StatefulWidget {
  final String filterType; // 'pending' ou 'completed'
  final CardPickingViewModel viewModel;
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final bool isReadOnly; // Novo parâmetro para modo somente leitura

  const PickingProductsListScreen({
    super.key,
    required this.filterType,
    required this.viewModel,
    required this.cart,
    this.isReadOnly = false, // Padrão é false (permite edição)
  });

  @override
  State<PickingProductsListScreen> createState() => _PickingProductsListScreenState();
}

class _PickingProductsListScreenState extends State<PickingProductsListScreen> {
  late SeparatedProductsViewModel _separatedProductsViewModel;
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();

    // Se for a tela de produtos separados, criar e inicializar o ViewModel
    if (widget.filterType == 'completed') {
      _separatedProductsViewModel = SeparatedProductsViewModel();

      // Adicionar listener para detectar quando um item é cancelado
      _separatedProductsViewModel.addListener(_onSeparatedProductsChanged);

      // Carregar produtos separados após o frame atual
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _separatedProductsViewModel.loadSeparatedProducts(widget.cart, isReadOnly: widget.isReadOnly);
      });
    }
  }

  void _onSeparatedProductsChanged() {
    // Marcar que precisa atualizar quando voltar para a tela anterior
    if (!_separatedProductsViewModel.isLoading && !_separatedProductsViewModel.isCancelling) {
      _needsRefresh = true;
    }
  }

  @override
  void dispose() {
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
    final title = isPendingFilter ? 'Produtos Pendentes' : 'Produtos Separados';
    final icon = isPendingFilter ? Icons.pending_actions : Icons.check_circle;
    final iconColor = isPendingFilter ? Colors.orange : Colors.green;

    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop && _needsRefresh && widget.filterType == 'completed') {
          // Atualizar o CardPickingViewModel quando voltar da tela de produtos separados
          await widget.viewModel.refresh();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: widget.filterType == 'completed'
              ? const SeparatedProductsTitleWithConnectionStatus()
              : widget.filterType == 'pending'
              ? const PendingProductsTitleWithConnectionStatus()
              : title,
          showSocketStatus: false,
          leading: IconButton(
            onPressed: () async {
              if (_needsRefresh && widget.filterType == 'completed') {
                await widget.viewModel.refresh();
              }
              if (context.mounted) {
                context.pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar',
          ),
          actions: [
            // Botão de filtro apenas para produtos pendentes
            if (widget.filterType == 'pending')
              Consumer<CardPickingViewModel>(
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
                              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                    tooltip: 'Filtros de Produtos Pendentes',
                  );
                },
              ),
          ],
        ),
        body: widget.filterType == 'completed'
            ? ChangeNotifierProvider<SeparatedProductsViewModel>.value(
                value: _separatedProductsViewModel,
                child: Consumer<SeparatedProductsViewModel>(
                  builder: (context, separatedViewModel, child) {
                    return _buildSeparatedProductsBody(
                      context,
                      theme,
                      colorScheme,
                      icon,
                      iconColor,
                      separatedViewModel,
                    );
                  },
                ),
              )
            : Consumer<CardPickingViewModel>(
                builder: (context, viewModel, child) {
                  return _buildPendingProductsBody(context, theme, colorScheme, icon, iconColor);
                },
              ),
      ),
    );
  }

  // Método para produtos pendentes (usando CardPickingViewModel)
  Widget _buildPendingProductsBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    Color iconColor,
  ) {
    if (widget.viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Carregando produtos...')],
        ),
      );
    }

    if (widget.viewModel.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar produtos',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.viewModel.errorMessage ?? 'Erro desconhecido',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => widget.viewModel.retry(), child: const Text('Tentar Novamente')),
            ],
          ),
        ),
      );
    }

    // Filtrar produtos pendentes
    final pendingItems = widget.viewModel.items.where((item) => !widget.viewModel.isItemCompleted(item.item)).toList();

    if (pendingItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: iconColor.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('Nenhum produto pendente', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Todos os produtos já foram separados!',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header com estatísticas
        _buildHeader(context, theme, colorScheme, icon, iconColor, pendingItems.length),

        // Lista de produtos pendentes
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingItems.length,
            itemBuilder: (context, index) {
              final item = pendingItems[index];
              return PickingProductListItem(
                item: item,
                viewModel: widget.viewModel,
                isCompleted: false,
                allowEdit: false,
              );
            },
          ),
        ),
      ],
    );
  }

  // Método para produtos separados (usando SeparatedProductsViewModel)
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
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Carregando produtos separados...')],
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
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar produtos',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage ?? 'Erro desconhecido',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => viewModel.retry(), child: const Text('Tentar Novamente')),
            ],
          ),
        ),
      );
    }

    if (viewModel.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: iconColor.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('Nenhum produto separado', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Ainda não há produtos separados neste carrinho.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Aviso de status do carrinho
        const SeparatedProductsCartStatusWarning(),

        // Header com estatísticas
        _buildHeader(context, theme, colorScheme, icon, iconColor, viewModel.items.length),

        // Lista de produtos separados
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await viewModel.refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    Color iconColor,
    int itemCount,
  ) {
    final title = widget.filterType == 'pending' ? 'Produtos Pendentes' : 'Produtos Separados';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: iconColor.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  '$itemCount ${itemCount == 1 ? 'produto' : 'produtos'}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: iconColor.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(16)),
            child: Text(
              '$itemCount',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PendingProductsFilterModal(viewModel: widget.viewModel),
    );
  }
}
