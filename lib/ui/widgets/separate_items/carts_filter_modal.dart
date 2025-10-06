import 'package:flutter/material.dart';

import 'package:exp/domain/models/situation/situation_model.dart';
import 'package:exp/domain/viewmodels/separation_items_viewmodel.dart';
import 'package:exp/domain/models/situation/expedition_situation_model.dart';
import 'package:exp/domain/models/filter/carts_filters_model.dart';
import 'package:exp/core/utils/date_helper.dart';

/// Modal para filtros da aba de carrinhos
class CartsFilterModal extends StatefulWidget {
  final SeparationItemsViewModel viewModel;

  const CartsFilterModal({super.key, required this.viewModel});

  @override
  State<CartsFilterModal> createState() => _CartsFilterModalState();
}

class _CartsFilterModalState extends State<CartsFilterModal> {
  late TextEditingController _codCarrinhoController;
  late TextEditingController _nomeCarrinhoController;
  late TextEditingController _codigoBarrasCarrinhoController;
  late TextEditingController _nomeUsuarioInicioController;
  List<String> _selectedSituacoes = [];
  Situation? _selectedCarrinhoAgrupador;
  DateTime? _dataInicioInicial;
  DateTime? _dataInicioFinal;

  @override
  void initState() {
    super.initState();

    _codCarrinhoController = TextEditingController(text: widget.viewModel.cartsFilters.codCarrinho ?? '');
    _nomeCarrinhoController = TextEditingController(text: widget.viewModel.cartsFilters.nomeCarrinho ?? '');
    _codigoBarrasCarrinhoController = TextEditingController(
      text: widget.viewModel.cartsFilters.codigoBarrasCarrinho ?? '',
    );
    _nomeUsuarioInicioController = TextEditingController(text: widget.viewModel.cartsFilters.nomeUsuarioInicio ?? '');
    _selectedSituacoes = widget.viewModel.cartsFilters.situacoes ?? [];
    _selectedCarrinhoAgrupador = widget.viewModel.cartsFilters.carrinhoAgrupador == Situation.inativo
        ? null
        : widget.viewModel.cartsFilters.carrinhoAgrupador;
    _dataInicioInicial = widget.viewModel.cartsFilters.dataInicioInicial;
    _dataInicioFinal = widget.viewModel.cartsFilters.dataInicioFinal;
  }

  @override
  void dispose() {
    _codCarrinhoController.dispose();
    _nomeCarrinhoController.dispose();
    _codigoBarrasCarrinhoController.dispose();
    _nomeUsuarioInicioController.dispose();
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
                  'Filtros de Carrinhos',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.viewModel.hasActiveCartsFilters)
                Container(
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
                ),
              const SizedBox(width: 8),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ],
          ),

          const SizedBox(height: 16),

          // Campos de filtro - usando Expanded para ocupar espaço disponível
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Código do Carrinho
                  TextField(
                    controller: _codCarrinhoController,
                    decoration: const InputDecoration(
                      labelText: 'Código do Carrinho',
                      hintText: 'Ex: 12345',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_cart),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  // Nome do Carrinho
                  TextField(
                    controller: _nomeCarrinhoController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Carrinho',
                      hintText: 'Ex: Carrinho ABC',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Código de Barras do Carrinho
                  TextField(
                    controller: _codigoBarrasCarrinhoController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Barras do Carrinho',
                      hintText: 'Ex: 7891234567890',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Situação
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
                        _selectedSituacoes.isEmpty
                            ? 'Todas as situações'
                            : '${_selectedSituacoes.length} selecionada(s)',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nome do Usuário de Início
                  TextField(
                    controller: _nomeUsuarioInicioController,
                    decoration: const InputDecoration(
                      labelText: 'Usuário de Início',
                      hintText: 'Ex: João Silva',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Carrinho Agrupador
                  DropdownButtonFormField<Situation>(
                    initialValue: _selectedCarrinhoAgrupador,
                    decoration: const InputDecoration(
                      labelText: 'Carrinho Agrupador',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.group_work),
                    ),
                    items: [
                      const DropdownMenuItem<Situation>(value: null, child: Text('Todos')),
                      ...Situation.values.map(
                        (situation) =>
                            DropdownMenuItem<Situation>(value: situation, child: Text(situation.description)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCarrinhoAgrupador = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Data de Início Inicial
                  InkWell(
                    onTap: () => _selectDataInicioInicial(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data de Início (Inicial)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        _dataInicioInicial != null
                            ? DateHelper.dateToString(_dataInicioInicial!)
                            : 'Selecionar data inicial',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Data de Início Final
                  InkWell(
                    onTap: () => _selectDataInicioFinal(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data de Início (Final)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        _dataInicioFinal != null ? DateHelper.dateToString(_dataInicioFinal!) : 'Selecionar data final',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ), // Fechar SingleChildScrollView e Expanded

          const SizedBox(height: 16),

          // Botões
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.viewModel.isLoading ? null : _clearFilters,
                  child: const Text('Limpar Filtros'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.viewModel.isLoading ? null : _applyFilters,
                  child: widget.viewModel.isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Aplicar Filtros'),
                ),
              ),
            ],
          ),

          // Espaçamento para teclado
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Future<void> _selectDataInicioInicial(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataInicioInicial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _dataInicioInicial) {
      setState(() {
        _dataInicioInicial = picked;
      });
    }
  }

  Future<void> _selectDataInicioFinal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataInicioFinal ?? (_dataInicioInicial ?? DateTime.now()),
      firstDate: _dataInicioInicial ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _dataInicioFinal) {
      setState(() {
        _dataInicioFinal = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _codCarrinhoController.clear();
      _nomeCarrinhoController.clear();
      _codigoBarrasCarrinhoController.clear();
      _nomeUsuarioInicioController.clear();
      _selectedSituacoes.clear();
      _selectedCarrinhoAgrupador = null;
      _dataInicioInicial = null;
      _dataInicioFinal = null;
    });

    widget.viewModel.clearCartsFilters();
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final filters = CartsFiltersModel(
      codCarrinho: _codCarrinhoController.text.trim().isNotEmpty ? _codCarrinhoController.text.trim() : null,
      nomeCarrinho: _nomeCarrinhoController.text.trim().isNotEmpty ? _nomeCarrinhoController.text.trim() : null,
      codigoBarrasCarrinho: _codigoBarrasCarrinhoController.text.trim().isNotEmpty
          ? _codigoBarrasCarrinhoController.text.trim()
          : null,
      situacoes: _selectedSituacoes.isNotEmpty ? _selectedSituacoes : null,
      nomeUsuarioInicio: _nomeUsuarioInicioController.text.trim().isNotEmpty
          ? _nomeUsuarioInicioController.text.trim()
          : null,
      dataInicioInicial: _dataInicioInicial,
      dataInicioFinal: _dataInicioFinal,
      carrinhoAgrupador: _selectedCarrinhoAgrupador ?? Situation.inativo,
    );

    Navigator.of(context).pop();
    widget.viewModel.applyCartsFilters(filters);
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

  /// Retorna apenas as situações que devem aparecer no filtro
  List<ExpeditionSituation> _getFilteredSituations() {
    return [
      ExpeditionSituation.aguardando,
      ExpeditionSituation.emPausa,
      ExpeditionSituation.cancelada,
      ExpeditionSituation.separando,
      ExpeditionSituation.separado,
      ExpeditionSituation.conferindo,
      ExpeditionSituation.conferido,
      ExpeditionSituation.entregue,
      ExpeditionSituation.embalando,
      ExpeditionSituation.embalado,
      ExpeditionSituation.agrupado,
      ExpeditionSituation.finalizada,
      ExpeditionSituation.naoLocalizada,
    ];
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
