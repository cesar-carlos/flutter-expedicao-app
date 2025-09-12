import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/ui/widgets/common/index.dart';
import 'package:exp/ui/widgets/app_drawer/app_drawer.dart';
import 'package:exp/ui/widgets/data_grid/separate_consultation_data_grid.dart';
import 'package:exp/domain/viewmodels/separate_consultation_viewmodel.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/domain/models/query_builder.dart';
import 'package:exp/domain/models/query_builder_extension.dart';

/// Tela para exibir consultas de separação de expedição
class SeparateConsultationScreen extends StatefulWidget {
  const SeparateConsultationScreen({super.key});

  @override
  State<SeparateConsultationScreen> createState() =>
      _ShipmentSeparateConsultationScreenState();
}

class _ShipmentSeparateConsultationScreenState
    extends State<SeparateConsultationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final bool _isNavigatingAway = false;

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ShipmentSeparateConsultationViewModel>(
      builder: (context, viewModel, child) {
        // Só processar mudanças de estado se o widget ainda estiver montado e não navegando
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
              title: 'Consultas de Separação',
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
                // Barra de pesquisa e filtros
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Campo de pesquisa
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                        ),
                        onChanged: (value) => viewModel.setSearchQuery(value),
                      ),
                      const SizedBox(height: 12),
                      // Botão de consulta principal
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
                // DataGrid
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar consultas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.searchQuery.isNotEmpty
                  ? 'Nenhuma consulta encontrada'
                  : 'Nenhuma consulta disponível',
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações do resultado
          Row(
            children: [
              Text(
                'Consultas encontradas: ${consultations.length}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (viewModel.searchQuery.isNotEmpty ||
                  viewModel.selectedSituacaoFilter != null)
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
          // DataGrid
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
                // Controles de paginação
                _buildPaginationControls(viewModel),
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onConsultationDoubleTap(dynamic consultation) {
    _showConsultationDetails(consultation);
  }

  void _showConsultationDetails(dynamic consultation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Consulta ${consultation.codSepararEstoque}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem(
                'ID:',
                consultation.codSepararEstoque.toString(),
              ),
              _buildDetailItem(
                'Código:',
                consultation.codSepararEstoque.toString(),
              ),
              _buildDetailItem('Descrição:', consultation.nomeEntidade),
              _buildDetailItem('Status:', consultation.situacao),
              _buildDetailItem('Usuário:', consultation.nomeEntidade),
              _buildDetailItem(
                'Data Emissão:',
                _formatDate(consultation.dataEmissao),
              ),
              _buildDetailItem('Hora Emissão:', consultation.horaEmissao),
              if (consultation.observacao != null)
                _buildDetailItem('Observações:', consultation.observacao),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar edição
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Widget _buildPaginationControls(
    ShipmentSeparateConsultationViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Informações da paginação
          Text(
            'Página ${viewModel.currentPage + 1} - ${viewModel.consultations.length} registros',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),

          // Botão página anterior
          IconButton(
            onPressed: viewModel.currentPage > 0 && !viewModel.isLoading
                ? () => viewModel.loadPage(viewModel.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
          ),

          // Indicador de página atual
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${viewModel.currentPage + 1}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Botão próxima página
          IconButton(
            onPressed: viewModel.hasMoreData && !viewModel.isLoading
                ? () => viewModel.loadNextPage()
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próxima página',
          ),
        ],
      ),
    );
  }

  void _showAddConsultationDialog(
    ShipmentSeparateConsultationViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Consulta'),
        content: const Text(
          'Funcionalidade de criar nova consulta será implementada aqui.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar criação de consulta
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _refreshData(ShipmentSeparateConsultationViewModel viewModel) {
    viewModel.loadConsultations();
  }

  void _performConsultation(ShipmentSeparateConsultationViewModel viewModel) {
    // Mostrar diálogo para inserir parâmetros de consulta
    context.showCustomDialog(
      title: 'Consultar Separações',
      titleIcon: Icon(
        Icons.search,
        color: Theme.of(context).colorScheme.primary,
      ),
      width: 800,
      height: 700,
      content: _buildConsultationDialogContent(viewModel),
    );
  }

  Widget _buildConsultationDialogContent(
    ShipmentSeparateConsultationViewModel viewModel,
  ) {
    final TextEditingController paramsController = TextEditingController();
    String selectedFilter = 'todos';
    int pageSize = viewModel.pageSize;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escolha o tipo de consulta:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Opções de filtro
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Todas as separações'),
                  subtitle: const Text(
                    'Buscar todas as separações disponíveis',
                  ),
                  value: 'todos',
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Por código'),
                  subtitle: const Text('Buscar por código específico'),
                  value: 'codigo',
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Por situação'),
                  subtitle: const Text('Buscar por situação específica'),
                  value: 'status',
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Campo de entrada baseado na seleção
            if (selectedFilter == 'codigo') ...[
              TextField(
                controller: paramsController,
                decoration: const InputDecoration(
                  labelText: 'Código da separação',
                  hintText: 'Ex: 123',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                keyboardType: TextInputType.number,
              ),
            ] else if (selectedFilter == 'status') ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Situação',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: ExpeditionSituation.values.map((situation) {
                  return DropdownMenuItem(
                    value: situation.code,
                    child: Text(situation.description),
                  );
                }).toList(),
                onChanged: (value) {
                  paramsController.text = value ?? '';
                },
              ),
            ],

            const SizedBox(height: 16),

            // Configurações de paginação
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.view_list,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Configurações de Paginação',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Registros por página:'),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        value: pageSize,
                        items: [10, 20, 50, 100].map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text('$size'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            pageSize = value ?? 20;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedFilter == 'todos'
                          ? 'Esta consulta retornará todas as separações disponíveis no sistema com paginação.'
                          : 'Esta consulta filtrará as separações baseada nos critérios selecionados com paginação.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Consultar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Atualizar tamanho da página se necessário
                    if (pageSize != viewModel.pageSize) {
                      viewModel.setPageSize(pageSize);
                    }
                    _executeConsultationWithFilter(
                      viewModel,
                      selectedFilter,
                      paramsController.text.trim(),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _executeConsultationWithFilter(
    ShipmentSeparateConsultationViewModel viewModel,
    String filterType,
    String inputValue,
  ) {
    QueryBuilder? queryBuilder;

    // Usa o pageSize atual do ViewModel
    final currentPageSize = viewModel.pageSize;

    switch (filterType) {
      case 'todos':
        // QueryBuilder com paginação usando o pageSize atual
        queryBuilder = QueryBuilderExtension.withDefaultPagination(
          limit: currentPageSize,
        );
        break;
      case 'codigo':
        if (inputValue.isNotEmpty) {
          queryBuilder = QueryBuilderExtension.withDefaultPagination(
            limit: currentPageSize,
          ).equals('codigo', inputValue);
        } else {
          queryBuilder = QueryBuilderExtension.withDefaultPagination(
            limit: currentPageSize,
          );
        }
        break;
      case 'status':
        if (inputValue.isNotEmpty) {
          queryBuilder = QueryBuilderExtension.withDefaultPagination(
            limit: currentPageSize,
          ).equals('situacao', inputValue);
        } else {
          queryBuilder = QueryBuilderExtension.withDefaultPagination(
            limit: currentPageSize,
          );
        }
        break;
    }

    _executeConsultation(viewModel, queryBuilder);
  }

  void _executeConsultation(
    ShipmentSeparateConsultationViewModel viewModel,
    QueryBuilder? queryBuilder,
  ) {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Consultando...'),
          ],
        ),
      ),
    );

    // Executar consulta
    viewModel
        .performConsultation(queryBuilder)
        .then((_) {
          // Verificar se o widget ainda está montado
          if (!mounted) return;

          // Fechar loading
          Navigator.of(context).pop();

          // Mostrar resultado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                viewModel.hasError
                    ? 'Erro na consulta: ${viewModel.errorMessage}'
                    : 'Consulta realizada com sucesso! ${viewModel.consultations.length} registros encontrados.',
              ),
              backgroundColor: viewModel.hasError ? Colors.red : Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        })
        .catchError((error) {
          // Verificar se o widget ainda está montado
          if (!mounted) return;

          // Fechar loading em caso de erro
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro na consulta: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        });
  }

  void _handleViewModelState(
    BuildContext context,
    ShipmentSeparateConsultationViewModel viewModel,
  ) {
    // Verificar se o widget ainda está montado e não está navegando
    if (!mounted || _isNavigatingAway) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificar novamente se o widget ainda está montado
      if (!mounted || _isNavigatingAway) return;

      switch (viewModel.state) {
        case SeparateConsultationState.error:
          if (viewModel.errorMessage != null) {
            ErrorDialog.showServerError(
              context,
              message: 'Erro ao carregar consultas',
              details: viewModel.errorMessage!,
              showRetryButton: true,
              onRetry: () => _refreshData(viewModel),
            );
          }
          break;
        default:
          break;
      }
    });
  }

  Future<void> _handleBack(
    ShipmentSeparateConsultationViewModel viewModel,
  ) async {
    context.go('/home');
  }
}
