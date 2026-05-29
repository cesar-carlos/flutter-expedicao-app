import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';

import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/index.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/scan_ui_controller.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class PickingCardScan extends StatefulWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final CardPickingViewModel viewModel;

  const PickingCardScan({super.key, required this.cart, required this.viewModel});

  @override
  State<PickingCardScan> createState() => _PickingCardScanState();
}

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
  static const String _defaultQuantity = '1';

  final _scanController = TextEditingController();

  final _quantityController = TextEditingController(text: _defaultQuantity);

  final _scanFocusNode = FocusNode();
  final _quantityFocusNode = FocusNode();

  late final PickingScanState _scanState;

  late final KeyboardToggleController _keyboardController;
  late final ScanInputProcessor _scanProcessor;
  late final CartStatusCache _statusCache;
  late final PickingDialogManager _dialogManager;
  late final ScanUiController _scanUiController;
  late final PickingFlowController _flowController;
  late final ScannerPreferencesController _scannerPreferencesController;
  late final ScannerBroadcastController _scannerBroadcastController;
  late final ScannerActivationController _scannerActivationController;

  final AudioService _audioService = locator<AudioService>();

  StreamSubscription<OperationError>? _errorSubscription;

  Timer? _shelfScanTimer;
  Timer? _reactivationTimer;

  bool _hasShownInitialShelfScan = false;

  /// Item 3: garante que a ativação inicial via didChangeDependencies
  /// aconteça uma única vez, evitando reativações redundantes.
  bool _scannerInitialized = false;

  /// Item 2/6: último valor conhecido de isCartInSeparationStatus, para
  /// reagir apenas quando a situação do carrinho muda (e não a cada build).
  bool? _lastCartInSeparationStatus;

  /// Item 5: enquanto o carrinho está sendo salvo/finalizado, scans
  /// concorrentes (foco e broadcast) são ignorados.
  bool _isSavingCart = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _setupListeners();
    _requestInitialFocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scannerPreferencesController.loadPreferences();

        unawaited(
          Future<void>.delayed(UIConstants.scannerInitDelay, () {
            if (mounted) {
              _scannerActivationController.activate(
                scanState: _scanState,
                keyboardController: _keyboardController,
                scanFocusNode: _scanFocusNode,
                scanController: _scanController,
                onBarcodeScanned: _onBarcodeScanned,
                mounted: () => mounted,
              );
            }
          }).catchError((Object e, StackTrace s) {
            AppLogger.warning(
              'Falha na ativação inicial do scanner (card picking)',
              tag: 'PickingCardScan',
              error: e,
              stackTrace: s,
            );
          }),
        );
        _statusCache.forceCheckCartStatus();
        if (mounted) {
          _scanState.forceUpdate();
        }
      }
    });

    _errorSubscription = widget.viewModel.operationErrors.listen(_handleOperationError);

    widget.viewModel.addListener(_onViewModelChanged);

    unawaited(
      Future<void>.delayed(UIConstants.longDelay, () {
        if (mounted && !_hasShownInitialShelfScan) {
          if (widget.viewModel.items.isNotEmpty && !widget.viewModel.isLoading) {
            _checkInitialShelfScan();
          }
        }
      }).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha no delayed de scan inicial de prateleira',
          tag: 'PickingCardScan',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _initializeComponents() {
    _scanState = PickingScanState();
    _keyboardController = KeyboardToggleController(scanFocusNode: _scanFocusNode, context: context);
    _scanProcessor = ScanInputProcessor(viewModel: widget.viewModel);
    _statusCache = CartStatusCache(viewModel: widget.viewModel);
    _dialogManager = PickingDialogManager(context: context, scanFocusNode: _scanFocusNode);
    _scannerPreferencesController = ScannerPreferencesController();
    _scannerBroadcastController = ScannerBroadcastController();
    _scannerActivationController = ScannerActivationController(
      preferencesController: _scannerPreferencesController,
      broadcastController: _scannerBroadcastController,
    );
    _scanUiController = ScanUiController(
      dialogManager: _dialogManager,
      audioService: _audioService,
      keyboardController: _keyboardController,
      quantityController: _quantityController,
      onFinishPicking: _finishPicking,
      onAddItem: _addItemToSeparation,
      context: context,
    );
    _flowController = PickingFlowController(
      viewModel: widget.viewModel,
      dialogManager: _dialogManager,
      audioService: _audioService,
      keyboardController: _keyboardController,
    );
  }

  void _setupListeners() {
    _scanController.addListener(_onScannerInput);
  }

  void _requestInitialFocus() {
    _keyboardController.requestInitialFocus();
  }

  bool get _isBroadcastMode => _scannerPreferencesController.isBroadcastConfigured;

  bool _isCartInSeparationStatus() {
    return _statusCache.isCartInSeparationStatus();
  }

  void _invalidateCartStatusCache() {
    _statusCache.invalidateCache();
  }

  Future<void> _pauseScannerForShelf() async {
    await _scannerActivationController.pause(
      scanState: _scanState,
      scanFocusNode: _scanFocusNode,
      mounted: () => mounted,
    );
  }

  void _reactivateScanner() {
    _scannerActivationController.reactivate(
      scanState: _scanState,
      keyboardController: _keyboardController,
      scanFocusNode: _scanFocusNode,
      scanController: _scanController,
      onBarcodeScanned: _onBarcodeScanned,
      mounted: () => mounted,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Item 3: a ativação inicial deve ocorrer uma única vez. Chamadas
    // subsequentes de didChangeDependencies (mudança de tema/MediaQuery/
    // provider) não devem reagendar ativação/foco do scanner.
    if (_scannerInitialized) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _statusCache.forceCheckCartStatus();

      if (widget.viewModel.items.isNotEmpty && !widget.viewModel.isLoading) {
        _scannerInitialized = true;
        unawaited(
          Future<void>.delayed(UIConstants.scannerActivationDelay, () {
            if (mounted) {
              if (!_scannerActivationController.isInitialized) {
                _scannerActivationController.activate(
                  scanState: _scanState,
                  keyboardController: _keyboardController,
                  scanFocusNode: _scanFocusNode,
                  scanController: _scanController,
                  onBarcodeScanned: _onBarcodeScanned,
                  mounted: () => mounted,
                );
              }
              _scanState.setEnabled(_isCartInSeparationStatus());
              _scanFocusNode.requestFocus();
            }
          }).catchError((Object e, StackTrace s) {
            AppLogger.warning(
              'Falha na reativação do scanner (didChangeDependencies)',
              tag: 'PickingCardScan',
              error: e,
              stackTrace: s,
            );
          }),
        );
      } else {
        // Itens ainda não carregados: apenas garante foco. A flag permanece
        // false para que a ativação efetiva ocorra quando os itens chegarem.
        _scanFocusNode.requestFocus();
      }
    });
  }

  void _onScannerInput() {
    if (_isBroadcastMode) return;
    if (_scanState.keyboardEnabled || _scanController.text.isEmpty) return;

    _processScannerInput();
  }

  void _processScannerInput() {
    final text = _scanController.text.trim();
    AppLogger.debug('Processing scanner input: $text', tag: 'PickingCardScan');
    _scanProcessor.processScannerInput(text, _handleCompleteBarcode, _waitForMoreInput);
  }

  void _handleCompleteBarcode(String barcode) {
    AppLogger.debug('Complete barcode scanned: $barcode', tag: 'PickingCardScan');
    _clearScannerFieldAfterDelay();
    _onBarcodeScanned(barcode);
  }

  void _waitForMoreInput() {
    if (!mounted || _scanController.text.isEmpty) return;

    final barcode = _scanController.text.trim();
    AppLogger.debug('Timeout/partial barcode: $barcode', tag: 'PickingCardScan');
    _clearScannerFieldAfterDelay();
    _onBarcodeScanned(barcode);
  }

  void _clearScannerFieldAfterDelay() {
    unawaited(
      Future<void>.delayed(UIConstants.scannerDisplayDelay, () {
        if (mounted) {
          _scanController.clear();
        }
      }).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao limpar campo do scanner após delay',
          tag: 'PickingCardScan',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _toggleKeyboard() {
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

  void _handleOperationError(OperationError error) {
    if (!mounted) return;

    _audioService.playError();

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
    _shelfScanTimer?.cancel();
    _reactivationTimer?.cancel();
    _scannerActivationController.dispose();
    _errorSubscription?.cancel();
    widget.viewModel.removeListener(_onViewModelChanged);
    _scanController.removeListener(_onScannerInput);
    _scanController.dispose();
    _scanFocusNode.dispose();
    _quantityController.dispose();
    _quantityFocusNode.dispose();

    _statusCache.clear();
    _scanProcessor.dispose();
    _scanState.dispose();

    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    // Item 2 + Item 6: reage à mudança de situação do carrinho apenas quando
    // o valor realmente muda. Ao mudar, invalida o cache local de status
    // (TTL curto, que poderia estar defasado após evento de socket) e reflete
    // o novo estado no scanner — sem agendar callback a cada build.
    final isCartInSeparation = widget.viewModel.isCartInSeparationStatus;
    if (_lastCartInSeparationStatus != isCartInSeparation) {
      _lastCartInSeparationStatus = isCartInSeparation;
      _invalidateCartStatusCache();
      if (!_isSavingCart) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isSavingCart) {
            _scanState.setEnabled(isCartInSeparation);
          }
        });
      }
    }

    _shelfScanTimer?.cancel();
    _reactivationTimer?.cancel();

    if (widget.viewModel.items.isNotEmpty && !widget.viewModel.isLoading) {
      _shelfScanTimer = Timer(UIConstants.shortLoadingDelay, () {
        if (mounted) _checkInitialShelfScan();
      });

      _reactivationTimer = Timer(UIConstants.scannerReactivationDelay, () {
        if (!mounted) return;

        final isCartInSeparation = _isCartInSeparationStatus();

        if (!_scanState.enabled && isCartInSeparation) {
          if (!_scannerActivationController.isInitialized) {
            _scannerActivationController.activate(
              scanState: _scanState,
              keyboardController: _keyboardController,
              scanFocusNode: _scanFocusNode,
              scanController: _scanController,
              onBarcodeScanned: _onBarcodeScanned,
              mounted: () => mounted,
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _scanState.setEnabled(true);
              _scanFocusNode.requestFocus();
            }
          });
        } else if (isCartInSeparation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scanFocusNode.requestFocus();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Item 2: o gating do scanner (setEnabled) NÃO é mais agendado a cada
    // build. A reação à mudança de isCartInSeparationStatus é feita em
    // _onViewModelChanged (listener do ViewModel), evitando enfileirar um
    // postFrameCallback por rebuild. O build agora apenas monta a árvore.
    return RepaintBoundary(
      child: _PickingCardScanProvider(
        scanState: _scanState,
        cart: widget.cart,
        viewModel: widget.viewModel,
        quantityController: _quantityController,
        quantityFocusNode: _quantityFocusNode,
        scanController: _scanController,
        scanFocusNode: _scanFocusNode,
        onToggleKeyboard: _toggleKeyboard,
        onBarcodeScanned: _onBarcodeScanned,
      ),
    );
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    AppLogger.debug(
      'Barcode scanned: mode=${_scannerPreferencesController.mode} code="$barcode"',
      tag: 'PickingCardScan',
    );
    if (barcode.trim().isEmpty) return;

    // Item 5: ignora scans enquanto o carrinho está sendo salvo/finalizado,
    // impedindo leituras concorrentes durante a operação de save.
    if (_isSavingCart) {
      AppLogger.debug('Scan ignorado: salvamento de carrinho em andamento', tag: 'PickingCardScan');
      return;
    }

    // B2: aquisicao atomica do lock de processamento.
    // Em modo broadcast, multiplos Intents podem chegar antes do startProcessing,
    // causando dupla adicao no carrinho. tryStartProcessing garante que apenas
    // o primeiro scan concorrente avance.
    if (!_scanState.tryStartProcessing()) {
      AppLogger.debug('Scan ignored: another scan in progress', tag: 'PickingCardScan');
      return;
    }

    try {
      final nextItem = widget.viewModel.nextItem;

      if (nextItem != null && widget.viewModel.shouldScanShelf(nextItem)) {
        // Libera o lock antes de pausar para shelf, pois o fluxo dali
        // entra em outro caminho assincrono.
        _scanState.stopProcessing();
        await _pauseScannerForShelf();
        if (!mounted) return;
        _flowController.showShelfScanDialog(context, nextItem, onShelfScanCompleted: _reactivateScanner);
        return;
      }

      _scanController.clear();

      final inputQuantity = int.tryParse(_quantityController.text) ?? 1;

      final scanResult = widget.viewModel.processScan(
        barcode: barcode,
        inputQuantity: inputQuantity,
        isCartInSeparation: _isCartInSeparationStatus(),
      );

      await _scanUiController.handleScanResult(barcode, scanResult, inputQuantity);
    } finally {
      _scanState.stopProcessing();
    }
  }

  Future<bool> _addItemToSeparation(
    SeparateItemConsultationModel item,
    String barcode,
    int quantity,
    int originalQuantity,
  ) async {
    try {
      final result = await widget.viewModel.addScannedItem(itemId: item.item, quantity: quantity);

      if (result.isSuccess) {
        if (item.endereco != null) {
          widget.viewModel.updateScannedAddress(item.endereco!);
        }

        await _scanProcessor.handleSuccessfulItemAddition(
          item,
          quantity,
          _resetQuantityIfNeeded,
          _invalidateCartStatusCache,
          () async {},
        );

        unawaited(
          _checkNextItemShelfScanAsync()
              .then((_) async {
                if (!mounted) return;
                await Future.delayed(UIConstants.mediumDelay);
                if (mounted) await _checkAndShowSaveCartModal();
              })
              .catchError((Object e, StackTrace s) {
                AppLogger.warning(
                  'Falha na sequência pós-adicionar item (prateleira/salvar)',
                  tag: 'PickingCardScan',
                  error: e,
                  stackTrace: s,
                );
              }),
        );

        _keyboardController.forceFocusAndCloseKeyboard();
        return true;
      } else {
        if (originalQuantity != quantity) {
          _quantityController.text = originalQuantity.toString();
        }
        _scanProcessor.handleFailedItemAddition(item, result.message);
        _dialogManager.showErrorDialog(barcode, item.nomeProduto, result.message);
        _keyboardController.forceFocusAndCloseKeyboard();
        return false;
      }
    } catch (e, stackTrace) {
      if (originalQuantity != quantity) {
        _quantityController.text = originalQuantity.toString();
      }
      AppLogger.error('Erro inesperado ao processar scan', tag: 'PickingCardScan', error: e, stackTrace: stackTrace);
      const message = 'Erro inesperado. Tente novamente.';
      _scanProcessor.handleFailedItemAddition(item, message);
      _dialogManager.showErrorDialog(barcode, item.nomeProduto, message);
      _keyboardController.forceFocusAndCloseKeyboard();
      return false;
    }
  }

  void _checkInitialShelfScan() {
    if (!mounted || _hasShownInitialShelfScan) return;

    final nextItem = widget.viewModel.shouldShowInitialShelfScan();
    if (nextItem != null) {
      _hasShownInitialShelfScan = true;

      unawaited(
        Future<void>.delayed(UIConstants.shortLoadingDelay, () {
          if (mounted) {
            unawaited(
              _pauseScannerForShelf()
                  .then((_) {
                    if (!mounted) return;
                    _flowController.showShelfScanDialog(context, nextItem, onShelfScanCompleted: _reactivateScanner);
                  })
                  .catchError((Object e, StackTrace s) {
                    AppLogger.warning(
                      'Falha ao abrir scan inicial de prateleira',
                      tag: 'PickingCardScan',
                      error: e,
                      stackTrace: s,
                    );
                  }),
            );
          }
        }).catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha no delayed antes do scan inicial de prateleira',
            tag: 'PickingCardScan',
            error: e,
            stackTrace: s,
          );
        }),
      );
    }
  }

  Future<void> _checkNextItemShelfScanAsync() async {
    await Future.delayed(UIConstants.shortLoadingDelay);
    if (!mounted) return;

    final nextItem = widget.viewModel.nextItem;

    if (nextItem != null && widget.viewModel.shouldScanShelf(nextItem)) {
      await _pauseScannerForShelf();
      if (!mounted) return;
      await _flowController.showShelfScanDialog(context, nextItem, onShelfScanCompleted: _reactivateScanner);
    }
  }

  void _resetQuantityIfNeeded() {
    if (_quantityController.text.isNotEmpty && int.tryParse(_quantityController.text) != null) {
      final currentQuantity = int.parse(_quantityController.text);
      if (currentQuantity > 1) {
        _quantityController.text = _defaultQuantity;
      }
    }
  }

  Future<void> _checkAndShowSaveCartModal() => _flowController.checkAndShowSaveCartModal();

  Future<void> _finishPicking() async {
    // Item 5: bloqueia scans concorrentes (foco e broadcast) durante o save.
    // Reabilita SEMPRE no finally, inclusive em caso de erro/cancelamento.
    _isSavingCart = true;
    _scanState.setEnabled(false);
    try {
      await _flowController.finishPicking();
    } finally {
      _isSavingCart = false;
      if (mounted) {
        _scanState.setEnabled(_isCartInSeparationStatus());
      }
    }
  }
}
