import 'package:flutter/material.dart';

import 'package:exp/domain/viewmodels/add_cart_viewmodel.dart';

class CartActionsWidget extends StatefulWidget {
  final AddCartViewModel viewModel;
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  const CartActionsWidget({super.key, required this.viewModel, required this.onCancel, required this.onAdd});

  @override
  State<CartActionsWidget> createState() => _CartActionsWidgetState();
}

class _CartActionsWidgetState extends State<CartActionsWidget> {
  final FocusNode _addButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focar no botão adicionar quando o widget for criado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.canAddCart) {
        _addButtonFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _addButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canAdd = widget.viewModel.canAddCart;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 1,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Informações de confirmação
            if (canAdd) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carrinho Válido',
                            style: textTheme.titleSmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Este carrinho pode ser adicionado à separação.',
                            style: textTheme.bodySmall?.copyWith(color: Colors.green.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carrinho Inválido',
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Situação atual: ${widget.viewModel.scannedCart?.situacaoDescription ?? "Desconhecida"}.\nApenas carrinhos LIBERADOS podem ser adicionados.',
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Botões de ação
            Row(
              children: [
                // Botão Cancelar
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.viewModel.isAdding ? null : widget.onCancel,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Botão Adicionar
                Expanded(
                  child: ElevatedButton.icon(
                    focusNode: _addButtonFocusNode,
                    onPressed: (canAdd && !widget.viewModel.isAdding) ? widget.onAdd : null,
                    icon: widget.viewModel.isAdding
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                          )
                        : const Icon(Icons.add_shopping_cart),
                    label: Text(widget.viewModel.isAdding ? 'Adicionando...' : 'Adicionar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: canAdd ? null : colorScheme.outline.withOpacity(0.3),
                      foregroundColor: canAdd ? null : colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),

            // Dica sobre situação necessária
            if (!canAdd) ...[
              const SizedBox(height: 12),
              Text(
                'Dica: O carrinho deve estar na situação LIBERADO para ser adicionado à separação.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
