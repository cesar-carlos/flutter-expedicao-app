import 'dart:async';

import 'package:flutter/material.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_usecase.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_viewmodel.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/ui/widgets/separation/separation_filter_modal.dart';
import 'package:data7_expedicao/ui/widgets/separation_title_with_connection_status.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_usecase.dart';
import 'package:data7_expedicao/ui/widgets/separation/separation_card.dart';
import 'package:data7_expedicao/ui/widgets/separation/separation_list_states.dart';
import 'package:data7_expedicao/ui/widgets/app_drawer/app_drawer.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/usecases/get_default_printer/get_default_printer_usecase.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_usecase.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_usecase.dart';
import 'package:data7_expedicao/presentation/coordinators/separation_print_coordinator.dart';
import 'package:data7_expedicao/presentation/coordinators/separation_user_link_coordinator.dart';
import 'package:data7_expedicao/presentation/coordinators/next_separation_coordinator.dart';

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

  // === CONTROLADORES ===
  final ScrollController _scrollController = ScrollController();

  // === ESTADO ===
  bool _showScrollToTop = false;
  bool _isLoadingNextSeparation = false;
  final Set<String> _printingTickets = <String>{};

  // === ANIMAÇÃO ===
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // === LIFECYCLE ===

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

    if (mounted) {
      try {
        final viewModel = context.read<SeparationViewModel>();
        viewModel.stopEventMonitoring();
        viewModel.setScreenVisible(false);
      } catch (e, stackTrace) {
        AppLogger.debug(
          'Erro ao parar monitoramento (contexto pode não estar mais disponível)',
          tag: 'SeparationScreen',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!mounted) return;

    try {
      final viewModel = context.read<SeparationViewModel>();

      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive ||
          state == AppLifecycleState.detached) {
        viewModel.setScreenVisible(false);
      } else if (state == AppLifecycleState.resumed) {
        viewModel.setScreenVisible(true);
        unawaited(viewModel.resyncVisibleSeparationsSilently());
      }
    } catch (e, stackTrace) {
      AppLogger.debug(
        'Erro ao atualizar visibilidade (contexto pode não estar mais disponível)',
        tag: 'SeparationScreen',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _loadInitialData() {
    context.read<SeparationViewModel>().loadSeparations();
  }

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
    if (!mounted) return;

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
    unawaited(
      viewModel.refresh().catchError((Object e, StackTrace s) {
        AppLogger.warning('Falha ao atualizar lista de separações', tag: 'SeparationScreen', error: e, stackTrace: s);
      }),
    );
  }

  String _buildPrintKey(SeparateConsultationModel separation) {
    return '${separation.codEmpresa}-${separation.codSepararEstoque}';
  }

  bool _isPrintingTicket(SeparateConsultationModel separation) {
    return _printingTickets.contains(_buildPrintKey(separation));
  }

  /// Usuários com codSetorEstoque só podem abrir separações em que estejam vinculados.
  /// Verificação centralizada em ResolveSeparationUserLinkUseCase (listagem ou fallback).
  Future<void> _onSeparationTap(SeparateConsultationModel separation) async {
    final userSessionService = locator<IUserSessionService>();
    final appUser = await userSessionService.loadUserSession();
    final codSetorEstoque = appUser?.userSystemModel?.codSetorEstoque;
    final codUsuario = appUser?.userSystemModel?.codUsuario;

    if (codUsuario == null || codUsuario <= 0) {
      if (mounted) {
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
      final linkCoordinator = SeparationUserLinkCoordinator(
        resolveSeparationUserLinkUseCase: locator<ResolveSeparationUserLinkUseCase>(),
      );
      final linkResult = await linkCoordinator.resolveLink(
        separation: separation,
        codUsuario: codUsuario,
        codSetorEstoque: codSetorEstoque,
      );
      if (!mounted) return;
      if (linkResult == SeparationLinkResult.checkFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(UIConstants.separationLinkCheckFailedMessage),
            backgroundColor: AppColors.error,
            duration: UIConstants.snackBarLongDuration,
          ),
        );
        return;
      }
      if (linkResult == SeparationLinkResult.notAssigned && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(UIConstants.separationNotAssignedToUserMessage),
            backgroundColor: AppColors.error,
            duration: UIConstants.snackBarLongDuration,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    context.push(AppRouter.separateItems, extra: separation.toJson());
  }

  void _showFilterModal() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.transparent,
        builder: (modalContext) => ChangeNotifierProvider.value(
          value: context.read<SeparationViewModel>(),
          child: const SeparationFilterModal(),
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning('Falha ao exibir filtro de separações', tag: 'SeparationScreen', error: e, stackTrace: s);
      }),
    );
  }

  Future<void> _onPrintTap(SeparateConsultationModel separation) async {
    final key = _buildPrintKey(separation);
    if (_printingTickets.contains(key)) {
      return;
    }

    if (mounted) {
      setState(() => _printingTickets.add(key));
    } else {
      _printingTickets.add(key);
    }

    try {
      final coordinator = SeparationPrintCoordinator(
        getDefaultPrinterUseCase: locator<GetDefaultPrinterUseCase>(),
        userSessionService: locator<IUserSessionService>(),
        printExpeditionTicketUseCase: locator<PrintExpeditionTicketUseCase>(),
      );

      final result = await coordinator.printSeparationTicket(
        codEmpresa: separation.codEmpresa,
        codSepararEstoque: separation.codSepararEstoque,
      );

      if (!mounted) return;

      switch (result) {
        case PrintTicketNoPrinterConfigured():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Nenhuma impressora padrão configurada para impressão.'),
              backgroundColor: AppColors.warning,
              action: SnackBarAction(label: 'Configurar', onPressed: () => context.push(AppRouter.printerConfig)),
            ),
          );
        case PrintTicketSent(:final printer):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impressão enviada para ${printer.name} (${printer.ip}:${printer.port}).'),
              backgroundColor: AppColors.info,
            ),
          );
        case PrintTicketFailed(:final message):
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.warning));
        case PrintTicketError():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao imprimir separação. Tente novamente.'),
              backgroundColor: AppColors.error,
            ),
          );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao imprimir separação', tag: 'SeparationScreen', error: e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao imprimir separação. Tente novamente.'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _printingTickets.remove(key));
      } else {
        _printingTickets.remove(key);
      }
    }
  }

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
            child: Semantics(
              button: true,
              label: _isLoadingNextSeparation ? 'Buscando...' : 'Próxima Separação',
              hint: 'Busca a próxima separação atribuída ao seu setor',
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
      final coordinator = NextSeparationCoordinator(
        userSessionService: locator<IUserSessionService>(),
        nextSeparationUserUseCase: locator<NextSeparationUserUseCase>(),
        getSeparationConsultationUseCase: locator<GetSeparationConsultationUseCase>(),
      );

      final result = await coordinator.findNextSeparation();
      if (!mounted) return;

      switch (result) {
        case NextSeparationSessionError():
          _showErrorModal('Erro de Sessão', 'Usuário não encontrado na sessão');
        case NextSeparationInvalidSector():
          _showErrorModal('Configuração Inválida', 'Usuário não possui setor estoque configurado');
        case NextSeparationEmpty(:final message):
          _showInfoModal('Nenhuma Separação', message);
        case NextSeparationSearchError(:final message):
          _showErrorModal('Erro na Busca', message);
        case NextSeparationAssignmentError(:final codSepararEstoque):
          _showErrorModal(
            'Erro de Atribuição',
            'A separação $codSepararEstoque não está atribuída ao usuário atual. '
                'Por favor, tente novamente.',
          );
        case NextSeparationConsultError(:final message):
          _showErrorModal('Erro na Consulta', message);
        case NextSeparationNotFound(:final codSepararEstoque):
          _showErrorModal('Separação Não Encontrada', 'A separação $codSepararEstoque não foi encontrada.');
        case NextSeparationReady(:final separation):
          context.push(AppRouter.separateItems, extra: separation.toJson());
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro inesperado em Próxima Separação',
        tag: 'SeparationScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _showErrorModal('Erro Inesperado', 'Erro inesperado. Tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingNextSeparation = false);
      }
    }
  }

  void _showErrorModal(String title, String message) {
    _showCustomModal(title: title, message: message, icon: Icons.error_outline, color: AppColors.error);
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
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(icon, color: color, size: _modalIconSize),
          title: Text(
            title,
            style: AppFonts.inter(color: color, fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('OK', style: AppFonts.inter(color: color)),
            ),
          ],
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir modal na tela de separações',
          tag: 'SeparationScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

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
    // Item 8: Selector por campo (hasActiveFilters) em vez de Consumer amplo.
    // O botão de refresh não precisa reagir ao ViewModel — obtém a instância
    // via context.read apenas no callback.
    return Selector<SeparationViewModel, bool>(
      selector: (_, vm) => vm.hasActiveFilters,
      builder: (context, hasActiveFilters, child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _showFilterModal,
            icon: _FilterIconWithBadge(hasActiveFilters: hasActiveFilters),
            tooltip: 'Filtros',
          ),
          IconButton(
            onPressed: () => _refreshAndScrollToTop(context.read<SeparationViewModel>()),
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SeparationViewModel viewModel) {
    if (viewModel.isLoading) return const SeparationLoadingState();
    if (viewModel.hasError) {
      return SeparationListErrorState(
        errorMessage: viewModel.errorMessage,
        onRetry: () {
          unawaited(
            viewModel.refresh().catchError((Object e, StackTrace s) {
              AppLogger.warning(
                'Falha ao repetir carregamento de separações',
                tag: 'SeparationScreen',
                error: e,
                stackTrace: s,
              );
            }),
          );
        },
      );
    }
    if (!viewModel.hasData) {
      return SeparationListEmptyState(
        onRefresh: () {
          final vm = context.read<SeparationViewModel>();
          unawaited(
            vm.refresh().catchError((Object e, StackTrace s) {
              AppLogger.warning(
                'Falha ao atualizar separações (estado vazio)',
                tag: 'SeparationScreen',
                error: e,
                stackTrace: s,
              );
            }),
          );
        },
      );
    }
    return _buildSeparationsList(viewModel);
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
    return SeparationCard(
      separation: separation,
      onSeparate: () => _onSeparationTap(separation),
      onPrint: () => unawaited(_onPrintTap(separation)),
      isPrinting: _isPrintingTicket(separation),
    );
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
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
