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
/// Responsabilidades:
/// - Gerenciar entrada de dados via scanner ou teclado manual
/// - Validar códigos de barras escaneados em tempo real
/// - Bloquear campo durante processamento para evitar scans duplicados
/// - Fornecer feedback visual e sonoro para o usuário
/// - Manter sincronização do status do carrinho via cache
///
/// Arquitetura:
/// - Componentes modulares (KeyboardToggleController, ScanInputProcessor, etc.)
/// - Estado gerenciado via ViewModel pattern
/// - Cache inteligente para otimização de performance
/// - Processamento assíncrono com bloqueio de UI
///
/// Performance:
/// - AutomaticKeepAliveClientMixin para preservar estado
/// - Cache de status do carrinho (200ms TTL)
/// - Validações paralelas
/// - Callbacks otimizados (delay de 10ms)
class PickingCardScan extends StatefulWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final CardPickingViewModel viewModel;

  const PickingCardScan({super.key, required this.cart, required this.viewModel});

  @override
  State<PickingCardScan> createState() => _PickingCardScanState();
}

class _PickingCardScanState extends State<PickingCardScan> with AutomaticKeepAliveClientMixin {
  // === CONSTANTES ===

  /// Timeout para aguardar mais entrada do scanner
  static const Duration _scannerTimeout = Duration(milliseconds: 300);

  /// Delay para limpar o campo após scan bem-sucedido
  static const Duration _displayDelay = Duration(milliseconds: 500);

  /// Quantidade padrão para adição de itens
  static const String _defaultQuantity = '1';

  // === CONTROLLERS ===

  /// Controller para o campo de entrada do scanner
  final _scanController = TextEditingController();

  /// Controller para o campo de quantidade com valor padrão
  final _quantityController = TextEditingController(text: _defaultQuantity);

  // === FOCUS NODES ===

  final _scanFocusNode = FocusNode();
  final _quantityFocusNode = FocusNode();

  // === ESTADO DA UI ===

  /// Timer para aguardar mais entrada do scanner
  Timer? _scanTimer;

  /// Indica se o modo teclado manual está ativo (vs modo scanner)
  bool _keyboardEnabled = false;

  /// Bloqueia o campo durante processamento para evitar scans duplicados
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

    // 🚀 Forçar verificação de status na inicialização para evitar tela bloqueada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _statusCache.forceCheckCartStatus();
        if (mounted) {
          setState(() {}); // Forçar rebuild com status atualizado
        }
      }
    });
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
        // 🚀 Verificar status novamente quando dependências mudarem
        _statusCache.forceCheckCartStatus();
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
  ///
  /// Agenda um timer para processar o código após o timeout,
  /// permitindo que o scanner complete a entrada de todos os dígitos.
  void _waitForMoreInput() {
    _scanTimer = Timer(_scannerTimeout, () {
      if (_scanController.text.isNotEmpty) {
        final barcode = _scanController.text.trim();
        _clearScannerFieldAfterDelay();
        _onBarcodeScanned(barcode);
      }
    });
  }

  /// Limpa o campo do scanner após um delay para o usuário visualizar
  ///
  /// O delay permite que o usuário veja o código escaneado antes
  /// de ser limpo automaticamente para o próximo scan.
  void _clearScannerFieldAfterDelay() {
    Future.delayed(_displayDelay, () {
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
      isProcessing: _isProcessingScan,
    );
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    if (barcode.trim().isEmpty) {
      return;
    }

    // Evitar múltiplos processamentos simultâneos
    if (_isProcessingScan) {
      return;
    }

    // 🔒 BLOQUEAR CAMPO E LIMPAR PARA PRÓXIMO SCAN
    setState(() {
      _isProcessingScan = true;
    });
    _scanController.clear();

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
        _audioService.playAlert();
        _dialogManager.showNoItemsForSectorDialog(validationResult.userSectorCode!, _finishPicking);
        return;
      }

      if (validationResult.allItemsCompleted) {
        _audioService.playAlert();
        _dialogManager.showAllItemsCompletedDialog();
        return;
      }

      if (validationResult.isWrongSector) {
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
        _audioService.playError();
        _dialogManager.showWrongProductDialog(
          barcode,
          validationResult.expectedItem!.enderecoDescricao ?? 'Endereço não definido',
          validationResult.expectedItem!.nomeProduto,
          validationResult.expectedItem!.codigoBarras ?? 'Código não definido',
        );
      }
    } finally {
      // 🔓 LIBERAR CAMPO APÓS PROCESSAR
      setState(() {
        _isProcessingScan = false;
      });
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

  /// Resetar quantidade para o valor padrão se estiver maior que 1
  ///
  /// Este método é chamado após cada adição bem-sucedida de item
  /// para resetar o campo de quantidade para o valor padrão.
  void _resetQuantityIfNeeded() {
    if (_quantityController.text.isNotEmpty && int.tryParse(_quantityController.text) != null) {
      final currentQuantity = int.parse(_quantityController.text);
      if (currentQuantity > 1) {
        _quantityController.text = _defaultQuantity;
      }
    }
  }

  /// Verifica se todos os itens do setor do usuário foram separados
  /// Se sim, oferece opção de salvar o carrinho imediatamente
  Future<void> _checkIfSectorItemsCompleted() async {
    final userSectorCode = widget.viewModel.userModel?.codSetorEstoque;

    // Se usuário não tem setor definido, não fazer nada
    if (userSectorCode == null) {
      return;
    }

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
