import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/keyboard_toggle_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_scan_state.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/scanner_preferences_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/scanner_broadcast_controller.dart';

class ScannerActivationController {
  final ScannerPreferencesController _preferencesController;
  final ScannerBroadcastController _broadcastController;

  bool _isInitialized = false;
  bool _isPaused = false;

  bool get isInitialized => _isInitialized;
  bool get isPaused => _isPaused;

  ScannerActivationController({
    ScannerPreferencesController? preferencesController,
    ScannerBroadcastController? broadcastController,
  }) : _preferencesController = preferencesController ?? ScannerPreferencesController(),
       _broadcastController = broadcastController ?? ScannerBroadcastController();

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

  Future<void> _activateFocusMode(
    PickingScanState scanState,
    KeyboardToggleController keyboardController,
    FocusNode scanFocusNode,
    bool Function() mounted,
  ) async {
    AppLogger.debug('Activating scanner in focus mode', tag: 'ScannerActivationController');
    scanState.setKeyboardEnabled(false);
    keyboardController.enableScannerMode();
  }

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
      await _reactivateFocusMode(scanState, keyboardController, scanController, scanFocusNode, onBarcodeScanned, mounted);
    }
  }

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

  Future<void> _reactivateFocusMode(
    PickingScanState scanState,
    KeyboardToggleController keyboardController,
    TextEditingController scanController,
    FocusNode scanFocusNode,
    void Function(String) onBarcodeScanned,
    bool Function() mounted,
  ) async {
    AppLogger.debug('Reactivating scanner in focus mode', tag: 'ScannerActivationController');

    _isInitialized = false;

    // S2: callback eh propagado mesmo no focus mode. Hoje activate() so
    // usa onBarcodeScanned em broadcast, mas mantemos o callback original
    // para evitar bug silencioso caso a logica de activate mude.
    await activate(
      scanState: scanState,
      keyboardController: keyboardController,
      scanFocusNode: scanFocusNode,
      scanController: scanController,
      onBarcodeScanned: onBarcodeScanned,
      mounted: mounted,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted()) return;
      scanState.setEnabled(true);
      scanState.stopProcessing();
      scanController.clear();
      scanFocusNode.requestFocus();
    });
  }

  void dispose() {
    _broadcastController.dispose();
    _isInitialized = false;
    _isPaused = false;
  }
}
