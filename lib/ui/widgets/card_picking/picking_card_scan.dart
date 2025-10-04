import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:exp/di/locator.dart';
import 'package:exp/core/services/audio_service.dart';
import 'package:exp/ui/widgets/card_picking/widgets/index.dart';
import 'package:exp/core/services/barcode_validation_service.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/ui/widgets/common/picking_dialog.dart';

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
      final text = _scanController.text.trim();

      // Verificar se parece com um código de barras completo (8-14 dígitos)
      if (text.length >= 8 && RegExp(r'^\d{8,14}$').hasMatch(text)) {
        // Scanner detectou código completo - processar imediatamente
        final barcode = text;
        // Aguardar um pouco para o usuário ver o valor antes de limpar
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _scanController.clear();
          }
        });
        _onBarcodeScanned(barcode);
        return;
      }

      // Aguardar mais caracteres ou fim da entrada do scanner
      _scanTimer = Timer(const Duration(milliseconds: 300), () {
        if (_scanController.text.isNotEmpty) {
          final barcode = _scanController.text.trim();
          // Aguardar um pouco para o usuário ver o valor antes de limpar
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _scanController.clear();
            }
          });
          _onBarcodeScanned(barcode);
        }
      });
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

    // Validar código de barras usando o serviço
    final validationResult = BarcodeValidationService.validateScannedBarcode(
      barcode,
      widget.viewModel.items,
      widget.viewModel.isItemCompleted,
      userSectorCode: widget.viewModel.userModel?.codSetorEstoque,
    );

    if (validationResult.isEmpty) {
      return;
    }

    if (validationResult.noItemsForSector) {
      // Reproduzir som de alerta para não haver mais itens do setor
      _audioService.playAlert();
      _showNoItemsForSectorDialog(validationResult.userSectorCode!);
      return;
    }

    if (validationResult.allItemsCompleted) {
      // Reproduzir som de alerta para todos os itens completos
      _audioService.playAlert();
      _showAllItemsCompletedDialog();
      return;
    }

    if (validationResult.isWrongSector) {
      // Reproduzir som de erro para produto de outro setor
      _audioService.playError();
      _showWrongSectorDialog(barcode, validationResult.scannedItem!, validationResult.userSectorCode!);
      return;
    }

    if (validationResult.isValid && validationResult.expectedItem != null) {
      await _addItemToSeparation(validationResult.expectedItem!, barcode, quantity);
    } else {
      // Reproduzir som de erro para produto errado
      _audioService.playError();
      _showWrongProductDialog(barcode, validationResult.expectedItem!);
    }
  }

  /// Adiciona item escaneado na separação via use case
  Future<void> _addItemToSeparation(SeparateItemConsultationModel item, String barcode, int quantity) async {
    try {
      // Chamar use case através do ViewModel
      final result = await widget.viewModel.addScannedItem(codProduto: item.codProduto, quantity: quantity);

      if (result.isSuccess) {
        // Verificar se o item foi completamente separado após adicionar a quantidade
        final itemId = item.item;
        final wasCompletedBefore = widget.viewModel.isItemCompleted(itemId);
        final currentPickedQuantity = widget.viewModel.getPickedQuantity(itemId);
        final totalQuantity = item.quantidade.toInt();
        final newPickedQuantity = currentPickedQuantity + quantity;

        // Reproduzir som de scan bem-sucedido e feedback tátil
        _audioService.playBarcodeScan();
        _provideTactileFeedback();

        // Verificar se o item foi completado após a adição
        // Aguardar um pouco para o ViewModel atualizar o estado
        await Future.delayed(const Duration(milliseconds: 100));
        final isCompletedNow = widget.viewModel.isItemCompleted(itemId);

        // Debug: Log para verificar o estado
        if (kDebugMode) {
          print('Item $itemId - Antes: $wasCompletedBefore, Depois: $isCompletedNow');
          print('Quantidades - Atual: $currentPickedQuantity, Nova: $newPickedQuantity, Total: $totalQuantity');
        }

        // Verificar se o item foi completado baseado na lógica de quantidades
        // Se não estava completo antes e a nova quantidade >= total, então foi completado
        final wasCompletedByQuantity = !wasCompletedBefore && newPickedQuantity >= totalQuantity;

        // Se o item não estava completo antes e agora está (por estado ou por quantidade), reproduzir som especial
        if ((wasCompletedBefore && isCompletedNow)) {
          _audioService.playItemCompleted();
        }

        // Resetar quantidade para 1 se estiver maior que 1
        if (_quantityController.text.isNotEmpty && int.tryParse(_quantityController.text) != null) {
          final currentQuantity = int.parse(_quantityController.text);
          if (currentQuantity > 1) _quantityController.text = '1';
        }

        // 🆕 VERIFICAR: Acabaram os itens do setor após adicionar este item?
        await _checkIfSectorItemsCompleted();
      } else {
        // Reproduzir som de erro
        _audioService.playError();

        // Erro - mostrar mensagem de erro
        _showErrorDialog(item, result.message, barcode);
      }
    } catch (e) {
      // Reproduzir som de erro
      _audioService.playError();

      // Mostrar erro inesperado
      _showErrorDialog(item, 'Erro inesperado: ${e.toString()}', barcode);
    }
  }

  /// Verifica se todos os itens do setor do usuário foram separados
  /// Se sim, oferece opção de salvar o carrinho imediatamente
  Future<void> _checkIfSectorItemsCompleted() async {
    final userSectorCode = widget.viewModel.userModel?.codSetorEstoque;

    // Se usuário não tem setor definido, não fazer nada
    if (userSectorCode == null) return;

    // Verificar se ainda há itens do setor para separar
    if (!widget.viewModel.hasItemsForUserSector) {
      // Reproduzir som de separação completa
      await _audioService.playAlertComplete();

      // Mostrar diálogo oferecendo salvar o carrinho
      _showSaveCartAfterSectorCompletedDialog(userSectorCode);
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
    showDialog(
      context: context,
      builder: (context) =>
          PickingDialogs.addItemError(barcode: barcode, productName: item.nomeProduto, errorMessage: errorMessage),
    ).then((_) {
      // Retornar foco para o campo de scanner após fechar o diálogo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanFocusNode.requestFocus();
      });
    });
  }

  void _showWrongProductDialog(String barcode, SeparateItemConsultationModel expectedItem) {
    showDialog(
      context: context,
      builder: (context) => PickingDialogs.wrongProduct(
        scannedBarcode: barcode,
        expectedAddress: expectedItem.enderecoDescricao ?? 'Endereço não definido',
        expectedProduct: expectedItem.nomeProduto,
        expectedBarcode: expectedItem.codigoBarras,
      ),
    ).then((_) {
      // Retornar foco para o campo de scanner após fechar o diálogo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanFocusNode.requestFocus();
      });
    });
  }

  void _showWrongSectorDialog(String barcode, SeparateItemConsultationModel scannedItem, int userSectorCode) {
    showDialog(
      context: context,
      builder: (context) => PickingDialogs.wrongSector(
        scannedBarcode: barcode,
        productName: scannedItem.nomeProduto,
        productSector: scannedItem.nomeSetorEstoque ?? 'Setor ${scannedItem.codSetorEstoque}',
        userSectorCode: userSectorCode,
      ),
    ).then((_) {
      // Retornar foco para o campo de scanner após fechar o diálogo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanFocusNode.requestFocus();
      });
    });
  }

  void _showNoItemsForSectorDialog(int userSectorCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PickingDialogs.noItemsForSector(
        userSectorCode: userSectorCode,
        onFinish: () async {
          Navigator.of(context).pop(); // Fechar o diálogo
          await _finishPicking();
        },
        onCancel: () {
          Navigator.of(context).pop(); // Fechar o diálogo
          // Retornar foco para o scanner
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scanFocusNode.requestFocus();
          });
        },
      ),
    );
  }

  void _showAllItemsCompletedDialog() {
    showDialog(context: context, builder: (context) => PickingDialogs.separationComplete()).then((_) {
      // Retornar foco para o campo de scanner após fechar o diálogo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanFocusNode.requestFocus();
      });
    });
  }

  Future<void> _finishPicking() async {
    // Voltar para a tela anterior
    if (mounted) {
      Navigator.of(context).pop(true); // Pop com resultado true indicando finalização
    }
  }

  /// Mostra diálogo após completar todos os itens do setor, oferecendo salvar o carrinho
  void _showSaveCartAfterSectorCompletedDialog(int userSectorCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Setor Concluído!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Text(
                    '✓ Todos os itens do seu setor foram separados!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text('Seu setor: Setor $userSectorCode', style: TextStyle(color: Colors.green.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Deseja salvar o carrinho agora?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'Os itens restantes pertencem a outros setores e serão separados por outros usuários.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fechar o diálogo
              // Retornar foco para o scanner
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scanFocusNode.requestFocus();
              });
            },
            child: const Text('Continuar Escaneando'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop(); // Fechar o diálogo
              await _saveCartAndReturn();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('Salvar Carrinho', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Salva o carrinho e volta para a tela anterior
  Future<void> _saveCartAndReturn() async {
    // Voltar para a tela anterior indicando que deve salvar
    if (mounted) {
      Navigator.of(context).pop('save_cart'); // Pop com resultado especial
    }
  }
}
