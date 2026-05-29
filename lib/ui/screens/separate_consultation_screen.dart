import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/ui/widgets/common/index.dart';
import 'package:data7_expedicao/ui/widgets/app_drawer/app_drawer.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder_extension.dart';
import 'package:data7_expedicao/ui/widgets/data_grid/separate_consultation_data_grid.dart';
import 'package:data7_expedicao/presentation/viewmodels/separate_consultation_viewmodel.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/ui/widgets/separate_consultation/index.dart';

class SeparateConsultationScreen extends StatefulWidget {
  const SeparateConsultationScreen({super.key});

  @override
  State<SeparateConsultationScreen> createState() => _ShipmentSeparateConsultationScreenState();
}

class _ShipmentSeparateConsultationScreenState extends State<SeparateConsultationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final bool _isNavigatingAway = false;

  /// Bug UUUUUUU: rastreia ultima mensagem de erro mostrada para evitar
  /// dialog duplicado em rebuilds. Mesmo padrao do Bug DDDDDDD corrigido
  /// em ProfileScreen.
  String? _lastShownErrorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // Item 9: remove o listener de busca antes de descartar o controller.
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ShipmentSeparateConsultationViewModel>(
      builder: (context, viewModel, child) {
        if (mounted && !_isNavigatingAway) {
          _handleViewModelState(context, viewModel);
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _handleBack(viewModel);
          },
          child: Scaffold(
            appBar: CustomAppBar(
              title: 'Consulta Separações',
              elevation: 0,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              leading: IconButton(
                onPressed: () => _handleBack(viewModel),
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                tooltip: 'Voltar',
              ),
              actions: [
                IconButton(
                  onPressed: () => _performConsultation(viewModel),
                  icon: Icon(Icons.search, color: colorScheme.onSurface),
                  tooltip: 'Consultar',
                ),
                IconButton(
                  onPressed: () => _refreshData(viewModel),
                  icon: Icon(Icons.refresh, color: colorScheme.onSurface),
                  tooltip: 'Atualizar',
                ),
              ],
            ),
            drawer: const AppDrawer(),
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(UIConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar consultas...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    viewModel.clearSearch();
                                  },
                                  icon: const Icon(Icons.clear),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        onChanged: (value) => viewModel.setSearchQuery(value),
                      ),
                      const SizedBox(height: UIConstants.smallPadding),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _performConsultation(viewModel),
                          icon: const Icon(Icons.search),
                          label: const Text('Consultar Separações'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(child: _buildDataGrid(viewModel)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataGrid(ShipmentSeparateConsultationViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: UIConstants.defaultPadding),
            Text('Erro ao carregar consultas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            ElevatedButton.icon(
              onPressed: () => _refreshData(viewModel),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    final consultations = viewModel.filteredConsultations;

    if (consultations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: UIConstants.defaultPadding),
            Text(
              viewModel.searchQuery.isNotEmpty ? 'Nenhuma consulta encontrada' : 'Nenhuma consulta disponível',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.searchQuery.isNotEmpty
                  ? 'Tente ajustar os filtros de pesquisa'
                  : 'Clique no botão + para criar uma nova consulta',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Consultas encontradas: ${consultations.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (viewModel.searchQuery.isNotEmpty || viewModel.selectedSituacaoFilter != null)
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    viewModel.clearFilters();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar Filtros'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SeparateConsultationDataGrid(
                    consultations: consultations,
                    onRowTap: _onConsultationTap,
                    onRowDoubleTap: _onConsultationDoubleTap,
                  ),
                ),

                ConsultationPaginationControls(viewModel: viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onConsultationTap(dynamic consultation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Consulta ${consultation.codSepararEstoque} selecionada'),
        duration: UIConstants.snackBarShortDuration,
      ),
    );
  }

  void _onConsultationDoubleTap(dynamic consultation) {
    _showConsultationDetails(consultation);
  }

  void _showConsultationDetails(dynamic consultation) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Consulta ${consultation.codSepararEstoque}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConsultationDetailItem(label: 'ID:', value: consultation.codSepararEstoque.toString()),
                ConsultationDetailItem(label: 'Código:', value: consultation.codSepararEstoque.toString()),
                ConsultationDetailItem(label: 'Descrição:', value: consultation.nomeEntidade),
                ConsultationDetailItem(label: 'Status:', value: consultation.situacaoDescription),
                ConsultationDetailItem(label: 'Usuário:', value: consultation.nomeEntidade),
                ConsultationDetailItem(label: 'Data Emissão:', value: _formatDate(consultation.dataEmissao)),
                ConsultationDetailItem(label: 'Hora Emissão:', value: consultation.horaEmissao),
                if (consultation.observacao != null)
                  ConsultationDetailItem(label: 'Observações:', value: consultation.observacao),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Fechar')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Editar'),
            ),
          ],
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir detalhes da consulta',
          tag: 'SeparateConsultationScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _refreshData(ShipmentSeparateConsultationViewModel viewModel) {
    unawaited(
      viewModel.loadConsultations().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao recarregar consultas de separação',
          tag: 'SeparateConsultationScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _performConsultation(ShipmentSeparateConsultationViewModel viewModel) {
    context.showCustomDialog(
      title: 'Consultar Separações',
      titleIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
      width: 800,
      height: 700,
      content: ConsultationFilterDialogContent(
        viewModel: viewModel,
        onConsult: (filterType, pageSize, inputValue) {
          if (pageSize != viewModel.pageSize) {
            viewModel.setPageSize(pageSize);
          }
          _executeConsultationWithFilter(viewModel, filterType, inputValue);
        },
      ),
    );
  }

  void _executeConsultationWithFilter(
    ShipmentSeparateConsultationViewModel viewModel,
    String filterType,
    String inputValue,
  ) {
    QueryBuilder? queryBuilder;

    final currentPageSize = viewModel.pageSize;

    switch (filterType) {
      case 'todos':
        queryBuilder = QueryBuilderExtension.withDefaultPagination(
          limit: currentPageSize,
        ).orderByDesc('codSepararEstoque');
        break;
      case 'codigo':
        if (inputValue.isNotEmpty) {
          queryBuilder = QueryBuilderExtension.withDefaultPagination(
            limit: currentPageSize,
          ).equals('CodSepararEstoque', inputValue).orderByDesc('codSepararEstoque');
        } else {
          queryBuilder = QueryBuilderExtension.withDefaultPagination(
            limit: currentPageSize,
          ).orderByDesc('codSepararEstoque');
        }
        break;
      case 'status':
        if (inputValue.isNotEmpty) {
          queryBuilder = QueryBuilderExtension.withDefaultPagination(
            limit: currentPageSize,
          ).equals('situacao', inputValue).orderByDesc('codSepararEstoque');
        } else {
          queryBuilder = QueryBuilderExtension.withDefaultPagination(
            limit: currentPageSize,
          ).orderByDesc('codSepararEstoque');
        }
        break;
    }

    _executeConsultation(viewModel, queryBuilder);
  }

  void _executeConsultation(ShipmentSeparateConsultationViewModel viewModel, QueryBuilder? queryBuilder) {
    // Bug WWWWWWW (CRITICO): captura referencias ao NavigatorState e
    // ScaffoldMessengerState ANTES do await. Sem isso, o codigo
    // anterior tinha um problema serio:
    //
    // 1. showDialog abre dialog com barrierDismissible: false
    // 2. await viewModel.performConsultation(...)
    // 3. Em .then, `if (!mounted) return;` ANTES do Navigator.pop()
    //
    // Se a tela fosse desmontada durante o await (deep link,
    // notificacao, etc), o dialog ficava TRAVADO permanentemente —
    // usuario nao podia fechar (barrierDismissible: false) e precisava
    // matar o app. Cenario raro mas catastrofico para UX.
    //
    // Solucao: capturar navigator/messenger ANTES do await e usar essas
    // referencias para fechar o dialog SEMPRE, mesmo se mounted=false.
    // Os state objects sobrevivem ao desmonte do widget desde que o
    // ancestral ainda exista (em geral, se a tela foi pop, o overlay do
    // dialog sera desmontado automaticamente — mas o pop explicito
    // garante limpeza).
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Consultando...')]),
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog de consulta em andamento',
          tag: 'SeparateConsultationScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );

    viewModel
        .performConsultation(queryBuilder)
        .then((_) {
          // Sempre fechar o dialog primeiro, antes de qualquer mounted check.
          if (navigator.canPop()) navigator.pop();

          if (!mounted) return;

          messenger.showSnackBar(
            SnackBar(
              content: Text(
                viewModel.hasError
                    ? 'Erro na consulta: ${viewModel.errorMessage}'
                    : 'Consulta realizada com sucesso! ${viewModel.consultations.length} registros encontrados.',
              ),
              backgroundColor: viewModel.hasError ? AppColors.error : AppColors.success,
              duration: UIConstants.snackBarMediumDuration,
            ),
          );
        })
        .catchError((error) {
          if (navigator.canPop()) navigator.pop();

          if (!mounted) return;

          messenger.showSnackBar(
            SnackBar(
              content: Text('Erro na consulta: $error'),
              backgroundColor: AppColors.error,
              duration: UIConstants.snackBarMediumDuration,
            ),
          );
        });
  }

  void _handleViewModelState(BuildContext context, ShipmentSeparateConsultationViewModel viewModel) {
    if (!mounted || _isNavigatingAway) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isNavigatingAway) return;

      switch (viewModel.state) {
        case SeparateConsultationState.error:
          final errorMsg = viewModel.errorMessage;
          if (errorMsg != null && errorMsg != _lastShownErrorMessage) {
            _lastShownErrorMessage = errorMsg;
            unawaited(
              ErrorDialog.showServerError(
                context,
                message: 'Erro ao carregar consultas',
                details: errorMsg,
                showRetryButton: true,
                onRetry: () => _refreshData(viewModel),
              ).catchError((Object e, StackTrace s) {
                AppLogger.warning(
                  'Falha ao exibir dialog de erro (consulta separação)',
                  tag: 'SeparateConsultationScreen',
                  error: e,
                  stackTrace: s,
                );
              }),
            );
          }
          break;
        default:
          // Quando o estado deixa de ser error, limpamos o tracking
          // para que um proximo erro IGUAL ao anterior possa ser mostrado.
          _lastShownErrorMessage = null;
          break;
      }
    });
  }

  Future<void> _handleBack(ShipmentSeparateConsultationViewModel viewModel) async {
    context.go('/home');
  }
}
