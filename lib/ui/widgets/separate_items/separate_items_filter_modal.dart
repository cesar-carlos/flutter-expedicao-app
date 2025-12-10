import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/viewmodels/separation_items_viewmodel.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_status.dart';

class SeparateItemsFilterModal extends StatefulWidget {
  final SeparationItemsViewModel viewModel;

  const SeparateItemsFilterModal({super.key, required this.viewModel});

  @override
  State<SeparateItemsFilterModal> createState() => _SeparateItemsFilterModalState();
}

class _SeparateItemsFilterModalState extends State<SeparateItemsFilterModal> {
  late TextEditingController _codProdutoController;
  late TextEditingController _codigoBarrasController;
  late TextEditingController _nomeProdutoController;
  late TextEditingController _enderecoDescricaoController;
  SeparationItemStatus? _selectedSituacao;
  ExpeditionSectorStockModel? _selectedSetorEstoque;

  @override
  void initState() {
    super.initState();

    _codProdutoController = TextEditingController(text: widget.viewModel.itemsFilters.codProduto ?? '');
    _codigoBarrasController = TextEditingController(text: widget.viewModel.itemsFilters.codigoBarras ?? '');
    _nomeProdutoController = TextEditingController(text: widget.viewModel.itemsFilters.nomeProduto ?? '');
    _enderecoDescricaoController = TextEditingController(text: widget.viewModel.itemsFilters.enderecoDescricao ?? '');
    _selectedSituacao = widget.viewModel.itemsFilters.situacao;
    _selectedSetorEstoque = widget.viewModel.itemsFilters.setorEstoque;

    if (!widget.viewModel.sectorsLoaded) {
      widget.viewModel.loadAvailableSectors().then((_) {
        if (mounted) {
          setState(() {
            _syncSelectedSector();
          });
        }
      });
    } else {
      _syncSelectedSector();
    }
  }

  void _syncSelectedSector() {
    if (_selectedSetorEstoque != null && widget.viewModel.availableSectors.isNotEmpty) {
      final matchingSector = widget.viewModel.availableSectors.cast<ExpeditionSectorStockModel?>().firstWhere(
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
    _codProdutoController.dispose();
    _codigoBarrasController.dispose();
    _nomeProdutoController.dispose();
    _enderecoDescricaoController.dispose();
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
          Row(
            children: [
              Icon(Icons.filter_alt, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filtros de Produtos',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.viewModel.hasActiveItemsFilters)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
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

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _codProdutoController,
                    decoration: const InputDecoration(
                      labelText: 'Código do Produto',
                      hintText: 'Ex: 12345',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _codigoBarrasController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Barras',
                      hintText: 'Ex: 7891234567890',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _nomeProdutoController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Produto',
                      hintText: 'Ex: Produto ABC',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _enderecoDescricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço/Descrição',
                      hintText: 'Ex: A1-B2-C3',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<SeparationItemStatus?>(
                    decoration: const InputDecoration(labelText: 'Situação', border: OutlineInputBorder()),
                    initialValue: _selectedSituacao,
                    items: [
                      const DropdownMenuItem<SeparationItemStatus?>(value: null, child: Text('Todos')),
                      ...widget.viewModel.situacaoFilterOptions.map((situacao) {
                        return DropdownMenuItem<SeparationItemStatus?>(
                          value: situacao,
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: situacao.color, size: 12),
                              const SizedBox(width: 8),
                              Text(situacao.description),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (situacao) {
                      setState(() {
                        _selectedSituacao = situacao;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<ExpeditionSectorStockModel?>(
                    decoration: const InputDecoration(
                      labelText: 'Setor de Estoque',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    initialValue: _getValidSelectedSector(),
                    items: [
                      const DropdownMenuItem<ExpeditionSectorStockModel?>(value: null, child: Text('Todos os setores')),
                      ...widget.viewModel.availableSectors.map((setor) {
                        return DropdownMenuItem<ExpeditionSectorStockModel?>(
                          value: setor,
                          child: Text(setor.descricao),
                        );
                      }),
                    ],
                    onChanged: (setor) {
                      setState(() {
                        _selectedSetorEstoque = setor;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

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

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  ExpeditionSectorStockModel? _getValidSelectedSector() {
    if (_selectedSetorEstoque == null) return null;

    if (widget.viewModel.availableSectors.isEmpty) {
      return null;
    }

    final matchingSector = widget.viewModel.availableSectors.cast<ExpeditionSectorStockModel?>().firstWhere(
      (sector) => sector != null && sector == _selectedSetorEstoque,
      orElse: () => null,
    );

    if (matchingSector != null) {
      _selectedSetorEstoque = matchingSector;
      return matchingSector;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedSetorEstoque = null;
        });
      });
      return null;
    }
  }

  void _clearFilters() {
    setState(() {
      _codProdutoController.clear();
      _codigoBarrasController.clear();
      _nomeProdutoController.clear();
      _enderecoDescricaoController.clear();
      _selectedSituacao = null;
      _selectedSetorEstoque = null;
    });

    widget.viewModel.clearItemsFilters();
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final filters = SeparateItemsFiltersModel(
      codProduto: _codProdutoController.text.trim().isNotEmpty ? _codProdutoController.text.trim() : null,
      codigoBarras: _codigoBarrasController.text.trim().isNotEmpty ? _codigoBarrasController.text.trim() : null,
      nomeProduto: _nomeProdutoController.text.trim().isNotEmpty ? _nomeProdutoController.text.trim() : null,
      enderecoDescricao: _enderecoDescricaoController.text.trim().isNotEmpty
          ? _enderecoDescricaoController.text.trim()
          : null,
      situacao: _selectedSituacao,
      setorEstoque: _selectedSetorEstoque,
    );

    Navigator.of(context).pop();
    widget.viewModel.applyItemsFilters(filters);
  }
}
