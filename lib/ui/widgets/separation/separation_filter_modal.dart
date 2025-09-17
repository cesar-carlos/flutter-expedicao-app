import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exp/domain/viewmodels/separation_viewmodel.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';

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
  String? _selectedSituacao;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<SeparationViewModel>();

    _codSepararEstoqueController = TextEditingController(text: viewModel.codSepararEstoqueFilter ?? '');
    _codOrigemController = TextEditingController(text: viewModel.codOrigemFilter ?? '');
    _selectedOrigem = viewModel.origemFilter;
    _selectedSituacao = viewModel.situacaoFilter;
    _selectedDate = viewModel.dataEmissaoFilter;
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

          // Situação
          DropdownButtonFormField<String>(
            initialValue: _selectedSituacao,
            decoration: const InputDecoration(
              labelText: 'Situação',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info),
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('Todas as situações')),
              ...ExpeditionSituation.values.map(
                (situacao) => DropdownMenuItem<String>(value: situacao.code, child: Text(situacao.description)),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSituacao = value;
              });
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
      _selectedSituacao = null;
      _selectedDate = null;
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
    viewModel.setSituacaoFilter(_selectedSituacao);
    viewModel.setDataEmissaoFilter(_selectedDate);

    Navigator.of(context).pop();
    viewModel.applyFilters();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
