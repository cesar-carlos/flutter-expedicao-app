import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/keyboard_toggle_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_scan_state.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/scanner_preferences_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/scanner_broadcast_controller.dart';

/// Controller responsável por coordenar a ativação do scanner
///
/// Responsabilidades:
/// - Coordenar ativação do scanner (focus ou broadcast)
/// - Gerenciar pausa/reactivação do scanner
/// - Integrar com KeyboardToggleController e PickingScanState
/// - Garantir que o scanner seja ativado corretamente após mudanças de estado
class ScannerActivationController {
  final ScannerPreferencesController _preferencesController;
  final ScannerBroadcastController _broadcastController;

  bool _isInitialized = false;
  bool _isPaused = false;

  /// Indica se o scanner foi inicializado
  bool get isInitialized => _isInitialized;

  /// Indica se o scanner está pausado
  bool get isPaused => _isPaused;

  ScannerActivationController({
    ScannerPreferencesController? preferencesController,
    ScannerBroadcastController? broadcastController,
  }) : _preferencesController = preferencesController ?? ScannerPreferencesController(),
       _broadcastController = broadcastController ?? ScannerBroadcastController();

  /// Ativa o scanner no modo apropriado (focus ou broadcast)
  ///
  /// [scanState] - Estado do scanner
  /// [keyboardController] - Controller para gerenciar teclado/scanner
  /// [scanFocusNode] - FocusNode do campo de scan
  /// [scanController] - TextEditingController do campo de scan
  /// [onBarcodeScanned] - Callback quando um código é escaneado
  /// [mounted] - Função para verificar se o widget está montado
  Future<void> activate({
    required PickingScanState scanState,
    required KeyboardToggleController keyboardController,
    required FocusNode scanFocusNode,
    required TextEditingController scanController,
    required void Function(String) onBarcodeScanned,
    required bool Function() mounted,
  }) async {
    if (_isInitialized) {
      AppLogger.debug('Scanner already initialized, skipping activation', tag: 'ScannerActivationController');
      return;
    }

    await _preferencesController.loadPreferences();
    final isBroadcastMode = _preferencesController.isBroadcastConfigured;

    if (isBroadcastMode) {
      await _activateBroadcastMode(onBarcodeScanned, mounted);
    } else {
      await _activateFocusMode(scanState, keyboardController, scanFocusNode, mounted);
    }

    _isInitialized = true;
  }

  /// Ativa o scanner em modo broadcast
  Future<void> _activateBroadcastMode(void Function(String) onBarcodeScanned, bool Function() mounted) async {
    AppLogger.debug('Activating scanner in broadcast mode', tag: 'ScannerActivationController');
    await _broadcastController.start(
      action: _preferencesController.broadcastAction,
      extraKey: _preferencesController.broadcastExtraKey,
      onBarcodeReceived: (code) {
        if (mounted()) {
          onBarcodeScanned(code);
        }
      },
    );
  }

  /// Ativa o scanner em modo focus
  Future<void> _activateFocusMode(
    PickingScanState scanState,
    KeyboardToggleController keyboardController,
    FocusNode scanFocusNode,
    bool Function() mounted,
  ) async {
    AppLogger.debug('Activating scanner in focus mode', tag: 'ScannerActivationController');
    scanState.setKeyboardEnabled(true);
    keyboardController.enableKeyboardMode();

    await Future.delayed(UIConstants.scannerInitDelay);
    if (!mounted()) return;

    scanState.setKeyboardEnabled(false);
    keyboardController.enableScannerMode();
  }

  /// Pausa o scanner (usado durante scan de prateleira, por exemplo)
  ///
  /// [scanState] - Estado do scanner
  /// [scanFocusNode] - FocusNode do campo de scan
  /// [mounted] - Função para verificar se o widget está montado
  Future<void> pause({
    required PickingScanState scanState,
    required FocusNode scanFocusNode,
    required bool Function() mounted,
  }) async {
    if (!mounted()) return;

    AppLogger.debug('Pausing scanner', tag: 'ScannerActivationController');
    _isPaused = true;
    scanState.setEnabled(false);

    if (_preferencesController.isBroadcastConfigured) {
      await _broadcastController.stop();
    }

    scanFocusNode.unfocus();
  }

  /// Reativa o scanner após uma pausa
  ///
  /// [scanState] - Estado do scanner
  /// [keyboardController] - Controller para gerenciar teclado/scanner
  /// [scanFocusNode] - FocusNode do campo de scan
  /// [scanController] - TextEditingController do campo de scan
  /// [onBarcodeScanned] - Callback quando um código é escaneado
  /// [mounted] - Função para verificar se o widget está montado
  Future<void> reactivate({
    required PickingScanState scanState,
    required KeyboardToggleController keyboardController,
    required FocusNode scanFocusNode,
    required TextEditingController scanController,
    required void Function(String) onBarcodeScanned,
    required bool Function() mounted,
  }) async {
    AppLogger.debug('Reactivating scanner', tag: 'ScannerActivationController');

    await Future.delayed(UIConstants.mediumDelay);
    if (!mounted()) {
      AppLogger.debug('Scanner reactivation cancelled - not mounted', tag: 'ScannerActivationController');
      return;
    }

    _preferencesController.reloadPreferences();
    _isInitialized = false;
    _isPaused = false;

    final isBroadcastMode = _preferencesController.isBroadcastConfigured;

    if (isBroadcastMode) {
      await _reactivateBroadcastMode(scanState, scanController, scanFocusNode, onBarcodeScanned, mounted);
    } else {
      await _reactivateFocusMode(scanState, keyboardController, scanController, scanFocusNode, mounted);
    }
  }

  /// Reativa o scanner em modo broadcast
  Future<void> _reactivateBroadcastMode(
    PickingScanState scanState,
    TextEditingController scanController,
    FocusNode scanFocusNode,
    void Function(String) onBarcodeScanned,
    bool Function() mounted,
  ) async {
    AppLogger.debug('Reactivating scanner in broadcast mode', tag: 'ScannerActivationController');

    await Future.delayed(UIConstants.scannerBroadcastRecreateDelay);
    if (!mounted()) {
      AppLogger.debug('Scanner reactivation cancelled - not mounted (broadcast)', tag: 'ScannerActivationController');
      return;
    }

    await _broadcastController.start(
      action: _preferencesController.broadcastAction,
      extraKey: _preferencesController.broadcastExtraKey,
      onBarcodeReceived: (code) {
        if (mounted()) {
          onBarcodeScanned(code);
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted()) return;
      scanState.setEnabled(true);
      scanState.stopProcessing();
      scanController.clear();
      scanFocusNode.requestFocus();
      AppLogger.debug('Broadcast listener recreated and ready', tag: 'ScannerActivationController');
    });
  }

  /// Reativa o scanner em modo focus
  Future<void> _reactivateFocusMode(
    PickingScanState scanState,
    KeyboardToggleController keyboardController,
    TextEditingController scanController,
    FocusNode scanFocusNode,
    bool Function() mounted,
  ) async {
    AppLogger.debug('Reactivating scanner in focus mode', tag: 'ScannerActivationController');

    await activate(
      scanState: scanState,
      keyboardController: keyboardController,
      scanFocusNode: scanFocusNode,
      scanController: scanController,
      onBarcodeScanned: (_) {},
      mounted: mounted,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted()) return;
      scanState.setKeyboardEnabled(false);
      scanState.setEnabled(true);
      keyboardController.enableScannerMode();
      scanState.stopProcessing();
      scanController.clear();
      scanFocusNode.requestFocus();
    });
  }

  /// Descarta o controller e limpa recursos
  void dispose() {
    _broadcastController.dispose();
    _isInitialized = false;
    _isPaused = false;
  }
}
