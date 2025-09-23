import 'package:flutter/material.dart';
import 'package:exp/domain/viewmodels/separate_items_viewmodel.dart';
import 'package:exp/domain/models/separate_items_filters_model.dart';

/// Modal para filtros da aba de produtos
class SeparateItemsFilterModal extends StatefulWidget {
  final SeparateItemsViewModel viewModel;

  const SeparateItemsFilterModal({super.key, required this.viewModel});

  @override
  State<SeparateItemsFilterModal> createState() => _SeparateItemsFilterModalState();
}

class _SeparateItemsFilterModalState extends State<SeparateItemsFilterModal> {
  late TextEditingController _codProdutoController;
  late TextEditingController _codigoBarrasController;
  late TextEditingController _nomeProdutoController;
  late TextEditingController _enderecoDescricaoController;

  @override
  void initState() {
    super.initState();

    _codProdutoController = TextEditingController(text: widget.viewModel.itemsFilters.codProduto ?? '');
    _codigoBarrasController = TextEditingController(text: widget.viewModel.itemsFilters.codigoBarras ?? '');
    _nomeProdutoController = TextEditingController(text: widget.viewModel.itemsFilters.nomeProduto ?? '');
    _enderecoDescricaoController = TextEditingController(text: widget.viewModel.itemsFilters.enderecoDescricao ?? '');
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
          // Header
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

          // Campos de filtro
          SingleChildScrollView(
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
              ],
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

  void _clearFilters() {
    setState(() {
      _codProdutoController.clear();
      _codigoBarrasController.clear();
      _nomeProdutoController.clear();
      _enderecoDescricaoController.clear();
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
    );

    Navigator.of(context).pop();
    widget.viewModel.applyItemsFilters(filters);
  }
}
