import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/barcode_broadcast_service.dart';
import 'package:data7_expedicao/core/services/scanner_mode_coordinator.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';

class ShelfScanningScreen extends StatefulWidget {
  final String expectedAddress;
  final String expectedAddressDescription;
  final CardPickingViewModel viewModel;
  final String? returnRoute;

  const ShelfScanningScreen({
    super.key,
    required this.expectedAddress,
    required this.expectedAddressDescription,
    required this.viewModel,
    this.returnRoute,
  });

  @override
  State<ShelfScanningScreen> createState() => _ShelfScanningScreenState();
}

class _ShelfScanningScreenState extends State<ShelfScanningScreen> {
  late final TextEditingController _scanController;
  late final FocusNode _focusNode;
  late final ShelfScanningService _shelfScanningService;
  late final AudioService _audioService;
  late final ConfigViewModel _configViewModel;
  late final ScannerModeCoordinator _coordinator;

  bool _isManualMode = false;
  bool _isClosingFromSuccess = false;
  bool _hasFocus = false;
  Timer? _validationTimer;

  bool get _isBroadcastActive => _coordinator.isBroadcastActive;

  @override
  void initState() {
    super.initState();
    _scanController = TextEditingController();
    _focusNode = FocusNode();
    _shelfScanningService = locator<ShelfScanningService>();
    _audioService = locator<AudioService>();
    _configViewModel = locator<ConfigViewModel>();
    _coordinator = ScannerModeCoordinator(
      broadcastService: locator<BarcodeBroadcastService>(),
      onBarcode: _onBroadcastCode,
    );

    _scanController.addListener(_onScannerInput);
    _focusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Mantemos o delay original de 100ms (timing estabelecido para
      // aguardar o widget tree estabilizar antes de pedir foco).
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 100)).then((_) => _runCoordinatorStartup()).catchError((
          Object e,
          StackTrace s,
        ) {
          AppLogger.warning(
            'Falha ao iniciar coordinator na tela de endereço',
            tag: 'ShelfScanningScreen',
            error: e,
            stackTrace: s,
          );
        }),
      );
    });
  }

  Future<void> _runCoordinatorStartup() async {
    if (!mounted) return;
    await _coordinator.start(_loadScannerPreferences());
    if (!mounted) return;
    if (_coordinator.isBroadcastActive) {
      _hideKeyboard();
      _focusNode.unfocus();
    } else {
      _enableScannerMode();
      unawaited(
        Future<void>.delayed(UIConstants.shortDelay, () {
          if (mounted) {
            _focusNode.requestFocus();
          }
        }).catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha ao solicitar foco do campo de scan (prateleira)',
            tag: 'ShelfScanningScreen',
            error: e,
            stackTrace: s,
          );
        }),
      );
    }
  }

  @override
  void dispose() {
    _scanController.removeListener(_onScannerInput);
    _focusNode.removeListener(_onFocusChange);
    _scanController.dispose();
    _focusNode.dispose();
    unawaited(
      _coordinator.dispose().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Erro ao encerrar ScannerModeCoordinator (tela prateleira)',
          tag: 'ShelfScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
    _validationTimer?.cancel();
    super.dispose();
  }

  void _onBroadcastCode(String code) {
    if (!mounted) return;
    // B4: NAO usar cleanBarcodeText (que so mantem digitos) — enderecos
    // de prateleira podem ter letras e separadores (ex.: "01-A-2").
    // A validacao em PickingUtils.validateShelfBarcode compara o endereco
    // INTEGRO apos trim. Apenas removemos caracteres de controle.
    final trimmed = _stripControlChars(code).trim();
    if (trimmed.isEmpty) return;
    _handleCompleteBarcode(trimmed);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  ScannerModePreferences _loadScannerPreferences() {
    try {
      _configViewModel.loadConfigSilent();
      final config = _configViewModel.currentConfig;
      final prefs = ScannerModePreferences(
        mode: config.scannerInputMode,
        action: (config.broadcastAction ?? '').trim(),
        extraKey: (config.broadcastExtraKey ?? '').trim(),
      );
      AppLogger.debug(
        'prefs mode=${prefs.mode} action=${prefs.action} extra=${prefs.extraKey}',
        tag: 'ShelfScreen',
      );
      return prefs;
    } catch (_) {
      return ScannerModePreferences.empty;
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
      // B3: NAO removemos hifens/pontos. A validacao do endereco eh exata
      // via validateShelfBarcode. Apenas removemos chars de controle.
      final cleanedText = _stripControlChars(text).trim();
      if (cleanedText.isNotEmpty) {
        _handleCompleteBarcode(cleanedText);
      }
      return;
    }

    // B7: cancela timer anterior em vez de empilhar Future.delayed por keystroke.
    _validationTimer?.cancel();
    _validationTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && _scanController.text.trim() == text) {
        _handleCompleteBarcode(text);
      }
    });
  }

  void _handleCompleteBarcode(String barcode) {
    AppLogger.debug('complete="$barcode"', tag: 'ShelfScreen');
    _clearScannerFieldAfterDelay();
    // S5: validacao imediata. O Timer de 100ms em _validateShelfInput era
    // util para reduzir reentrancia durante digitacao manual; chamadas vindas
    // de Enter/broadcast ja sao atomicas e nao precisam do delay.
    _validateShelfInputImmediate(barcode);
  }

  void _validateShelfInputImmediate(String input) {
    _validationTimer?.cancel();
    if (!mounted) return;
    _runShelfValidation(input.trim());
  }

  void _clearScannerFieldAfterDelay() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _scanController.clear();
      }
    });
  }

  static final _controlCharsPattern = RegExp(r'[\n\r\t]');

  bool _hasEnterCharacter(String text) {
    return _controlCharsPattern.hasMatch(text);
  }

  /// Remove apenas caracteres de controle (Enter/Return/Tab),
  /// preservando letras, dígitos e separadores como hífen e ponto,
  /// que podem fazer parte de códigos de endereço (ex.: "01-A-2").
  String _stripControlChars(String text) {
    return text.replaceAll(_controlCharsPattern, '');
  }

  void _validateShelfInput([String? scannedValue]) {
    _validationTimer?.cancel();

    _validationTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      final input = (scannedValue ?? _scanController.text).trim();
      _runShelfValidation(input);
    });
  }

  void _runShelfValidation(String input) {
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
            'Falha ao reproduzir som de sucesso (prateleira/tela)',
            tag: 'ShelfScreen',
            error: e,
            stackTrace: s,
          );
        }),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pop();
        }
      });
    } else {
      _showValidationError();
    }
  }

  void _showValidationError() {
    // Bug LLLLLLL: _showValidationError pode ser chamada por callback
    // de Timer (linha 164) ou por callback assincrono. Sem mounted
    // check, ScaffoldMessenger.of(context) lanca em widget desmontado.
    if (!mounted) return;
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
          'Falha ao reproduzir som de erro (prateleira/tela)',
          tag: 'ShelfScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _toggleInputMode() {
    AppLogger.debug('toggle manual=${!_isManualMode}', tag: 'ShelfScreen');
    setState(() {
      _isManualMode = !_isManualMode;
      _handleKeyboardControl();
    });
    // Override manual delegado ao coordinator: ele decide se para/reinicia
    // a subscription com base nas prefs atuais.
    unawaited(
      _coordinator.setManualOverride(_isManualMode).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao aplicar override manual do scanner',
          tag: 'ShelfScreen',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _handleKeyboardControl() {
    if (_isManualMode) {
      _enableKeyboardMode();
    } else {
      _enableScannerMode();
    }
  }

  void _enableScannerMode() {
    AppLogger.debug('enable scanner mode', tag: 'ShelfScreen');
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
    AppLogger.debug('enable keyboard mode', tag: 'ShelfScreen');
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

  void _handleBack() {
    if (_isClosingFromSuccess) {
      context.pop();
    } else {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isClosingFromSuccess,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: CustomAppBar.withCustomTitle(
          title: Row(
            children: [
              Icon(Icons.qr_code_scanner, color: AppColors.warning, size: UIConstants.largeIconSize),
              const SizedBox(width: 8),
              const Expanded(child: Text('Prateleira', overflow: TextOverflow.ellipsis)),
            ],
          ),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handleBack),
          showSocketStatus: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(UIConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.info, size: UIConstants.mediumIconSize),
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
              const SizedBox(height: UIConstants.largePadding),
              TextField(
                controller: _scanController,
                focusNode: _focusNode,
                autofocus: false,
                enableInteractiveSelection: _isManualMode,
                readOnly: !_isManualMode && _isBroadcastActive,
                keyboardType: _isManualMode
                    ? TextInputType.text
                    : (_isBroadcastActive ? TextInputType.none : const TextInputType.numberWithOptions(decimal: false)),
                showCursor: !_isManualMode && !_isBroadcastActive && _hasFocus,
                decoration: InputDecoration(
                  labelText: context.l10n.shelfCode,
                  border: const OutlineInputBorder(),
                  prefixIcon: GestureDetector(
                    onTap: _toggleInputMode,
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
        ),
      ),
    );
  }
}
