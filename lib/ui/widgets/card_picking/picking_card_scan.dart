import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/domain/viewmodels/socket_viewmodel.dart';

class PickingCardScan extends StatefulWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final CardPickingViewModel viewModel;

  const PickingCardScan({super.key, required this.cart, required this.viewModel});

  @override
  State<PickingCardScan> createState() => _PickingCardScanState();
}

class _PickingCardScanState extends State<PickingCardScan> {
  final TextEditingController _scanController = TextEditingController();
  final FocusNode _scanFocusNode = FocusNode();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final FocusNode _quantityFocusNode = FocusNode();

  Timer? _scanTimer;
  bool _keyboardEnabled = false; // Estado do teclado

  @override
  void initState() {
    super.initState();

    // Listener para detectar quando o scanner termina de enviar o código
    _scanController.addListener(_onScannerInput);

    // Manter o foco no campo para receber dados do scanner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanFocusNode.requestFocus();
    });
  }

  void _onScannerInput() {
    // Cancelar timer anterior se existir
    _scanTimer?.cancel();

    // Criar novo timer que dispara após 300ms de inatividade
    // (indicando que o scanner terminou de enviar o código)
    // Só funciona quando teclado está desabilitado (modo scanner)
    if (_scanController.text.isNotEmpty && !_keyboardEnabled) {
      _scanTimer = Timer(const Duration(milliseconds: 300), () {
        if (_scanController.text.isNotEmpty) {
          _onBarcodeScanned(_scanController.text);
        }
      });
    }
  }

  void _toggleKeyboard() {
    setState(() {
      _keyboardEnabled = !_keyboardEnabled;
    });

    // Forçar foco e abrir teclado quando necessário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_keyboardEnabled) {
        // Perder foco primeiro, depois recuperar para forçar o teclado
        _scanFocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          _scanFocusNode.requestFocus();
        });
      } else {
        _scanFocusNode.requestFocus();
      }
    });

    // Mostrar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _keyboardEnabled
              ? 'Modo teclado ativado - Digite o código manualmente'
              : 'Modo scanner ativado - Use o scanner integrado',
        ),
        backgroundColor: _keyboardEnabled ? Colors.blue : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _scanController.removeListener(_onScannerInput);
    _scanController.dispose();
    _scanFocusNode.dispose();
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + (bottomInset > 0 ? 60 : 0)),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumo de separação ordenado por endereço
            _buildSeparationSummary(context, theme, colorScheme),

            const SizedBox(height: 6),

            // Campo de entrada do scanner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.barcode_reader, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Escaneie o código de barras',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Consumer<SocketViewModel>(
                        builder: (context, socketViewModel, child) {
                          final isConnected = socketViewModel.isConnected;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isConnected ? Colors.green : Colors.red).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isConnected ? Icons.wifi : Icons.wifi_off,
                                  color: isConnected ? Colors.green : Colors.red,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  socketViewModel.connectionStateDescription,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isConnected ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _scanController,
                    focusNode: _scanFocusNode,
                    autofocus: true,
                    readOnly: !_keyboardEnabled,
                    keyboardType: _keyboardEnabled ? TextInputType.number : TextInputType.none,
                    decoration: InputDecoration(
                      hintText: _keyboardEnabled ? 'Digite o código...' : 'Aguardando scanner',
                      prefixIcon: IconButton(
                        icon: Icon(
                          _keyboardEnabled ? Icons.keyboard : Icons.qr_code_scanner,
                          color: colorScheme.primary,
                        ),
                        onPressed: _toggleKeyboard,
                        tooltip: _keyboardEnabled ? 'Usar scanner' : 'Usar teclado',
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                        onPressed: () {
                          _scanController.clear();
                          _scanFocusNode.requestFocus();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    onSubmitted: _onBarcodeScanned,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _keyboardEnabled
                        ? 'Digite o código de barras e pressione Enter'
                        : 'Posicione o produto no scanner ou toque no ícone para usar o teclado',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Campo de quantidade
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Quantidade a Separar',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Botão diminuir
                      IconButton(
                        onPressed: () {
                          final currentValue = int.tryParse(_quantityController.text) ?? 1;
                          if (currentValue > 1) {
                            _quantityController.text = (currentValue - 1).toString();
                          }
                        },
                        icon: Icon(Icons.remove, color: Colors.orange),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.orange.withOpacity(0.1),
                          shape: CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Campo de quantidade
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          focusNode: _quantityFocusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '1',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.orange, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.orange.withOpacity(0.05),
                          ),
                          onChanged: (value) {
                            // Validar que seja um número positivo
                            final intValue = int.tryParse(value);
                            if (intValue == null || intValue < 1) {
                              _quantityController.text = '1';
                              _quantityController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _quantityController.text.length),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botão aumentar
                      IconButton(
                        onPressed: () {
                          final currentValue = int.tryParse(_quantityController.text) ?? 1;
                          _quantityController.text = (currentValue + 1).toString();
                        },
                        icon: Icon(Icons.add, color: Colors.orange),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.orange.withOpacity(0.1),
                          shape: CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Defina a quantidade que será separada quando escanear o produto',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparationSummary(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    // Ordenar produtos por enderecoDescricao
    final sortedItems = List.from(widget.viewModel.items)
      ..sort((a, b) => (a.enderecoDescricao ?? '').compareTo(b.enderecoDescricao ?? ''));

    // Encontrar o próximo item a ser separado (primeiro não completo)
    final nextItem = sortedItems.where((item) => !widget.viewModel.isItemCompleted(item.item)).firstOrNull;

    // Contar itens completos e totais
    final completedCount = sortedItems.where((item) => widget.viewModel.isItemCompleted(item.item)).length;
    final totalCount = sortedItems.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.my_location, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Próximo Item',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: completedCount == totalCount
                      ? Colors.green.withOpacity(0.2)
                      : colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/$totalCount',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: completedCount == totalCount ? Colors.green.shade700 : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Produto atual
          if (nextItem != null) ...[
            const SizedBox(height: 6),

            // Endereço destacado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nextItem.enderecoDescricao ?? 'Endereço não definido',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Informações do produto
            Text(
              'Produto',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              nextItem.nomeProduto,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // Detalhes em grid
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildDetailItem(theme, colorScheme, 'Unidade', nextItem.codUnidadeMedida, Icons.straighten),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildDetailItem(
                      theme,
                      colorScheme,
                      'Quantidade',
                      '${widget.viewModel.getPickedQuantity(nextItem.item)}/${nextItem.quantidade}',
                      Icons.inventory_2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Código de barras se disponível
            if (nextItem.codigoBarras != null && nextItem.codigoBarras!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.qr_code, color: colorScheme.onSurfaceVariant, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nextItem.codigoBarras!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            // Todos os itens foram separados
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 6),
                  Text(
                    'Separação Concluída!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Todos os itens foram separados com sucesso.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(ThemeData theme, ColorScheme colorScheme, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    if (barcode.trim().isEmpty) return;

    // Obter a quantidade informada
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    // Buscar o produto pelo código de barras
    final items = widget.viewModel.items;
    SeparateItemConsultationModel? foundItem;

    for (final item in items) {
      if (item.codigoBarras != null && item.codigoBarras!.trim().toLowerCase() == barcode.trim().toLowerCase()) {
        foundItem = item;
        break;
      }
    }

    if (foundItem != null) {
      // Produto encontrado - adicionar na separação via use case
      await _addItemToSeparation(foundItem, barcode, quantity);
    } else {
      // Produto não encontrado
      _showProductNotFoundDialog(barcode);
    }

    // Limpar o campo e manter o foco
    _scanController.clear();
    _scanFocusNode.requestFocus();
  }

  /// Adiciona item escaneado na separação via use case
  Future<void> _addItemToSeparation(SeparateItemConsultationModel item, String barcode, int quantity) async {
    final currentPicked = widget.viewModel.getPickedQuantity(item.item);
    final maxQuantity = item.quantidade.toInt();

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Chamar use case através do ViewModel
      final result = await widget.viewModel.addScannedItem(codProduto: item.codProduto, quantity: quantity);

      // Fechar loading
      if (mounted) Navigator.of(context).pop();

      if (result.isSuccess) {
        // Sucesso - mostrar feedback positivo
        _showSuccessDialog(item, quantity, currentPicked + quantity, maxQuantity);
      } else {
        // Erro - mostrar mensagem de erro
        _showErrorDialog(item, result.message, barcode);
      }
    } catch (e) {
      // Fechar loading
      if (mounted) Navigator.of(context).pop();

      // Mostrar erro inesperado
      _showErrorDialog(item, 'Erro inesperado: ${e.toString()}', barcode);
    }
  }

  void _showSuccessDialog(SeparateItemConsultationModel item, int quantity, int newTotal, int maxQuantity) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            const Expanded(child: Text('Item Adicionado!', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produto: ${item.nomeProduto}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Endereço: ${item.enderecoDescricao}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quantidade adicionada:', style: theme.textTheme.bodySmall),
                      Text(
                        '+$quantity',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total separado:', style: theme.textTheme.bodySmall),
                      Text(
                        '$newTotal / $maxQuantity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: newTotal >= maxQuantity ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(SeparateItemConsultationModel item, String errorMessage, String barcode) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Expanded(child: Text('Erro ao Adicionar', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: $barcode', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Produto: ${item.nomeProduto}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(errorMessage, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red.shade700)),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
      ),
    );
  }

  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Expanded(child: Text('Produto Não Encontrado', overflow: TextOverflow.ellipsis, maxLines: 1)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código escaneado: $barcode'),
            const SizedBox(height: 6),
            const Text('Este produto não está na lista de itens para separação.'),
            const SizedBox(height: 6),
            const Text('Verifique se:'),
            const Text('• O código está correto'),
            const Text('• O produto faz parte desta separação'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
      ),
    );
  }
}
