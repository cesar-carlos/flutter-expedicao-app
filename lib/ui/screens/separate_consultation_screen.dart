import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/ui/widgets/common/index.dart';
import 'package:exp/ui/widgets/app_drawer/app_drawer.dart';
import 'package:exp/ui/widgets/data_grid/separate_consultation_data_grid.dart';
import 'package:exp/domain/viewmodels/separate_consultation_viewmodel.dart';
import 'package:exp/domain/models/shipping_situation_model.dart';

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
                      const SizedBox(height: 12),
                      // Filtros rápidos
                      Row(
                        children: [
                          Expanded(
                            child: FilterChip(
                              label: const Text('Todas'),
                              selected:
                                  viewModel.selectedSituacaoFilter == null,
                              onSelected: (selected) {
                                if (selected) {
                                  viewModel.setSituacaoFilter(null);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilterChip(
                              label: const Text('Aguardando'),
                              selected:
                                  viewModel.selectedSituacaoFilter ==
                                  ExpeditionSituation.aguardando.code,
                              onSelected: (selected) {
                                if (selected) {
                                  viewModel.setSituacaoFilter(
                                    ExpeditionSituation.aguardando.code,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilterChip(
                              label: const Text('Finalizadas'),
                              selected:
                                  viewModel.selectedSituacaoFilter ==
                                  ExpeditionSituation.finalizada.code,
                              onSelected: (selected) {
                                if (selected) {
                                  viewModel.setSituacaoFilter(
                                    ExpeditionSituation.finalizada.code,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // DataGrid
                Expanded(child: _buildDataGrid(viewModel)),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddConsultationDialog(viewModel),
              tooltip: 'Nova Consulta',
              child: const Icon(Icons.add),
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
            child: SeparateConsultationDataGrid(
              consultations: consultations,
              onRowTap: _onConsultationTap,
              onRowDoubleTap: _onConsultationDoubleTap,
            ),
          ),
        ],
      ),
    );
  }

  void _onConsultationTap(dynamic consultation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Consulta ${consultation.codigo} selecionada'),
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
        title: Text('Consulta ${consultation.codigo}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('ID:', consultation.id.toString()),
              _buildDetailItem('Código:', consultation.codigo ?? 'N/A'),
              _buildDetailItem('Descrição:', consultation.descricao ?? 'N/A'),
              _buildDetailItem('Status:', consultation.status ?? 'N/A'),
              _buildDetailItem('Usuário:', consultation.usuario ?? 'N/A'),
              if (consultation.dataInicialSeparacao != null)
                _buildDetailItem(
                  'Data Inicial:',
                  _formatDate(consultation.dataInicialSeparacao),
                ),
              if (consultation.dataFinalSeparacao != null)
                _buildDetailItem(
                  'Data Final:',
                  _formatDate(consultation.dataFinalSeparacao),
                ),
              if (consultation.observacoes != null)
                _buildDetailItem('Observações:', consultation.observacoes),
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
    showDialog(
      context: context,
      builder: (context) => _buildConsultationDialog(viewModel),
    );
  }

  Widget _buildConsultationDialog(
    ShipmentSeparateConsultationViewModel viewModel,
  ) {
    final TextEditingController paramsController = TextEditingController();
    String selectedFilter = 'todos';

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Consultar Separações'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
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
                    RadioListTile<String>(
                      title: const Text('Consulta personalizada'),
                      subtitle: const Text('Digite parâmetros personalizados'),
                      value: 'personalizada',
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
                ] else if (selectedFilter == 'personalizada') ...[
                  TextField(
                    controller: paramsController,
                    decoration: const InputDecoration(
                      labelText: 'Parâmetros personalizados',
                      hintText: 'Ex: codigo=123, situacao=AGUARDANDO',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.filter_list),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Formato: campo=valor, campo2=valor2',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],

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
                              ? 'Esta consulta retornará todas as separações disponíveis no sistema.'
                              : 'Esta consulta filtrará as separações baseada nos critérios selecionados.',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Consultar'),
              onPressed: () {
                Navigator.of(context).pop();
                _executeConsultationWithFilter(
                  viewModel,
                  selectedFilter,
                  paramsController.text.trim(),
                );
              },
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
    String params = '';

    switch (filterType) {
      case 'todos':
        params = '';
        break;
      case 'codigo':
        params = inputValue.isNotEmpty ? 'codigo=$inputValue' : '';
        break;
      case 'status':
        params = inputValue.isNotEmpty ? 'situacao=$inputValue' : '';
        break;
      case 'personalizada':
        params = inputValue;
        break;
    }

    _executeConsultation(viewModel, params);
  }

  void _executeConsultation(
    ShipmentSeparateConsultationViewModel viewModel,
    String params,
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
        .performConsultation(params)
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
