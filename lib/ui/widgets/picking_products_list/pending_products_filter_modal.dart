import 'package:flutter/material.dart';

import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/domain/models/filter/pending_products_filters_model.dart';
import 'package:exp/domain/models/expedition_sector_stock_model.dart';
import 'package:exp/domain/models/separation_item_status.dart';

/// Modal para filtros da tela de produtos pendentes
class PendingProductsFilterModal extends StatefulWidget {
  final CardPickingViewModel viewModel;

  const PendingProductsFilterModal({super.key, required this.viewModel});

  @override
  State<PendingProductsFilterModal> createState() => _PendingProductsFilterModalState();
}

class _PendingProductsFilterModalState extends State<PendingProductsFilterModal> {
  late TextEditingController _codProdutoController;
  late TextEditingController _codigoBarrasController;
  late TextEditingController _nomeProdutoController;
  late TextEditingController _enderecoDescricaoController;
  SeparationItemStatus? _selectedSituacao;
  ExpeditionSectorStockModel? _selectedSetorEstoque;

  @override
  void initState() {
    super.initState();

    _codProdutoController = TextEditingController(text: widget.viewModel.filters.codProduto ?? '');
    _codigoBarrasController = TextEditingController(text: widget.viewModel.filters.codigoBarras ?? '');
    _nomeProdutoController = TextEditingController(text: widget.viewModel.filters.nomeProduto ?? '');
    _enderecoDescricaoController = TextEditingController(text: widget.viewModel.filters.enderecoDescricao ?? '');
    _selectedSituacao = widget.viewModel.filters.situacao;
    _selectedSetorEstoque = widget.viewModel.filters.setorEstoque;

    // Carrega setores de estoque se ainda não foram carregados
    if (!widget.viewModel.sectorsLoaded) {
      widget.viewModel.loadAvailableSectors().then((_) {
        // Após carregar os setores, atualiza o estado para garantir que o dropdown seja reconstruído
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
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
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
                  'Filtros de Produtos Pendentes',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.viewModel.hasActiveFilters)
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

          const SizedBox(height: 24),

          // Campos de filtro - Usando Flexible para permitir scroll
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Código do Produto
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

                  // Código de Barras
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

                  // Nome do Produto
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

                  // Endereço/Descrição
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

                  // Situação
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

                  // Setor de Estoque
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

          const SizedBox(height: 24),

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

  /// Retorna o setor selecionado se ele ainda existe na lista, senão retorna null
  ExpeditionSectorStockModel? _getValidSelectedSector() {
    if (_selectedSetorEstoque == null) return null;

    // Se os setores ainda não foram carregados, retorna null e força o carregamento
    if (widget.viewModel.availableSectors.isEmpty) {
      return null;
    }

    // Procura o setor na lista de setores disponíveis usando o operador == do modelo
    final matchingSector = widget.viewModel.availableSectors.cast<ExpeditionSectorStockModel?>().firstWhere(
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

    widget.viewModel.clearFilters();
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final filters = PendingProductsFiltersModel(
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
    widget.viewModel.applyFilters(filters);
  }
}
