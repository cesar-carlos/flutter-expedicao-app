import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/ui/widgets/common/custom_app_bar.dart';
import 'package:exp/ui/widgets/picking_products_list/picking_product_list_item.dart';

class PickingProductsListScreen extends StatelessWidget {
  final String filterType; // 'pending' ou 'completed'
  final CardPickingViewModel viewModel;

  const PickingProductsListScreen({super.key, required this.filterType, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isPendingFilter = filterType == 'pending';
    final title = isPendingFilter ? 'Produtos Pendentes' : 'Produtos Separados';
    final icon = isPendingFilter ? Icons.pending_actions : Icons.check_circle;
    final iconColor = isPendingFilter ? Colors.orange : Colors.green;

    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        showSocketStatus: false,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), tooltip: 'Voltar'),
      ),
      body: Consumer<CardPickingViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(context, theme, colorScheme, icon, iconColor);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, ColorScheme colorScheme, IconData icon, Color iconColor) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Carregando produtos...')],
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

    // Filtrar produtos baseado no tipo
    final filteredItems = _getFilteredItems();

    if (filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: iconColor.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                filterType == 'pending' ? 'Nenhum produto pendente' : 'Nenhum produto separado',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                filterType == 'pending' ? 'Todos os produtos já foram separados!' : 'Ainda não há produtos separados.',
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
        _buildHeader(context, theme, colorScheme, icon, iconColor, filteredItems.length),

        // Lista de produtos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return PickingProductListItem(
                item: item,
                viewModel: viewModel,
                isCompleted: viewModel.isItemCompleted(item.item),
                allowEdit: filterType == 'completed', // Só permite editar produtos separados
              );
            },
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
                  filterType == 'pending' ? 'Produtos Pendentes' : 'Produtos Separados',
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

  List<SeparateItemConsultationModel> _getFilteredItems() {
    if (filterType == 'pending') {
      // Produtos pendentes: não completados
      return viewModel.items.where((item) => !viewModel.isItemCompleted(item.item)).toList();
    } else {
      // Produtos separados: completados
      return viewModel.items.where((item) => viewModel.isItemCompleted(item.item)).toList();
    }
  }
}
