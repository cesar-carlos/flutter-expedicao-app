import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exp/domain/viewmodels/separation_viewmodel.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/expedition_sector_stock_model.dart';

/// Modal para filtros da tela de separação
class SeparationFilterModal extends StatefulWidget {
  const SeparationFilterModal({super.key});

  @override
  State<SeparationFilterModal> createState() => _SeparationFilterModalState();
}

class _SeparationFilterModalState extends State<SeparationFilterModal> {
  late TextEditingController _codSepararEstoqueController;
  late TextEditingController _codOrigemController;
  String? _selectedOrigem;
  List<String> _selectedSituacoes = []; // Mudado de String? para List<String>
  DateTime? _selectedDate;
  ExpeditionSectorStockModel? _selectedSetorEstoque;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<SeparationViewModel>();

    _codSepararEstoqueController = TextEditingController(text: viewModel.codSepararEstoqueFilter ?? '');
    _codOrigemController = TextEditingController(text: viewModel.codOrigemFilter ?? '');
    _selectedOrigem = viewModel.origemFilter;
    _selectedSituacoes = viewModel.situacoesFilter ?? [];
    _selectedDate = viewModel.dataEmissaoFilter;
    _selectedSetorEstoque = viewModel.setorEstoqueFilter;

    // Carrega setores de estoque se ainda não foram carregados
    if (!viewModel.sectorsLoaded) {
      viewModel.loadAvailableSectors().then((_) {
        if (mounted) {
          setState(() {
            // Sincroniza o setor selecionado com a lista carregada
            _syncSelectedSector();
          });
        }
      });
    } else {
      // Se os setores já foram carregados, sincroniza imediatamente
      _syncSelectedSector();
    }
  }

  /// Sincroniza o setor selecionado com a lista de setores disponíveis
  void _syncSelectedSector() {
    final viewModel = context.read<SeparationViewModel>();
    if (_selectedSetorEstoque != null && viewModel.availableSectors.isNotEmpty) {
      final matchingSector = viewModel.availableSectors.cast<ExpeditionSectorStockModel?>().firstWhere(
        (sector) => sector != null && sector == _selectedSetorEstoque,
        orElse: () => null,
      );

      if (matchingSector != null) {
        _selectedSetorEstoque = matchingSector;
      }
    }
  }

  @override
  void dispose() {
    _codSepararEstoqueController.dispose();
    _codOrigemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.filter_alt, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filtros de Separação',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Consumer<SeparationViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.hasActiveFilters) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Ativos',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ],
          ),

          const SizedBox(height: 24),

          // Código de Separação
          TextField(
            controller: _codSepararEstoqueController,
            decoration: const InputDecoration(
              labelText: 'Código de Separação',
              hintText: 'Ex: 12345',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          // Origem
          DropdownButtonFormField<String>(
            initialValue: _selectedOrigem,
            decoration: const InputDecoration(
              labelText: 'Origem',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.source),
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('Todas as origens')),
              ...ExpeditionOrigem.values.map(
                (origem) => DropdownMenuItem<String>(value: origem.code, child: Text(origem.description)),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedOrigem = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Código de Origem
          TextField(
            controller: _codOrigemController,
            decoration: const InputDecoration(
              labelText: 'Código de Origem',
              hintText: 'Ex: 123',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          // Situação (Seleção Múltipla)
          InkWell(
            onTap: () => _showSituacoesDialog(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Situação',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              child: Text(
                _selectedSituacoes.isEmpty ? 'Todas as situações' : '${_selectedSituacoes.length} selecionada(s)',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Setor de Estoque
          Consumer<SeparationViewModel>(
            builder: (context, viewModel, child) {
              return DropdownButtonFormField<ExpeditionSectorStockModel?>(
                decoration: const InputDecoration(
                  labelText: 'Setor de Estoque',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                initialValue: _getValidSelectedSector(viewModel),
                items: [
                  const DropdownMenuItem<ExpeditionSectorStockModel?>(value: null, child: Text('Todos os setores')),
                  ...viewModel.availableSectors.map((setor) {
                    return DropdownMenuItem<ExpeditionSectorStockModel?>(value: setor, child: Text(setor.descricao));
                  }),
                ],
                onChanged: (setor) {
                  setState(() {
                    _selectedSetorEstoque = setor;
                  });
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Data de Emissão
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data de Emissão',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              child: Text(
                _selectedDate != null ? _formatDate(_selectedDate!) : 'Selecionar data',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botões
          Consumer<SeparationViewModel>(
            builder: (context, viewModel, child) {
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: viewModel.isLoading ? null : _clearFilters,
                      child: const Text('Limpar Filtros'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _applyFilters,
                      child: viewModel.isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Aplicar Filtros'),
                    ),
                  ),
                ],
              );
            },
          ),

          // Espaçamento para teclado
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _codSepararEstoqueController.clear();
      _codOrigemController.clear();
      _selectedOrigem = null;
      _selectedSituacoes = [];
      _selectedDate = null;
      _selectedSetorEstoque = null;
    });

    final viewModel = context.read<SeparationViewModel>();
    viewModel.clearFilters();
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final viewModel = context.read<SeparationViewModel>();

    viewModel.setCodSepararEstoqueFilter(_codSepararEstoqueController.text);
    viewModel.setOrigemFilter(_selectedOrigem);
    viewModel.setCodOrigemFilter(_codOrigemController.text);
    viewModel.setSituacoesFilter(_selectedSituacoes.isEmpty ? null : _selectedSituacoes);
    viewModel.setDataEmissaoFilter(_selectedDate);
    viewModel.setSetorEstoqueFilter(_selectedSetorEstoque);

    Navigator.of(context).pop();
    viewModel.applyFilters();
  }

  /// Mostra diálogo para seleção múltipla de situações
  Future<void> _showSituacoesDialog(BuildContext context) async {
    final situacoes = _getFilteredSituations();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => _MultiSelectSituacoesDialog(situacoes: situacoes, selectedSituacoes: _selectedSituacoes),
    );

    if (result != null) {
      setState(() {
        _selectedSituacoes = result;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Retorna o setor selecionado se ele ainda existe na lista, senão retorna null
  ExpeditionSectorStockModel? _getValidSelectedSector(SeparationViewModel viewModel) {
    if (_selectedSetorEstoque == null) return null;

    // Se os setores ainda não foram carregados, retorna null
    if (viewModel.availableSectors.isEmpty) {
      return null;
    }

    // Procura o setor na lista de setores disponíveis usando o operador == do modelo
    final matchingSector = viewModel.availableSectors.cast<ExpeditionSectorStockModel?>().firstWhere(
      (sector) => sector != null && sector == _selectedSetorEstoque,
      orElse: () => null,
    );

    if (matchingSector != null) {
      // Atualiza a referência para usar o objeto da lista
      _selectedSetorEstoque = matchingSector;
      return matchingSector;
    } else {
      // Se o setor não existe mais, limpa a seleção
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedSetorEstoque = null;
          });
        }
      });
      return null;
    }
  }

  /// Retorna apenas as situações que devem aparecer no filtro
  /// Removidas as situações marcadas em vermelho conforme solicitado
  List<ExpeditionSituation> _getFilteredSituations() {
    return ExpeditionSituation.values.where((situacao) {
      // Situações removidas conforme imagem:
      // - Em Andamento (EM ANDAMENTO)
      // - Em Conferencia (EM CONFERENCIA)
      // - Cancelada (CANCELADA)
      // - Devolvida (DEVOLVIDA)
      // - Conferindo (CONFERINDO)
      // - Conferido (CONFERIDO)
      // - Entregue (ENTREGUE)
      // - Embalando (EMBALANDO)

      return situacao != ExpeditionSituation.emAndamento &&
          situacao != ExpeditionSituation.emConferencia &&
          situacao != ExpeditionSituation.cancelada &&
          situacao != ExpeditionSituation.devolvida &&
          situacao != ExpeditionSituation.conferindo &&
          situacao != ExpeditionSituation.conferido &&
          situacao != ExpeditionSituation.entregue &&
          situacao != ExpeditionSituation.embalando;
    }).toList();
  }
}

/// Widget de diálogo para seleção múltipla de situações
class _MultiSelectSituacoesDialog extends StatefulWidget {
  final List<ExpeditionSituation> situacoes;
  final List<String> selectedSituacoes;

  const _MultiSelectSituacoesDialog({required this.situacoes, required this.selectedSituacoes});

  @override
  State<_MultiSelectSituacoesDialog> createState() => _MultiSelectSituacoesDialogState();
}

class _MultiSelectSituacoesDialogState extends State<_MultiSelectSituacoesDialog> {
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List<String>.from(widget.selectedSituacoes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Situações'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: widget.situacoes.map((situacao) {
            final isSelected = _tempSelected.contains(situacao.code);
            return CheckboxListTile(
              title: Text(situacao.description),
              value: isSelected,
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    _tempSelected.add(situacao.code);
                  } else {
                    _tempSelected.remove(situacao.code);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _tempSelected.clear();
            });
          },
          child: const Text('Limpar Todas'),
        ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(_tempSelected), child: const Text('Aplicar')),
      ],
    );
  }
}
