import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/presentation/viewmodels/separate_consultation_viewmodel.dart';

class ConsultationPaginationControls extends StatelessWidget {
  const ConsultationPaginationControls({super.key, required this.viewModel});

  final ShipmentSeparateConsultationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Text(
            'Página ${viewModel.currentPage + 1} - ${viewModel.consultations.length} registros',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),

          IconButton(
            onPressed: viewModel.currentPage > 0 && !viewModel.isLoading
                ? () => viewModel.loadPage(viewModel.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(UIConstants.largeBorderRadius),
            ),
            child: Text(
              '${viewModel.currentPage + 1}',
              style: AppFonts.inter(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
          ),

          IconButton(
            onPressed: viewModel.hasMoreData && !viewModel.isLoading ? () => viewModel.loadNextPage() : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próxima página',
          ),
        ],
      ),
    );
  }
}
