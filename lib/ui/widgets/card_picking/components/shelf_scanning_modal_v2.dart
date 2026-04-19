import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/barcode_broadcast_service.dart';
import 'package:data7_expedicao/core/services/barcode_scanner_service.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';

class ShelfScanningModalV2 extends StatefulWidget {
  final String expectedAddress;
  final String expectedAddressDescription;
  final CardPickingViewModel viewModel;
  final VoidCallback? onBack;

  const ShelfScanningModalV2({
    super.key,
    required this.expectedAddress,
    required this.expectedAddressDescription,
    required this.viewModel,
    this.onBack,
  });

  @override
  State<ShelfScanningModalV2> createState() => _ShelfScanningModalV2State();
}

class _ShelfScanningModalV2State extends State<ShelfScanningModalV2> {
  late final TextEditingController _scanController;
  late final FocusNode _focusNode;
  late final ShelfScanningService _shelfScanningService;
  late final AudioService _audioService;
  late final BarcodeScannerService _scannerService;
  late final BarcodeBroadcastService _broadcastService;
  late final ConfigViewModel _configViewModel;

  StreamSubscription<String>? _broadcastSub;
  ScannerInputMode _scannerMode = ScannerInputMode.focus;
  String _broadcastAction = '';
  String _broadcastExtraKey = '';
  bool _manualOverrideBroadcast = false;
  bool _isManualMode = false;
  bool _isClosingFromSuccess = false;
  bool _hasFocus = false;
  Timer? _validationTimer;

  bool get _isBroadcastConfigured =>
      _scannerMode == ScannerInputMode.broadcast && _broadcastAction.isNotEmpty && _broadcastExtraKey.isNotEmpty;

  bool get _isBroadcastActive => _isBroadcastConfigured && !_manualOverrideBroadcast;

  @override
  void initState() {
    super.initState();
    _scanController = TextEditingController();
    _focusNode = FocusNode();
    _shelfScanningService = locator<ShelfScanningService>();
    _audioService = locator<AudioService>();
    _scannerService = locator<BarcodeScannerService>();
    _broadcastService = locator<BarcodeBroadcastService>();
    _configViewModel = locator<ConfigViewModel>();

    _scanController.addListener(_onScannerInput);
    _focusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadScannerPreferences();
        Future.delayed(UIConstants.shortLoadingDelay, () {
          if (!mounted) return;
          if (_isBroadcastActive) {
            _startBroadcastListener();
            _hideKeyboard();
            _focusNode.unfocus();
          } else {
            _enableScannerMode();
            Future.delayed(UIConstants.shortDelay, () {
              if (mounted) {
                _focusNode.requestFocus();
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scanController.removeListener(_onScannerInput);
    _focusNode.removeListener(_onFocusChange);
    _scanController.dispose();
    _focusNode.dispose();
    final sub = _broadcastSub;
    _broadcastSub = null;
    if (sub != null) {
      unawaited(
        sub.cancel().catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Erro ao cancelar inscrição broadcast no dispose',
            tag: 'ShelfScanningModalV2',
            error: e,
            stackTrace: s,
          );
        }),
      );
    }
    _validationTimer?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  void _loadScannerPreferences() {
    try {
      _configViewModel.loadConfigSilent();
      final config = _configViewModel.currentConfig;
      _scannerMode = config.scannerInputMode;
      _broadcastAction = (config.broadcastAction ?? '').trim();
      _broadcastExtraKey = (config.broadcastExtraKey ?? '').trim();
      AppLogger.debug(
        'Shelf modal V2 scanner preferences loaded: mode=$_scannerMode action=$_broadcastAction extra=$_broadcastExtraKey',
        tag: 'ShelfScanningModalV2',
      );
    } catch (e, stackTrace) {
      _scannerMode = ScannerInputMode.focus;
      _broadcastAction = '';
      _broadcastExtraKey = '';
      AppLogger.warning(
        'Failed to load scanner preferences, using defaults',
        tag: 'ShelfScanningModalV2',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _startBroadcastListener() {
    if (!_isBroadcastConfigured) return;
    if (_manualOverrideBroadcast) return;
    AppLogger.debug(
      'Starting broadcast listener: action=$_broadcastAction extra=$_broadcastExtraKey',
      tag: 'ShelfScanningModalV2',
    );
    _broadcastSub?.cancel();
    _broadcastSub = _broadcastService.listen(action: _broadcastAction, extraKey: _broadcastExtraKey).listen((code) {
      if (!mounted) return;
      final trimmed = _scannerService.cleanBarcodeText(code.trim());
      if (trimmed.isEmpty) return;
      _handleCompleteBarcode(trimmed);
    });
  }

  Future<void> _stopBroadcastListener() async {
    AppLogger.debug('Stopping broadcast listener', tag: 'ShelfScanningModalV2');
    try {
      await _broadcastSub?.cancel();
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Error canceling broadcast subscription',
        tag: 'ShelfScanningModalV2',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _broadcastSub = null;
    }
  }

  void _onScannerInput() {
    if (_isBroadcastActive) return;
    if (_isManualMode || _scanController.text.isEmpty) return;

    _processScannerInput();
  }

  void _processScannerInput() {
    final text = _scanController.text.trim();

    if (_hasEnterCharacter(text)) {
      final cleanedText = _cleanBarcodeText(text);
      if (cleanedText.isNotEmpty) {
        _handleCompleteBarcode(cleanedText);
      }
      return;
    }

    Future.delayed(UIConstants.shortLoadingDelay, () {
      if (mounted && _scanController.text.trim() == text) {
        _handleCompleteBarcode(text);
      }
    });
  }

  void _handleCompleteBarcode(String barcode) {
    AppLogger.debug('Complete barcode scanned: $barcode', tag: 'ShelfScanningModalV2');
    _clearScannerFieldAfterDelay();
    _validateShelfInput(barcode);
  }

  void _clearScannerFieldAfterDelay() {
    Future.delayed(UIConstants.scannerDisplayDelay, () {
      if (mounted) {
        _scanController.clear();
      }
    });
  }

  bool _hasEnterCharacter(String text) {
    return RegExp(r'[\n\r\t]').hasMatch(text);
  }

  String _cleanBarcodeText(String text) {
    return text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  }

  void _validateShelfInput([String? scannedValue]) {
    _validationTimer?.cancel();

    _validationTimer = Timer(UIConstants.shortLoadingDelay, () {
      if (!mounted) return;

      final input = (scannedValue ?? _scanController.text).trim();
      if (input.isEmpty) return;

      final isValid = _shelfScanningService.validateScannedAddress(
        scannedAddress: input,
        expectedAddress: widget.expectedAddress,
        expectedAddressDescription: widget.expectedAddressDescription,
        isManualMode: _isManualMode,
      );

      if (isValid) {
        _isClosingFromSuccess = true;
        widget.viewModel.updateScannedAddress(input);
        unawaited(
          _audioService.playShelfScanSuccess().catchError((Object e, StackTrace s) {
            AppLogger.warning(
              'Falha ao reproduzir som de sucesso (prateleira)',
              tag: 'ShelfScanningModalV2',
              error: e,
              stackTrace: s,
            );
          }),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(Duration.zero, () {
            if (mounted) Navigator.of(context).pop();
          });
        });
      } else {
        _showValidationError();
      }
    });
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isManualMode
              ? 'Endereço incorreto. Esperado: ${widget.expectedAddressDescription}'
              : 'Código de barras incorreto. Esperado: ${widget.expectedAddress}',
        ),
        backgroundColor: AppColors.error,
      ),
    );

    unawaited(
      _audioService.playError().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao reproduzir som de erro (validação prateleira)',
          tag: 'ShelfScanningModalV2',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  Future<void> _toggleInputMode() async {
    final willBeManual = !_isManualMode;
    AppLogger.debug('Toggling input mode: manual=$willBeManual', tag: 'ShelfScanningModalV2');

    if (willBeManual && _isBroadcastConfigured) {
      _manualOverrideBroadcast = true;
      await _stopBroadcastListener();
      if (!mounted) return;
    }

    setState(() {
      _isManualMode = willBeManual;
      if (!_isManualMode && _isBroadcastConfigured) {
        _manualOverrideBroadcast = false;
        _startBroadcastListener();
      }
      _handleKeyboardControl();
    });
  }

  void _handleKeyboardControl() {
    if (_isManualMode) {
      _enableKeyboardMode();
    } else {
      _enableScannerMode();
    }
  }

  void _enableScannerMode() {
    AppLogger.debug('Enabling scanner mode', tag: 'ShelfScanningModalV2');
    _hideKeyboard();

    if (!_isBroadcastActive) {
      Future.delayed(UIConstants.shortDelay, () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    } else {
      _focusNode.unfocus();
    }
  }

  void _enableKeyboardMode() {
    AppLogger.debug('Enabling keyboard mode', tag: 'ShelfScanningModalV2');
    _focusNode.unfocus();

    Future.delayed(UIConstants.shortDelay, () {
      if (mounted) {
        _focusNode.requestFocus();
        _forceKeyboardShow();
      }
    });
  }

  void _forceKeyboardShow() {
    Future.delayed(UIConstants.shortLoadingDelay, () {
      if (mounted) {
        try {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        } catch (e) {
          Future.delayed(UIConstants.shortDelay, () {
            if (mounted) {
              _focusNode.requestFocus();
            }
          });
        }
      }
    });
  }

  void _hideKeyboard() {
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    } catch (e) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isClosingFromSuccess,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          final navigator = Navigator.of(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(Duration.zero, () {
              if (navigator.mounted) navigator.pop();
            });
          });
        }
      },
      child: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          return SizedBox(
            width: screenWidth * 0.9 + 13,
            child: AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              title: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, color: AppColors.warning, size: UIConstants.largeIconSize),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Prateleira', overflow: TextOverflow.ellipsis)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.info, size: UIConstants.mediumIconSize),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.expectedAddressDescription,
                          style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.smallPadding),
                  TextField(
                    controller: _scanController,
                    focusNode: _focusNode,
                    autofocus: false,
                    enableInteractiveSelection: _isManualMode,
                    readOnly: !_isManualMode && _isBroadcastActive,
                    keyboardType: _isManualMode
                        ? TextInputType.text
                        : (_isBroadcastActive
                              ? TextInputType.none
                              : const TextInputType.numberWithOptions(decimal: false)),
                    showCursor: !_isManualMode && !_isBroadcastActive && _hasFocus,
                    decoration: InputDecoration(
                      labelText: context.l10n.shelfCode,
                      border: const OutlineInputBorder(),
                      prefixIcon: GestureDetector(
                        onTap: () {
                          unawaited(
                            _toggleInputMode().catchError((Object e, StackTrace s) {
                              AppLogger.warning(
                                'Falha ao alternar modo de entrada (prateleira)',
                                tag: 'ShelfScanningModalV2',
                                error: e,
                                stackTrace: s,
                              );
                            }),
                          );
                        },
                        child: Icon(_isManualMode ? Icons.keyboard : Icons.qr_code_scanner, color: AppColors.warning),
                      ),
                    ),
                    onSubmitted: (_) => _validateShelfInput(),
                    onTap: () {
                      if (_isBroadcastActive) {
                        _focusNode.unfocus();
                        _hideKeyboard();
                      } else if (!_isManualMode) {
                        _focusNode.requestFocus();
                      }
                    },
                  ),
                ],
              ),
              actions: [
                if (widget.onBack != null)
                  TextButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Future.delayed(Duration.zero, () {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            widget.onBack!();
                          }
                        });
                      });
                    },
                    child: Text(context.l10n.back),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
