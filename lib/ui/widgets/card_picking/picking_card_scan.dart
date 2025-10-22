import 'dart:async' show StreamSubscription;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/utils/picking_utils.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/index.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';

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

/// Widget intermediário que fornece o Provider mas não reconstrói
///
/// Este widget é necessário para separar a lógica do Provider da lógica
/// de estado do PickingCardScan, evitando rebuilds desnecessários.
class _PickingCardScanProvider extends StatelessWidget {
  final PickingScanState scanState;
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final CardPickingViewModel viewModel;
  final TextEditingController quantityController;
  final FocusNode quantityFocusNode;
  final TextEditingController scanController;
  final FocusNode scanFocusNode;
  final VoidCallback onToggleKeyboard;
  final void Function(String) onBarcodeScanned;

  const _PickingCardScanProvider({
    required this.scanState,
    required this.cart,
    required this.viewModel,
    required this.quantityController,
    required this.quantityFocusNode,
    required this.scanController,
    required this.scanFocusNode,
    required this.onToggleKeyboard,
    required this.onBarcodeScanned,
  });

  @override
  Widget build(BuildContext context) {
    // 🚀 Provider fornece estado SEM forçar rebuild deste widget
    return ChangeNotifierProvider<PickingScanState>.value(
      value: scanState,
      child: PickingScreenLayout(
        cart: cart,
        viewModel: viewModel,
        quantityController: quantityController,
        quantityFocusNode: quantityFocusNode,
        scanController: scanController,
        scanFocusNode: scanFocusNode,
        onToggleKeyboard: onToggleKeyboard,
        onBarcodeScanned: onBarcodeScanned,
      ),
    );
  }
}

class _PickingCardScanState extends State<PickingCardScan> with AutomaticKeepAliveClientMixin {
  // === CONSTANTES ===

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

  /// Estado gerenciado via Provider para evitar problemas de setState após dispose
  late final PickingScanState _scanState;

  // Componentes especializados (arquitetura modular)
  late final KeyboardToggleController _keyboardController;
  late final ScanInputProcessor _scanProcessor;
  late final CartStatusCache _statusCache;
  late final PickingDialogManager _dialogManager;

  // Serviços
  final AudioService _audioService = locator<AudioService>();

  // Subscription para erros de operação
  StreamSubscription<OperationError>? _errorSubscription;

  // Controle para evitar modal duplicado
  bool _hasShownInitialShelfScan = false;

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
          _scanState.forceUpdate(); // Usar Provider em vez de setState
        }
      }
    });

    // Escutar erros de operações assíncronas
    _errorSubscription = widget.viewModel.operationErrors.listen(_handleOperationError);

    // 🆕 Escutar mudanças no ViewModel para detectar quando os itens são carregados
    widget.viewModel.addListener(_onViewModelChanged);

    // 🆕 Verificação adicional após um delay maior para casos onde o listener não é chamado
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && !_hasShownInitialShelfScan) {
        if (widget.viewModel.items.isNotEmpty && !widget.viewModel.isLoading) {
          _checkInitialShelfScan();
        }
      }
    });
  }

  /// Inicializa os componentes refatorados
  void _initializeComponents() {
    // Inicializar estado gerenciado via Provider
    _scanState = PickingScanState();
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
    if (_scanState.keyboardEnabled || _scanController.text.isEmpty) return;

    _processScannerInput();
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

  /// Aguarda mais entrada do scanner
  ///
  /// Este método é chamado quando o debounce detecta que o usuário parou de digitar.
  /// Processa o código atual se houver conteúdo.
  void _waitForMoreInput() {
    if (!mounted || _scanController.text.isEmpty) return;

    final barcode = _scanController.text.trim();
    _clearScannerFieldAfterDelay();
    _onBarcodeScanned(barcode);
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
    // Usar Provider para gerenciar estado
    _scanState.toggleKeyboard();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_scanState.keyboardEnabled) {
          _keyboardController.enableKeyboardMode();
        } else {
          _keyboardController.enableScannerMode();
        }
      }
    });
  }

  /// Trata erros de operação assíncrona
  void _handleOperationError(OperationError error) {
    if (!mounted) return;

    // Tocar som de erro
    _audioService.playError();

    // Buscar item para mostrar diálogo
    final item = widget.viewModel.items.cast<SeparateItemConsultationModel?>().firstWhere(
      (i) => i?.item == error.itemId,
      orElse: () => null,
    );

    if (item != null) {
      _dialogManager.showErrorDialog(
        item.codigoBarras ?? '',
        item.nomeProduto,
        'Erro ao sincronizar: ${error.message}',
      );
    }
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    widget.viewModel.removeListener(_onViewModelChanged); // 🆕 Remover listener
    _scanController.removeListener(_onScannerInput);
    _scanFocusNode.removeListener(_onFocusChange);
    _scanController.dispose();
    _scanFocusNode.dispose();
    _quantityController.dispose();
    _quantityFocusNode.dispose();

    // Limpar cache e estado
    _statusCache.clear();
    _scanProcessor.dispose();
    _scanState.dispose();

    super.dispose();
  }

  /// Listener para mudanças no ViewModel
  void _onViewModelChanged() {
    if (!mounted) return;

    // Verificar se os itens foram carregados e se deve mostrar modal de prateleira
    if (widget.viewModel.items.isNotEmpty && !widget.viewModel.isLoading) {
      // Aguardar um pouco para garantir que a UI esteja atualizada
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _checkInitialShelfScan();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin

    final isEnabled = _isCartInSeparationStatus();
    // Atualiza o estado habilitado do Provider sem rebuild do widget pai
    _scanState.setEnabled(isEnabled);

    // 🚀 Widget intermediário que NÃO reconstrói quando o Provider notifica
    // O Provider está dentro do _PickingCardScanProvider, isolado desta classe
    return _PickingCardScanProvider(
      scanState: _scanState,
      cart: widget.cart,
      viewModel: widget.viewModel,
      quantityController: _quantityController,
      quantityFocusNode: _quantityFocusNode,
      scanController: _scanController,
      scanFocusNode: _scanFocusNode,
      onToggleKeyboard: _toggleKeyboard,
      onBarcodeScanned: _onBarcodeScanned,
    );
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    if (barcode.trim().isEmpty) return;

    // Evitar múltiplos processamentos simultâneos
    if (_scanState.isProcessingScan) return;

    // 🆕 VERIFICAR SE PRECISA ESCANEAR PRATELEIRA
    final nextItem = PickingUtils.findNextItemToPick(
      widget.viewModel.items,
      widget.viewModel.isItemCompleted,
      userSectorCode: widget.viewModel.userModel?.codSetorEstoque,
    );

    if (nextItem != null && widget.viewModel.shouldScanShelf(nextItem)) {
      _showShelfScanDialog(nextItem);
      return;
    }

    // Bloquear campo e limpar para próximo scan
    _scanState.startProcessing();
    _scanController.clear();

    try {
      // Verificação rápida de status antes da validação pesada
      if (!_isCartInSeparationStatus()) {
        _audioService.playError();
        return;
      }

      // Obter a quantidade informada
      final inputQuantity = int.tryParse(_quantityController.text) ?? 1;

      // Validar código de barras usando o processador
      final validationResult = _scanProcessor.validateScannedBarcode(barcode);

      if (validationResult.isEmpty) return;

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
        // Converter quantidade usando o código de barras escaneado
        final convertedQuantity = _convertQuantityWithBarcode(validationResult.expectedItem!, barcode, inputQuantity);

        // Se houve conversão, atualizar o campo de quantidade visualmente
        if (convertedQuantity != inputQuantity) {
          _quantityController.text = convertedQuantity.toString();
        }

        await _addItemToSeparation(validationResult.expectedItem!, barcode, convertedQuantity);
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
      _scanState.stopProcessing();
    }
  }

  /// Converte a quantidade usando o código de barras escaneado
  /// Utiliza o método converterQuantidadePorCodigoBarras do modelo para calcular
  /// a quantidade correta baseada na unidade de medida do código de barras
  int _convertQuantityWithBarcode(SeparateItemConsultationModel item, String barcode, int inputQuantity) {
    try {
      // Verifica se o item tem múltiplas unidades de medida
      if (item.unidadeMedidas.length <= 1) {
        // Se há apenas uma unidade, não há necessidade de conversão
        return inputQuantity;
      }

      // Converte a quantidade usando o método do modelo
      // O método converterQuantidadePorCodigoBarras já faz a busca internamente
      final convertedQuantity = item.converterQuantidadePorCodigoBarras(barcode, inputQuantity.toDouble());

      // Se a conversão foi bem-sucedida e o resultado é válido, retorna a quantidade convertida
      if (convertedQuantity != null && convertedQuantity > 0) {
        return convertedQuantity.round();
      }

      // Se não foi possível converter, retorna a quantidade original
      return inputQuantity;
    } catch (e) {
      // Em caso de erro, retorna a quantidade original
      return inputQuantity;
    }
  }

  /// Adiciona item escaneado na separação via use case
  Future<void> _addItemToSeparation(SeparateItemConsultationModel item, String barcode, int quantity) async {
    try {
      final result = await widget.viewModel.addScannedItem(codProduto: item.codProduto, quantity: quantity);

      if (result.isSuccess) {
        // Atualizar endereço escaneado ANTES de processar o sucesso
        if (item.endereco != null) {
          widget.viewModel.updateScannedAddress(item.endereco!);
        }

        await _scanProcessor.handleSuccessfulItemAddition(
          item,
          quantity,
          _resetQuantityIfNeeded,
          _invalidateCartStatusCache,
          _checkIfSectorItemsCompleted,
        );

        // Verificar se o próximo item precisa de escaneamento de prateleira
        _checkNextItemShelfScan();

        _keyboardController.returnFocusToScanner();
      } else {
        _scanProcessor.handleFailedItemAddition(item, result.message);
        _dialogManager.showErrorDialog(barcode, item.nomeProduto, result.message);
        _keyboardController.returnFocusToScanner();
      }
    } catch (e) {
      _scanProcessor.handleFailedItemAddition(item, 'Erro inesperado: ${e.toString()}');
      _dialogManager.showErrorDialog(barcode, item.nomeProduto, 'Erro inesperado: ${e.toString()}');
      _keyboardController.returnFocusToScanner();
    }
  }

  /// Verifica se deve mostrar o modal de escaneamento de prateleira na inicialização
  void _checkInitialShelfScan() {
    if (!mounted || _hasShownInitialShelfScan) return;

    final nextItem = widget.viewModel.shouldShowInitialShelfScan();
    if (nextItem != null) {
      _hasShownInitialShelfScan = true; // Marcar como já mostrado

      // Aguardar um pouco para garantir que a UI esteja totalmente carregada
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _showShelfScanDialog(nextItem);
        }
      });
    }
  }

  /// Verifica se o próximo item precisa de escaneamento de prateleira
  void _checkNextItemShelfScan() {
    if (!mounted) return;

    final nextItem = PickingUtils.findNextItemToPick(
      widget.viewModel.items,
      widget.viewModel.isItemCompleted,
      userSectorCode: widget.viewModel.userModel?.codSetorEstoque,
    );

    if (nextItem != null && widget.viewModel.shouldScanShelf(nextItem)) {
      // Aguardar um pouco para garantir que a UI esteja atualizada
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _showShelfScanDialog(nextItem);
        }
      });
    }
  }

  /// Mostra diálogo de escaneamento de prateleira
  void _showShelfScanDialog(SeparateItemConsultationModel nextItem) {
    _dialogManager.showShelfScanDialog(
      expectedAddress: nextItem.endereco!,
      expectedAddressDescription: nextItem.enderecoDescricao ?? 'Endereço não definido',
      onShelfScanned: (scannedAddress) {
        print('🔍 DEBUG: onShelfScanned chamado com endereço: $scannedAddress');
        // Atualizar endereço escaneado no ViewModel
        widget.viewModel.updateScannedAddress(scannedAddress);

        // Retornar foco para scanner
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scanFocusNode.requestFocus();
        });

        // Tocar som de sucesso
        _audioService.playShelfScanSuccess();
      },
      onBack: () {
        // Fechar modal e voltar para tela de separação
        Navigator.of(context).pop(); // Fecha o modal
        Navigator.of(context).pop(); // Volta para tela de separação
      },
    );
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
      print('🔍 DEBUG: _finishPicking chamado - fazendo Navigator.pop(true)');
      Navigator.of(context).pop(true); // Pop com resultado true indicando finalização
    }
  }
}
