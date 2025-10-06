import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/domain/viewmodels/separated_products_viewmodel.dart';

/// Widget que exibe um aviso quando o carrinho não está em situação de separação
class SeparatedProductsCartStatusWarning extends StatelessWidget {
  const SeparatedProductsCartStatusWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SeparatedProductsViewModel>(
      builder: (context, viewModel, child) {
        // Só mostra o aviso se o carrinho não estiver em situação de separação
        if (viewModel.isCartInSeparationStatus) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Carrinho não está em separação',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Este carrinho não está mais em situação de separação. '
                      'Não é possível remover itens da lista de produtos separados.',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
