import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/domain/viewmodels/separation_viewmodel.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/ui/widgets/separation/separation_filter_modal.dart';
import 'package:data7_expedicao/ui/widgets/separation_title_with_connection_status.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_usecase.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_params.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_failure.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_success.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/ui/widgets/separation/separation_card.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/ui/widgets/app_drawer/app_drawer.dart';
import 'package:data7_expedicao/domain/models/entity_type_model.dart';

/// Tela principal de listagem de separações
class SeparationScreen extends StatefulWidget {
  const SeparationScreen({super.key});

  @override
  State<SeparationScreen> createState() => _SeparationScreenState();
}

class _SeparationScreenState extends State<SeparationScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  // === CONSTANTES ===
  static const double _scrollThresholdToShowButton = 200.0;
  static const double _scrollThresholdToLoadMore = 200.0;
  static const Duration _scrollAnimationDuration = Duration(milliseconds: 500);
  static const Duration _fabAnimationDuration = Duration(milliseconds: 300);
  static const double _fabPosition = 16.0;
  static const double _fabIconSize = 20.0;
  static const double _modalIconSize = 48.0;
  static const double _loadingIndicatorSize = 20.0;
  static const double _emptyStateIconSize = 64.0;

  // === CONTROLADORES ===
  final ScrollController _scrollController = ScrollController();

  // === ESTADO ===
  bool _showScrollToTop = false;
  bool _isLoadingNextSeparation = false;

  // === ANIMAÇÃO ===
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // === LIFECYCLE ===

  // ========== Lifecycle ==========

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);

    // Inicializar animação do FAB
    _fabAnimationController = AnimationController(duration: _fabAnimationDuration, vsync: this);
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut));

    // Iniciar com o botão "Próxima Separação" visível
    _fabAnimationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();

      // Inicia o monitoramento de eventos quando a tela é aberta
      final viewModel = context.read<SeparationViewModel>();
      viewModel.startEventMonitoring();
      viewModel.setScreenVisible(true); // Marca tela como visível
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Para o monitoramento de eventos quando a tela é fechada
    try {
      final viewModel = context.read<SeparationViewModel>();
      viewModel.stopEventMonitoring();
      viewModel.setScreenVisible(false); // Marca tela como não visível
    } catch (e) {
      // Ignora erro se o contexto não estiver mais disponível
    }

    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Atualizar visibilidade baseado no estado do app
    try {
      final viewModel = context.read<SeparationViewModel>();

      // Considera "não visível" se app está em background
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive ||
          state == AppLifecycleState.detached) {
        viewModel.setScreenVisible(false);
      } else if (state == AppLifecycleState.resumed) {
        // Só marca como visível se voltou ao foreground
        viewModel.setScreenVisible(true);
      }
    } catch (e) {
      // Ignora erro se contexto não disponível
    }
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
    if (shouldShow != _showScrollToTop && mounted) {
      setState(() => _showScrollToTop = shouldShow);

      // Animar transição do FAB
      if (shouldShow) {
        _fabAnimationController.reverse();
      } else {
        _fabAnimationController.forward();
      }
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

  // ========== Next Separation FAB ==========

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Stack(alignment: Alignment.bottomRight, children: [_buildNextSeparationFab(), _buildScrollToTopFab()]);
      },
    );
  }

  /// Botão "Próxima Separação" com animação otimizada
  Widget _buildNextSeparationFab() {
    return Positioned(
      right: _fabPosition,
      bottom: _fabPosition,
      child: Transform.scale(
        scale: _fabAnimation.value,
        child: Opacity(
          opacity: _fabAnimation.value,
          child: IgnorePointer(
            ignoring: _showScrollToTop,
            child: FloatingActionButton.extended(
              heroTag: "next_separation_fab",
              onPressed: _isLoadingNextSeparation ? null : _findNextSeparation,
              tooltip: 'Buscar próxima separação',
              icon: _buildFabIcon(),
              label: Text(_isLoadingNextSeparation ? 'Buscando...' : 'Próxima Separação'),
            ),
          ),
        ),
      ),
    );
  }

  /// Botão "Voltar ao topo" com animação otimizada
  Widget _buildScrollToTopFab() {
    return Positioned(
      right: _fabPosition,
      bottom: _fabPosition,
      child: Transform.scale(
        scale: 1.0 - _fabAnimation.value,
        child: Opacity(
          opacity: 1.0 - _fabAnimation.value,
          child: IgnorePointer(
            ignoring: !_showScrollToTop,
            child: FloatingActionButton(
              heroTag: "scroll_to_top_fab",
              onPressed: _scrollToTop,
              tooltip: 'Voltar ao topo',
              child: const Icon(Icons.arrow_upward),
            ),
          ),
        ),
      ),
    );
  }

  /// Ícone do FAB (spinner ou play_arrow)
  Widget _buildFabIcon() {
    if (_isLoadingNextSeparation) {
      return const SizedBox(
        width: _fabIconSize,
        height: _fabIconSize,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return const Icon(Icons.play_arrow);
  }

  /// Busca a próxima separação disponível para o usuário
  Future<void> _findNextSeparation() async {
    if (!mounted) return;

    setState(() => _isLoadingNextSeparation = true);

    try {
      final params = await _getUserParams();
      if (params == null) return; // Erro já foi tratado

      final result = await _executeNextSeparationUseCase(params);
      if (!mounted) return;

      _handleNextSeparationResult(result);
    } catch (e) {
      if (mounted) {
        _showErrorModal('Erro Inesperado', 'Erro inesperado: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingNextSeparation = false);
      }
    }
  }

  /// Obtém parâmetros do usuário logado
  Future<NextSeparationUserParams?> _getUserParams() async {
    final userSessionService = locator<UserSessionService>();
    final appUser = await userSessionService.loadUserSession();

    if (appUser?.userSystemModel == null) {
      if (mounted) {
        _showErrorModal('Erro de Sessão', 'Usuário não encontrado na sessão');
      }
      return null;
    }

    final userSystemModel = appUser!.userSystemModel!;
    final params = NextSeparationUserParams(
      codEmpresa: userSystemModel.codEmpresa ?? 0,
      codUsuario: userSystemModel.codUsuario,
      codSetorEstoque: userSystemModel.codSetorEstoque,
      userSystemModel: userSystemModel,
    );

    if (!params.hasValidSector) {
      if (mounted) {
        _showErrorModal('Configuração Inválida', 'Usuário não possui setor estoque configurado');
      }
      return null;
    }

    return params;
  }

  /// Executa o usecase de próxima separação
  Future<Result<NextSeparationUserSuccess>> _executeNextSeparationUseCase(NextSeparationUserParams params) async {
    final usecase = locator<NextSeparationUserUseCase>();
    return await usecase(params);
  }

  /// Processa o resultado da busca de próxima separação
  void _handleNextSeparationResult(Result<NextSeparationUserSuccess> result) {
    result.fold(
      (success) {
        if (success.hasSeparation) {
          _openNextSeparation(success.separation!);
        } else {
          _showInfoModal('Nenhuma Separação', success.message);
        }
      },
      (failure) {
        final errorMessage = failure is NextSeparationUserFailure ? failure.userMessage : failure.toString();
        _showErrorModal('Erro na Busca', errorMessage);
      },
    );
  }

  /// Converte SeparationUserSectorConsultationModel para SeparateConsultationModel
  /// e navega para a tela de separação
  void _openNextSeparation(SeparationUserSectorConsultationModel separation) {
    try {
      // Converter para SeparateConsultationModel
      final separateConsultation = SeparateConsultationModel(
        codEmpresa: separation.codEmpresa,
        codSepararEstoque: separation.codSepararEstoque,
        origem: ExpeditionOrigem.vazio, // Valor padrão
        codOrigem: 0, // Valor padrão
        codTipoOperacaoExpedicao: 0, // Valor padrão
        nomeTipoOperacaoExpedicao: 'Operação Padrão', // Valor padrão
        situacao: separation.separarEstoqueSituacao,
        tipoEntidade: EntityType.cliente, // Valor padrão
        dataEmissao: DateTime.now(), // Valor padrão
        horaEmissao: '00:00:00', // Valor padrão
        codEntidade: 0, // Valor padrão
        nomeEntidade: separation.nomeUsuario ?? 'Entidade Padrão',
        codPrioridade: separation.codPrioridade,
        nomePrioridade: separation.descricaoPrioridade,
        codSetoresEstoque: [separation.codSetorEstoque],
        codUsuariosSeparacao: separation.codUsuario != null ? [separation.codUsuario!] : [],
        historico: null,
        observacao: null,
      );

      // Navegar para a tela de separação
      context.push(AppRouter.separateItems, extra: separateConsultation.toJson());
    } catch (e) {
      _showErrorModal('Erro ao Abrir Separação', 'Erro ao abrir separação: ${e.toString()}');
    }
  }

  // ========== Helper Methods ==========

  void _showErrorModal(String title, String message) {
    _showCustomModal(title: title, message: message, icon: Icons.error_outline, color: Colors.red);
  }

  void _showInfoModal(String title, String message) {
    _showCustomModal(title: title, message: message, icon: Icons.info_outline, color: Colors.blue);
  }

  /// Modal customizado reutilizável
  void _showCustomModal({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        icon: Icon(icon, color: color, size: _modalIconSize),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  // ========== Build Methods ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const SeparationTitleWithConnectionStatus(),
        showSocketStatus: false,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), tooltip: 'Voltar'),
        actions: [_buildAppBarActions()],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: Consumer<SeparationViewModel>(
              builder: (context, viewModel, child) {
                return _buildBody(context, viewModel);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
            Icon(Icons.error_outline, size: _emptyStateIconSize, color: Theme.of(context).colorScheme.error),
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
            Icon(Icons.inventory_2_outlined, size: _emptyStateIconSize, color: Theme.of(context).colorScheme.outline),
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
          SizedBox(
            width: _loadingIndicatorSize,
            height: _loadingIndicatorSize,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
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
