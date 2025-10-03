import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/core/routing/app_router.dart';
import 'package:exp/ui/widgets/common/custom_app_bar.dart';
import 'package:exp/ui/widgets/common/connection_status_bar.dart';
import 'package:exp/domain/viewmodels/separation_viewmodel.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/ui/widgets/separation/separation_filter_modal.dart';
import 'package:exp/ui/widgets/separation/separation_card.dart';
import 'package:exp/ui/widgets/app_drawer/app_drawer.dart';

/// Tela principal de listagem de separações
class SeparationScreen extends StatefulWidget {
  const SeparationScreen({super.key});

  @override
  State<SeparationScreen> createState() => _SeparationScreenState();
}

class _SeparationScreenState extends State<SeparationScreen> {
  // Constantes
  static const double _scrollThresholdToShowButton = 200.0;
  static const double _scrollThresholdToLoadMore = 200.0;
  static const Duration _scrollAnimationDuration = Duration(milliseconds: 500);

  // Controladores
  final ScrollController _scrollController = ScrollController();

  // Estado
  bool _showScrollToTop = false;

  // ========== Lifecycle ==========

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ========== Data Loading ==========

  void _loadInitialData() {
    context.read<SeparationViewModel>().loadSeparations();
  }

  // ========== Scroll Handling ==========

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    _updateScrollToTopButtonVisibility();
    _loadMoreIfNeeded();
  }

  void _updateScrollToTopButtonVisibility() {
    final shouldShow = _scrollController.offset > _scrollThresholdToShowButton;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  void _loadMoreIfNeeded() {
    final isNearBottom =
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - _scrollThresholdToLoadMore;
    if (isNearBottom) {
      context.read<SeparationViewModel>().loadMoreSeparations();
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(0, duration: _scrollAnimationDuration, curve: Curves.easeInOut);
  }

  void _refreshAndScrollToTop(SeparationViewModel viewModel) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    viewModel.refresh();
  }

  // ========== UI Actions ==========

  void _onSeparationTap(SeparateConsultationModel separation) {
    context.push(AppRouter.separateItems, extra: separation.toJson());
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => ChangeNotifierProvider.value(
        value: context.read<SeparationViewModel>(),
        child: const SeparationFilterModal(),
      ),
    );
  }

  // ========== Build Methods ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Separação',
        showSocketStatus: false,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), tooltip: 'Voltar'),
        actions: [_buildAppBarActions()],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const ConnectionStatusBar(),
          Expanded(
            child: Consumer<SeparationViewModel>(
              builder: (context, viewModel, child) {
                return _buildBody(context, viewModel);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              tooltip: 'Voltar ao topo',
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  Widget _buildAppBarActions() {
    return Consumer<SeparationViewModel>(
      builder: (context, viewModel, child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [_buildFilterButton(viewModel), _buildRefreshButton(viewModel)],
      ),
    );
  }

  Widget _buildFilterButton(SeparationViewModel viewModel) {
    return IconButton(
      onPressed: _showFilterModal,
      icon: _FilterIconWithBadge(hasActiveFilters: viewModel.hasActiveFilters),
      tooltip: 'Filtros',
    );
  }

  Widget _buildRefreshButton(SeparationViewModel viewModel) {
    return IconButton(
      onPressed: () => _refreshAndScrollToTop(viewModel),
      icon: const Icon(Icons.refresh),
      tooltip: 'Atualizar lista',
    );
  }

  Widget _buildBody(BuildContext context, SeparationViewModel viewModel) {
    if (viewModel.isLoading) return _buildLoadingState();
    if (viewModel.hasError) return _buildErrorState(viewModel);
    if (!viewModel.hasData) return _buildEmptyState();
    return _buildSeparationsList(viewModel);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Carregando separações...')],
      ),
    );
  }

  Widget _buildErrorState(SeparationViewModel viewModel) {
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
              onPressed: viewModel.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildSeparationsList(SeparationViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        key: const PageStorageKey<String>('separations_list'),
        controller: _scrollController,
        itemCount: viewModel.separations.length + (viewModel.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) => _buildListItem(index, viewModel),
      ),
    );
  }

  Widget _buildListItem(int index, SeparationViewModel viewModel) {
    if (index == viewModel.separations.length) {
      return _buildLoadingMoreIndicator(viewModel);
    }

    final separation = viewModel.separations[index];
    return SeparationCard(separation: separation, onSeparate: () => _onSeparationTap(separation));
  }

  Widget _buildLoadingMoreIndicator(SeparationViewModel viewModel) {
    if (!viewModel.isLoadingMore) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Carregando mais separações...'),
        ],
      ),
    );
  }
}

/// Widget auxiliar para exibir ícone de filtro com badge de indicador
class _FilterIconWithBadge extends StatelessWidget {
  final bool hasActiveFilters;

  const _FilterIconWithBadge({required this.hasActiveFilters});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Icon(Icons.filter_alt),
        if (hasActiveFilters)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
