import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:exp/ui/widgets/card_picking/widgets/index.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/core/services/audio_service.dart';
import 'package:exp/di/locator.dart';

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
  final AudioService _audioService = locator<AudioService>();

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

    // Diferentes estratégias para scanner vs teclado
    if (!_keyboardEnabled && _scanController.text.isNotEmpty) {
      // Modo scanner: usar timer para detectar fim da entrada
      _scanTimer = Timer(const Duration(milliseconds: 500), () {
        if (_scanController.text.isNotEmpty) {
          _onBarcodeScanned(_scanController.text);
        }
      });
    }

    // Detectar códigos de barras comuns (8-14 dígitos) automaticamente
    if (!_keyboardEnabled && _scanController.text.length >= 8) {
      final text = _scanController.text.trim();
      // Verificar se parece com um código de barras (apenas números)
      if (RegExp(r'^\d{8,14}$').hasMatch(text)) {
        _scanTimer?.cancel();
        _onBarcodeScanned(text);
      }
    }
  }

  void _toggleKeyboard() {
    setState(() {
      _keyboardEnabled = !_keyboardEnabled;
    });

    // Forçar foco e controlar teclado quando necessário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_keyboardEnabled) {
        // Perder foco primeiro, depois recuperar para forçar o teclado
        _scanFocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          _scanFocusNode.requestFocus();
        });
      } else {
        // Fechar teclado virtual primeiro
        _scanFocusNode.unfocus();
        FocusScope.of(context).unfocus(); // Garantir que teclado feche
        // Depois manter foco para receber dados do scanner físico
        Future.delayed(const Duration(milliseconds: 200), () {
          _scanFocusNode.requestFocus();
        });
      }
    });
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + (bottomInset > 0 ? 60 : 0)),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card do próximo item
            NextItemCard(viewModel: widget.viewModel),

            const SizedBox(height: 6),

            // Card de seleção de quantidade
            QuantitySelectorCard(controller: _quantityController, focusNode: _quantityFocusNode),

            const SizedBox(height: 6),

            // Card do scanner de código de barras
            BarcodeScannerCard(
              controller: _scanController,
              focusNode: _scanFocusNode,
              keyboardEnabled: _keyboardEnabled,
              onToggleKeyboard: _toggleKeyboard,
              onSubmitted: _onBarcodeScanned,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    if (barcode.trim().isEmpty) return;

    // Obter a quantidade informada
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    // Ordenar produtos por enderecoDescricao para obter sequência correta
    final items = List.from(widget.viewModel.items)
      ..sort((a, b) => (a.enderecoDescricao ?? '').compareTo(b.enderecoDescricao ?? ''));

    // Encontrar o próximo item a ser separado (primeiro não completo)
    final nextItem = items.where((item) => !widget.viewModel.isItemCompleted(item.item)).firstOrNull;

    if (nextItem == null) {
      // Reproduzir som de alerta para todos os itens completos
      _audioService.playAlert();
      _showAllItemsCompletedDialog();
      _scanController.clear();
      _scanFocusNode.requestFocus();
      return;
    }

    // Verificar se o código bipado corresponde ao próximo item
    final trimmedBarcode = barcode.trim().toLowerCase();
    final expectedBarcode1 = nextItem.codigoBarras?.trim().toLowerCase();
    final expectedBarcode2 = nextItem.codigoBarras2?.trim().toLowerCase();

    final isCorrectBarcode =
        (expectedBarcode1 != null && expectedBarcode1 == trimmedBarcode) ||
        (expectedBarcode2 != null && expectedBarcode2 == trimmedBarcode);

    if (isCorrectBarcode) {
      await _addItemToSeparation(nextItem, barcode, quantity);
    } else {
      // Reproduzir som de erro para produto errado
      _audioService.playError();
      _showWrongProductDialog(barcode, nextItem);
    }

    // Limpar o campo e manter o foco
    _scanController.clear();
    _scanFocusNode.requestFocus();
  }

  /// Adiciona item escaneado na separação via use case
  Future<void> _addItemToSeparation(SeparateItemConsultationModel item, String barcode, int quantity) async {
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
        // Reproduzir som de scan bem-sucedido e feedback tátil
        _audioService.playBarcodeScan();
        _provideTactileFeedback();

        // Resetar quantidade para 1 se estiver maior que 1
        if (_quantityController.text.isNotEmpty && int.tryParse(_quantityController.text) != null) {
          final currentQuantity = int.parse(_quantityController.text);
          if (currentQuantity > 1) {
            _quantityController.text = '1';
          }
        }
      } else {
        // Reproduzir som de erro
        _audioService.playError();

        // Erro - mostrar mensagem de erro
        _showErrorDialog(item, result.message, barcode);
      }
    } catch (e) {
      // Fechar loading
      if (mounted) Navigator.of(context).pop();

      // Reproduzir som de erro
      _audioService.playError();

      // Mostrar erro inesperado
      _showErrorDialog(item, 'Erro inesperado: ${e.toString()}', barcode);
    }
  }

  void _provideTactileFeedback() {
    try {
      // Feedback tátil leve para confirmar sucesso
      HapticFeedback.lightImpact();
    } catch (e) {
      // Ignorar se não suportado no dispositivo
    }
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

  void _showWrongProductDialog(String barcode, SeparateItemConsultationModel expectedItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            const Expanded(child: Text('Produto Incorreto', overflow: TextOverflow.ellipsis, maxLines: 1)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código escaneado: $barcode'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próximo produto esperado:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
                  const SizedBox(height: 6),
                  Text('📍 ${expectedItem.enderecoDescricao}'),
                  Text('📦 ${expectedItem.nomeProduto}'),
                  if (expectedItem.codigoBarras != null) Text('🏷️ ${expectedItem.codigoBarras}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Escaneie o produto correto da sequência de separação.'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Entendi'))],
      ),
    );
  }

  void _showAllItemsCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            const Expanded(child: Text('Separação Completa!', overflow: TextOverflow.ellipsis, maxLines: 1)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎉 Parabéns! Todos os itens foram separados com sucesso.'),
            SizedBox(height: 12),
            Text('Você pode:'),
            Text('• Revisar os itens separados no menu'),
            Text('• Finalizar a separação'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }
}
