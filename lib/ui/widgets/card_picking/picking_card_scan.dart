import 'dart:async' show Timer;

import 'package:flutter/material.dart';

import 'package:exp/core/services/audio_service.dart';
import 'package:exp/di/locator.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/ui/widgets/card_picking/components/index.dart';

/// Tela de escaneamento de itens do carrinho durante a separação
///
/// Gerencia o processo de picking (separação) de itens, permitindo
/// escanear códigos de barras e adicionar itens ao carrinho.
class PickingCardScan extends StatefulWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final CardPickingViewModel viewModel;

  const PickingCardScan({super.key, required this.cart, required this.viewModel});

  @override
  State<PickingCardScan> createState() => _PickingCardScanState();
}

class _PickingCardScanState extends State<PickingCardScan> with AutomaticKeepAliveClientMixin {
  // Controllers de texto
  final _scanController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  // Focus nodes
  final _scanFocusNode = FocusNode();
  final _quantityFocusNode = FocusNode();

  // Estado da UI
  Timer? _scanTimer;
  bool _keyboardEnabled = false;
  bool _isProcessingScan = false;

  // Componentes especializados (arquitetura modular)
  late final KeyboardToggleController _keyboardController;
  late final ScanInputProcessor _scanProcessor;
  late final CartStatusCache _statusCache;
  late final PickingDialogManager _dialogManager;

  // Serviços
  final AudioService _audioService = locator<AudioService>();

  /// Mantém o estado vivo para otimização de performance
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _setupListeners();
    _requestInitialFocus();
  }

  /// Inicializa os componentes refatorados
  void _initializeComponents() {
    _keyboardController = KeyboardToggleController(scanFocusNode: _scanFocusNode, context: context);

    _scanProcessor = ScanInputProcessor(viewModel: widget.viewModel);

    _statusCache = CartStatusCache(viewModel: widget.viewModel);

    _dialogManager = PickingDialogManager(context: context, scanFocusNode: _scanFocusNode);
  }

  /// Configura os listeners necessários
  void _setupListeners() {
    _scanController.addListener(_onScannerInput);
    _scanFocusNode.addListener(_onFocusChange);
  }

  /// Solicita foco inicial no campo de scanner
  void _requestInitialFocus() {
    _keyboardController.requestInitialFocus();
  }

  /// Obtém o status do carrinho com cache para otimização
  bool _isCartInSeparationStatus() {
    return _statusCache.isCartInSeparationStatus();
  }

  /// Invalida o cache do status do carrinho
  void _invalidateCartStatusCache() {
    _statusCache.invalidateCache();
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

    _scanProcessor.processScannerInput(text, _handleCompleteBarcode, _waitForMoreInput);
  }

  /// Processa código de barras completo detectado pelo scanner
  void _handleCompleteBarcode(String barcode) {
    _clearScannerFieldAfterDelay();
    _onBarcodeScanned(barcode);
  }

  /// Aguarda mais entrada do scanner com timeout
  void _waitForMoreInput() {
    const scannerTimeout = Duration(milliseconds: 300);
    _scanTimer = Timer(scannerTimeout, () {
      if (_scanController.text.isNotEmpty) {
        final barcode = _scanController.text.trim();
        _clearScannerFieldAfterDelay();
        _onBarcodeScanned(barcode);
      }
    });
  }

  /// Limpa o campo do scanner após um delay para o usuário visualizar
  void _clearScannerFieldAfterDelay() {
    const displayDelay = Duration(milliseconds: 500);
    Future.delayed(displayDelay, () {
      if (mounted) {
        _scanController.clear();
      }
    });
  }

  /// Listener para mudanças de foco do campo de scanner
  void _onFocusChange() {
    if (_scanFocusNode.hasFocus) {
      // Campo ganhou foco no modo manual - teclado deveria aparecer automaticamente
      // Não forçar aqui para evitar conflitos com o toggle
    }
  }

  /// Alterna entre modo scanner e teclado
  void _toggleKeyboard() {
    // Evitar setState se o estado não mudou
    if (_keyboardEnabled == !_keyboardEnabled) return;

    setState(() {
      _keyboardEnabled = !_keyboardEnabled;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_keyboardEnabled) {
          _keyboardController.enableKeyboardMode();
        } else {
          _keyboardController.enableScannerMode();
        }
      }
    });
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

    // Limpar cache
    _statusCache.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin

    final isEnabled = _isCartInSeparationStatus();

    return PickingScreenLayout(
      cart: widget.cart,
      viewModel: widget.viewModel,
      quantityController: _quantityController,
      quantityFocusNode: _quantityFocusNode,
      scanController: _scanController,
      scanFocusNode: _scanFocusNode,
      keyboardEnabled: _keyboardEnabled,
      onToggleKeyboard: _toggleKeyboard,
      onBarcodeScanned: _onBarcodeScanned,
      isEnabled: isEnabled,
    );
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    if (barcode.trim().isEmpty) return;

    // Evitar múltiplos processamentos simultâneos
    if (_isProcessingScan) return;
    _isProcessingScan = true;

    try {
      // Verificação rápida de status antes da validação pesada
      if (!_isCartInSeparationStatus()) {
        _audioService.playError();
        return;
      }

      // Obter a quantidade informada
      final quantity = int.tryParse(_quantityController.text) ?? 1;

      // Validar código de barras usando o processador
      final validationResult = _scanProcessor.validateScannedBarcode(barcode);

      if (validationResult.isEmpty) {
        return;
      }

      if (validationResult.noItemsForSector) {
        // Reproduzir som de alerta para não haver mais itens do setor
        _audioService.playAlert();
        _dialogManager.showNoItemsForSectorDialog(validationResult.userSectorCode!, _finishPicking);
        return;
      }

      if (validationResult.allItemsCompleted) {
        // Reproduzir som de alerta para todos os itens completos
        _audioService.playAlert();
        _dialogManager.showAllItemsCompletedDialog();
        return;
      }

      if (validationResult.isWrongSector) {
        // Reproduzir som de erro para produto de outro setor
        _audioService.playError();
        _dialogManager.showWrongSectorDialog(
          barcode,
          validationResult.scannedItem!.nomeProduto,
          validationResult.scannedItem!.nomeSetorEstoque ?? 'Setor ${validationResult.scannedItem!.codSetorEstoque}',
          validationResult.userSectorCode!,
        );
        return;
      }

      if (validationResult.isValid && validationResult.expectedItem != null) {
        await _addItemToSeparation(validationResult.expectedItem!, barcode, quantity);
      } else {
        // Reproduzir som de erro para produto errado
        _audioService.playError();
        _dialogManager.showWrongProductDialog(
          barcode,
          validationResult.expectedItem!.enderecoDescricao ?? 'Endereço não definido',
          validationResult.expectedItem!.nomeProduto,
          validationResult.expectedItem!.codigoBarras ?? 'Código não definido',
        );
      }
    } finally {
      _isProcessingScan = false;
    }
  }

  /// Adiciona item escaneado na separação via use case
  Future<void> _addItemToSeparation(SeparateItemConsultationModel item, String barcode, int quantity) async {
    try {
      final result = await widget.viewModel.addScannedItem(codProduto: item.codProduto, quantity: quantity);

      if (result.isSuccess) {
        await _scanProcessor.handleSuccessfulItemAddition(
          item,
          quantity,
          _resetQuantityIfNeeded,
          _invalidateCartStatusCache,
          _checkIfSectorItemsCompleted,
        );
      } else {
        _scanProcessor.handleFailedItemAddition(item, result.message);
        _dialogManager.showErrorDialog(barcode, item.nomeProduto, result.message);
      }
    } catch (e) {
      _scanProcessor.handleFailedItemAddition(item, 'Erro inesperado: ${e.toString()}');
      _dialogManager.showErrorDialog(barcode, item.nomeProduto, 'Erro inesperado: ${e.toString()}');
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
      _dialogManager.showSaveCartAfterSectorCompletedDialog(
        userSectorCode,
        _finishPicking,
        _keyboardController.returnFocusToScanner,
      );
    }
  }

  /// Finaliza o picking e volta para a tela anterior
  Future<void> _finishPicking() async {
    if (mounted) {
      Navigator.of(context).pop(true); // Pop com resultado true indicando finalização
    }
  }
}
