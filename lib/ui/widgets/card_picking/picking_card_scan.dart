import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:exp/core/services/audio_service.dart';
import 'package:exp/core/services/barcode_validation_service.dart';
import 'package:exp/di/locator.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/ui/widgets/card_picking/widgets/index.dart';
import 'package:exp/ui/widgets/common/picking_dialog.dart';

class PickingCardScan extends StatefulWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final CardPickingViewModel viewModel;

  const PickingCardScan({super.key, required this.cart, required this.viewModel});

  @override
  State<PickingCardScan> createState() => _PickingCardScanState();
}

class _PickingCardScanState extends State<PickingCardScan> {
  // Controllers e FocusNodes
  final TextEditingController _scanController = TextEditingController();
  final FocusNode _scanFocusNode = FocusNode();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final FocusNode _quantityFocusNode = FocusNode();

  // Estado e timers
  Timer? _scanTimer;
  bool _keyboardEnabled = false;

  // Serviços
  final AudioService _audioService = locator<AudioService>();

  // Constantes para melhor legibilidade
  static const Duration _scannerTimeout = Duration(milliseconds: 300);
  static const Duration _focusDelay = Duration(milliseconds: 100);
  static const Duration _keyboardDelay = Duration(milliseconds: 50);
  static const Duration _initialFocusDelay = Duration(milliseconds: 300);
  static const Duration _displayDelay = Duration(milliseconds: 500);
  static const Duration _stateUpdateDelay = Duration(milliseconds: 100);

  // Padrões de validação
  static final RegExp _barcodePattern = RegExp(r'^\d{8,14}$');
  static const int _minBarcodeLength = 8;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _requestInitialFocus();
  }

  /// Configura os listeners necessários
  void _setupListeners() {
    _scanController.addListener(_onScannerInput);
    _scanFocusNode.addListener(_onFocusChange);
  }

  /// Solicita foco inicial no campo de scanner
  void _requestInitialFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scanFocusNode.requestFocus();

        // Garantir foco após delay para telas que ainda estão carregando
        Future.delayed(_initialFocusDelay, () {
          if (mounted) {
            _scanFocusNode.requestFocus();
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Garantir foco quando as dependências mudarem (tela completamente carregada)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scanFocusNode.requestFocus();
      }
    });
  }

  /// Processa entrada do scanner ou teclado
  void _onScannerInput() {
    _scanTimer?.cancel();

    if (!_keyboardEnabled && _scanController.text.isNotEmpty) {
      _processScannerInput();
    }
  }

  /// Processa entrada específica do scanner
  void _processScannerInput() {
    final text = _scanController.text.trim();

    if (_isCompleteBarcode(text)) {
      _handleCompleteBarcode(text);
    } else {
      _waitForMoreInput();
    }
  }

  /// Verifica se o texto parece ser um código de barras completo
  bool _isCompleteBarcode(String text) {
    return text.length >= _minBarcodeLength && _barcodePattern.hasMatch(text);
  }

  /// Processa código de barras completo detectado pelo scanner
  void _handleCompleteBarcode(String barcode) {
    _clearScannerFieldAfterDelay();
    _onBarcodeScanned(barcode);
  }

  /// Aguarda mais entrada do scanner
  void _waitForMoreInput() {
    _scanTimer = Timer(_scannerTimeout, () {
      if (_scanController.text.isNotEmpty) {
        final barcode = _scanController.text.trim();
        _clearScannerFieldAfterDelay();
        _onBarcodeScanned(barcode);
      }
    });
  }

  /// Limpa o campo do scanner após um delay para o usuário ver o valor
  void _clearScannerFieldAfterDelay() {
    Future.delayed(_displayDelay, () {
      if (mounted) {
        _scanController.clear();
      }
    });
  }

  void _onFocusChange() {
    // Listener simplificado - apenas para debug
    if (_keyboardEnabled && _scanFocusNode.hasFocus) {
      // Campo ganhou foco no modo manual - teclado deveria aparecer automaticamente
      // Não forçar aqui para evitar conflitos com o toggle
    }
  }

  /// Alterna entre modo scanner e teclado
  void _toggleKeyboard() {
    setState(() {
      _keyboardEnabled = !_keyboardEnabled;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_keyboardEnabled) {
          _enableKeyboardMode();
        } else {
          _enableScannerMode();
        }
      }
    });
  }

  /// Habilita modo teclado com abertura automática
  void _enableKeyboardMode() {
    _scanFocusNode.unfocus();

    Future.delayed(_focusDelay, () {
      if (mounted) {
        _scanFocusNode.requestFocus();
        _forceKeyboardShow();
      }
    });
  }

  /// Habilita modo scanner com fechamento do teclado
  void _enableScannerMode() {
    _hideKeyboard();

    Future.delayed(_focusDelay, () {
      if (mounted) {
        _scanFocusNode.requestFocus();
      }
    });
  }

  /// Força a abertura do teclado
  void _forceKeyboardShow() {
    Future.delayed(_keyboardDelay, () {
      if (mounted) {
        try {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        } catch (e) {
          // Fallback: tentar novamente
          Future.delayed(_focusDelay, () {
            if (mounted) {
              _scanFocusNode.requestFocus();
            }
          });
        }
      }
    });
  }

  /// Esconde o teclado
  void _hideKeyboard() {
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    } catch (e) {
      // Fallback: usar unfocus para fechar teclado
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _scanController.removeListener(_onScannerInput);
    _scanFocusNode.removeListener(_onFocusChange);
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
            QuantitySelectorCard(
              controller: _quantityController,
              focusNode: _quantityFocusNode,
              enabled: widget.viewModel.isCartInSeparationStatus,
            ),

            const SizedBox(height: 6),

            // Card do scanner de código de barras
            BarcodeScannerCard(
              controller: _scanController,
              focusNode: _scanFocusNode,
              keyboardEnabled: _keyboardEnabled,
              onToggleKeyboard: _toggleKeyboard,
              onSubmitted: _onBarcodeScanned,
              enabled: widget.viewModel.isCartInSeparationStatus,
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
      final result = await widget.viewModel.addScannedItem(codProduto: item.codProduto, quantity: quantity);

      if (result.isSuccess) {
        await _handleSuccessfulItemAddition(item, quantity);
      } else {
        _handleFailedItemAddition(item, result.message, barcode);
      }
    } catch (e) {
      _handleFailedItemAddition(item, 'Erro inesperado: ${e.toString()}', barcode);
    }
  }

  /// Processa adição bem-sucedida de item
  Future<void> _handleSuccessfulItemAddition(SeparateItemConsultationModel item, int quantity) async {
    final itemId = item.item;
    final wasCompletedBefore = widget.viewModel.isItemCompleted(itemId);

    // Reproduzir feedback de sucesso
    _audioService.playBarcodeScan();
    _provideTactileFeedback();

    // Verificar se o item foi completado após a adição
    await Future.delayed(_stateUpdateDelay);
    final isCompletedNow = widget.viewModel.isItemCompleted(itemId);

    _logItemCompletionStatus(itemId.toString(), wasCompletedBefore, isCompletedNow, item, quantity);

    // Reproduzir som especial se item foi completado
    if (wasCompletedBefore && isCompletedNow) {
      _audioService.playItemCompleted();
    }

    // Resetar quantidade se necessário
    _resetQuantityIfNeeded();

    // Verificar se acabaram os itens do setor
    await _checkIfSectorItemsCompleted();
  }

  /// Processa falha na adição de item
  void _handleFailedItemAddition(SeparateItemConsultationModel item, String errorMessage, String barcode) {
    _audioService.playError();
    _showErrorDialog(item, errorMessage, barcode);
  }

  /// Log do status de completude do item (apenas em debug)
  void _logItemCompletionStatus(
    String itemId,
    bool wasCompletedBefore,
    bool isCompletedNow,
    SeparateItemConsultationModel item,
    int quantity,
  ) {
    if (kDebugMode) {
      final currentPickedQuantity = widget.viewModel.getPickedQuantity(itemId);
      final totalQuantity = item.quantidade.toInt();
      final newPickedQuantity = currentPickedQuantity + quantity;

      print('Item $itemId - Antes: $wasCompletedBefore, Depois: $isCompletedNow');
      print('Quantidades - Atual: $currentPickedQuantity, Nova: $newPickedQuantity, Total: $totalQuantity');
    }
  }

  /// Resetar quantidade para 1 se estiver maior
  void _resetQuantityIfNeeded() {
    if (_quantityController.text.isNotEmpty && int.tryParse(_quantityController.text) != null) {
      final currentQuantity = int.parse(_quantityController.text);
      if (currentQuantity > 1) {
        _quantityController.text = '1';
      }
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

  /// Mostra diálogo de erro genérico
  void _showErrorDialog(SeparateItemConsultationModel item, String errorMessage, String barcode) {
    _showDialogWithFocusReturn(
      () => PickingDialogs.addItemError(barcode: barcode, productName: item.nomeProduto, errorMessage: errorMessage),
    );
  }

  /// Mostra diálogo de produto errado
  void _showWrongProductDialog(String barcode, SeparateItemConsultationModel expectedItem) {
    _showDialogWithFocusReturn(
      () => PickingDialogs.wrongProduct(
        scannedBarcode: barcode,
        expectedAddress: expectedItem.enderecoDescricao ?? 'Endereço não definido',
        expectedProduct: expectedItem.nomeProduto,
        expectedBarcode: expectedItem.codigoBarras,
      ),
    );
  }

  /// Mostra diálogo de setor errado
  void _showWrongSectorDialog(String barcode, SeparateItemConsultationModel scannedItem, int userSectorCode) {
    _showDialogWithFocusReturn(
      () => PickingDialogs.wrongSector(
        scannedBarcode: barcode,
        productName: scannedItem.nomeProduto,
        productSector: scannedItem.nomeSetorEstoque ?? 'Setor ${scannedItem.codSetorEstoque}',
        userSectorCode: userSectorCode,
      ),
    );
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

  /// Mostra diálogo de separação completa
  void _showAllItemsCompletedDialog() {
    _showDialogWithFocusReturn(() => PickingDialogs.separationComplete());
  }

  /// Mostra diálogo e retorna foco para o scanner após fechar
  void _showDialogWithFocusReturn(Widget Function() dialogBuilder) {
    showDialog(context: context, builder: (context) => dialogBuilder()).then((_) {
      _returnFocusToScanner();
    });
  }

  /// Retorna foco para o campo de scanner
  void _returnFocusToScanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scanFocusNode.requestFocus();
      }
    });
  }

  /// Finaliza o picking e volta para a tela anterior
  Future<void> _finishPicking() async {
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
