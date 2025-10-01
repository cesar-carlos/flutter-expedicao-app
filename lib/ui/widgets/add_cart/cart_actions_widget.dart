import 'package:flutter/material.dart';

import 'package:exp/domain/viewmodels/add_cart_viewmodel.dart';
import 'package:exp/ui/widgets/common/custom_flat_button.dart';

class CartActionsWidget extends StatefulWidget {
  final AddCartViewModel viewModel;
  final VoidCallback onCancel;
  final VoidCallback onAdd;
  final VoidCallback? onNewQuery;

  const CartActionsWidget({
    super.key,
    required this.viewModel,
    required this.onCancel,
    required this.onAdd,
    this.onNewQuery,
  });

  @override
  State<CartActionsWidget> createState() => _CartActionsWidgetState();
}

class _CartActionsWidgetState extends State<CartActionsWidget> {
  final _addButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

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
                            'Situação atual: ${widget.viewModel.scannedCart?.situacaoDescription ?? "Desconhecida"}',
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

            if (canAdd) ...[
              // Botões para carrinho válido
              Row(
                children: [
                  // Botão Cancelar - apenas ícone para economizar espaço
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: widget.viewModel.isAdding ? null : widget.onCancel,
                        child: Center(child: Icon(Icons.close, color: colorScheme.outline, size: 20)),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Botão Adicionar - usando CustomFlatButton ocupando o espaço restante
                  Expanded(
                    child: CustomFlatButton(
                      text: widget.viewModel.isAdding ? 'Adicionando...' : 'Adicionar',
                      icon: Icons.add_shopping_cart,
                      onPressed: !widget.viewModel.isAdding ? widget.onAdd : null,
                      isLoading: widget.viewModel.isAdding,
                      backgroundColor: colorScheme.primary,
                      textColor: colorScheme.onPrimary,
                      borderRadius: 8,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Botões para carrinho inválido
              Row(
                children: [
                  // Botão Cancelar - apenas ícone para economizar espaço
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: widget.viewModel.isAdding ? null : widget.onCancel,
                        child: Center(child: Icon(Icons.close, color: colorScheme.outline, size: 20)),
                      ),
                    ),
                  ),

                  if (widget.onNewQuery != null) ...[
                    const SizedBox(width: 12),
                    // Botão Nova Consulta - usando CustomFlatButton ocupando o espaço restante
                    Expanded(
                      child: CustomFlatButton(
                        text: widget.viewModel.isScanning ? 'Buscando...' : 'Nova Consulta',
                        icon: Icons.search,
                        onPressed: widget.viewModel.isScanning ? null : widget.onNewQuery,
                        isLoading: widget.viewModel.isScanning,
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        borderRadius: 8,
                      ),
                    ),
                  ],
                ],
              ),
            ],

            if (!canAdd) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.error.withOpacity(0.2)),
                ),
                child: Text(
                  'Carrinho deve estar na situação LIBERADO para ser adicionado à separação.',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
