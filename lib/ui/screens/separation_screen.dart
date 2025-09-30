import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/core/routing/app_router.dart';
import 'package:exp/ui/widgets/common/custom_app_bar.dart';
import 'package:exp/domain/viewmodels/separation_viewmodel.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/ui/widgets/separation/separation_filter_modal.dart';
import 'package:exp/ui/widgets/separation/separation_card.dart';
import 'package:exp/ui/widgets/app_drawer/app_drawer.dart';

class SeparationScreen extends StatefulWidget {
  const SeparationScreen({super.key});

  @override
  State<SeparationScreen> createState() => _SeparationScreenState();
}

class _SeparationScreenState extends State<SeparationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Carrega as separações quando a tela é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeparationViewModel>().loadSeparations();
    });

    // Adiciona listener para scroll infinito
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Carrega mais dados quando está próximo do final
      context.read<SeparationViewModel>().loadMoreSeparations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Separação',
        leading: IconButton(
          onPressed: () => context.go(AppRouter.home),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
        ),
        actions: [
          Consumer<SeparationViewModel>(
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
                tooltip: 'Filtros',
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<SeparationViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(context, viewModel);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SeparationViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Carregando separações...')],
        ),
      );
    }

    if (viewModel.hasError) {
      return _buildErrorState(context, viewModel);
    }

    if (!viewModel.hasData) {
      return _buildEmptyState(context);
    }

    return _buildSeparationsList(context, viewModel);
  }

  Widget _buildErrorState(BuildContext context, SeparationViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar separações',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Nenhuma separação encontrada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há separações disponíveis no momento.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<SeparationViewModel>().refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparationsList(BuildContext context, SeparationViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: viewModel.separations.length + (viewModel.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          // Se é o último item e há mais dados, mostra loading indicator
          if (index == viewModel.separations.length) {
            return _buildLoadingMoreIndicator(viewModel);
          }

          final separation = viewModel.separations[index];
          return SeparationCard(separation: separation, onSeparate: () => _onSeparationSeparate(context, separation));
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(SeparationViewModel viewModel) {
    if (!viewModel.isLoadingMore) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Carregando mais separações...'),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        // Passa o Provider do contexto pai para o modal
        return ChangeNotifierProvider.value(
          value: context.read<SeparationViewModel>(),
          child: const SeparationFilterModal(),
        );
      },
    );
  }

  void _onSeparationSeparate(BuildContext context, SeparateConsultationModel separation) {
    // Navega para a tela de separação de itens
    context.go(AppRouter.separateItems, extra: separation.toJson());
  }
}
