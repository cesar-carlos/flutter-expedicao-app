import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/separate_consultation_viewmodel.dart';

class ConsultationFilterDialogContent extends StatefulWidget {
  const ConsultationFilterDialogContent({super.key, required this.viewModel, required this.onConsult});

  final ShipmentSeparateConsultationViewModel viewModel;
  final void Function(String filterType, int pageSize, String inputValue) onConsult;

  @override
  State<ConsultationFilterDialogContent> createState() => _ConsultationFilterDialogContentState();
}

class _ConsultationFilterDialogContentState extends State<ConsultationFilterDialogContent> {
  final TextEditingController _paramsController = TextEditingController();
  String _selectedFilter = 'todos';
  late int _pageSize;

  @override
  void initState() {
    super.initState();
    _pageSize = widget.viewModel.pageSize;
  }

  @override
  void dispose() {
    _paramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Escolha o tipo de consulta:', style: AppFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: UIConstants.defaultPadding),

        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'todos', label: Text('Todas as separações'), icon: Icon(Icons.all_inbox)),
            ButtonSegment(value: 'codigo', label: Text('Por código'), icon: Icon(Icons.tag)),
            ButtonSegment(value: 'status', label: Text('Por situação'), icon: Icon(Icons.flag)),
          ],
          selected: {_selectedFilter},
          onSelectionChanged: (selection) {
            setState(() => _selectedFilter = selection.first);
          },
        ),

        const SizedBox(height: UIConstants.defaultPadding),

        if (_selectedFilter == 'codigo') ...[
          TextField(
            controller: _paramsController,
            decoration: const InputDecoration(
              labelText: 'Código da separação',
              hintText: 'Ex: 123',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
            keyboardType: TextInputType.number,
          ),
        ] else if (_selectedFilter == 'status') ...[
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Situação',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag),
            ),
            items: ExpeditionSituation.values.map((situation) {
              return DropdownMenuItem(value: situation.code, child: Text(situation.description));
            }).toList(),
            onChanged: (value) {
              _paramsController.text = value ?? '';
            },
          ),
        ],

        const SizedBox(height: UIConstants.defaultPadding),

        Container(
          padding: const EdgeInsets.all(UIConstants.smallPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.view_list, color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Configurações de Paginação',
                      style: AppFonts.inter(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Registros por página:'),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: _pageSize,
                    items: [10, 20, 50, 100].map((size) {
                      return DropdownMenuItem(value: size, child: Text('$size'));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _pageSize = value ?? 20;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: UIConstants.defaultPadding),
        Container(
          padding: const EdgeInsets.all(UIConstants.smallPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedFilter == 'todos'
                      ? 'Esta consulta retornará todas as separações disponíveis no sistema com paginação.'
                      : 'Esta consulta filtrará as separações baseada nos critérios selecionados com paginação.',
                  style: AppFonts.inter(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: UIConstants.largePadding),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Consultar'),
              onPressed: () {
                Navigator.of(context).pop();

                widget.onConsult(_selectedFilter, _pageSize, _paramsController.text.trim());
              },
            ),
          ],
        ),
      ],
    );
  }
}
