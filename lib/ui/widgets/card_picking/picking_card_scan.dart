import 'dart:async' show StreamSubscription;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/utils/picking_utils.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/index.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/scan_ui_controller.dart';

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
  static const Duration _displayDelay = Duration(milliseconds: 500);

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

  final AudioService _audioService = locator<AudioService>();

  StreamSubscription<OperationError>? _errorSubscription;

  bool _hasShownInitialShelfScan = false;

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
        _statusCache.forceCheckCartStatus();
        if (mounted) {
          _scanState.forceUpdate();
        }
      }
    });

    _errorSubscription = widget.viewModel.operationErrors.listen(_handleOperationError);

    widget.viewModel.addListener(_onViewModelChanged);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && !_hasShownInitialShelfScan) {
        if (widget.viewModel.items.isNotEmpty && !widget.viewModel.isLoading) {
          _checkInitialShelfScan();
        }
      }
    });
  }

  void _initializeComponents() {
    _scanState = PickingScanState();
    _keyboardController = KeyboardToggleController(scanFocusNode: _scanFocusNode, context: context);
    _scanProcessor = ScanInputProcessor(viewModel: widget.viewModel);
    _statusCache = CartStatusCache(viewModel: widget.viewModel);
    _dialogManager = PickingDialogManager(context: context, scanFocusNode: _scanFocusNode);
    _scanUiController = ScanUiController(
      dialogManager: _dialogManager,
      audioService: _audioService,
      keyboardController: _keyboardController,
      quantityController: _quantityController,
      onFinishPicking: _finishPicking,
      onAddItem: _addItemToSeparation,
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

  bool _isCartInSeparationStatus() {
    return _statusCache.isCartInSeparationStatus();
  }

  void _invalidateCartStatusCache() {
    _statusCache.invalidateCache();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _statusCache.forceCheckCartStatus();
        _scanFocusNode.requestFocus();
      }
    });
  }

  void _onScannerInput() {
    if (_scanState.keyboardEnabled || _scanController.text.isEmpty) return;

    _processScannerInput();
  }

  void _processScannerInput() {
    final text = _scanController.text.trim();
    _scanProcessor.processScannerInput(text, _handleCompleteBarcode, _waitForMoreInput);
  }

  void _handleCompleteBarcode(String barcode) {
    _clearScannerFieldAfterDelay();
    _onBarcodeScanned(barcode);
  }

  void _waitForMoreInput() {
    if (!mounted || _scanController.text.isEmpty) return;

    final barcode = _scanController.text.trim();
    _clearScannerFieldAfterDelay();
    _onBarcodeScanned(barcode);
  }

  void _clearScannerFieldAfterDelay() {
    Future.delayed(_displayDelay, () {
      if (mounted) {
        _scanController.clear();
      }
    });
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

    if (widget.viewModel.items.isNotEmpty && !widget.viewModel.isLoading) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _checkInitialShelfScan();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isEnabled = _isCartInSeparationStatus();

    _scanState.setEnabled(isEnabled);

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

    if (_scanState.isProcessingScan) return;

    final nextItem = PickingUtils.findNextItemToPick(
      widget.viewModel.items,
      widget.viewModel.isItemCompleted,
      userSectorCode: widget.viewModel.userModel?.codSetorEstoque,
    );

    if (nextItem != null && widget.viewModel.shouldScanShelf(nextItem)) {
      _flowController.showShelfScanDialog(context, nextItem, _scanFocusNode);
      return;
    }

    _scanState.startProcessing();
    _scanController.clear();

    try {
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

  Future<void> _addItemToSeparation(SeparateItemConsultationModel item, String barcode, int quantity) async {
    try {
      final result = await widget.viewModel.addScannedItem(codProduto: item.codProduto, quantity: quantity);

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

        _checkNextItemShelfScan();

        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted) {
            await _checkAndShowSaveCartModal();
          }
        });

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

  void _checkInitialShelfScan() {
    if (!mounted || _hasShownInitialShelfScan) return;

    final nextItem = widget.viewModel.shouldShowInitialShelfScan();
    if (nextItem != null) {
      _hasShownInitialShelfScan = true;

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _flowController.showShelfScanDialog(context, nextItem, _scanFocusNode);
        }
      });
    }
  }

  void _checkNextItemShelfScan() {
    if (!mounted) return;

    final nextItem = PickingUtils.findNextItemToPick(
      widget.viewModel.items,
      widget.viewModel.isItemCompleted,
      userSectorCode: widget.viewModel.userModel?.codSetorEstoque,
    );

    if (nextItem != null && widget.viewModel.shouldScanShelf(nextItem)) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _flowController.showShelfScanDialog(context, nextItem, _scanFocusNode);
        }
      });
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

  Future<void> _finishPicking() => _flowController.finishPicking();
}
