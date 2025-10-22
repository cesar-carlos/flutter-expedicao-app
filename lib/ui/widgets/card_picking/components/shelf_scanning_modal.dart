import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/di/locator.dart';

/// Widget dedicado para o modal de escaneamento de prateleira
///
/// Responsabilidades:
/// - Gerenciar a UI do modal de escaneamento
/// - Controlar o modo scan/manual
/// - Validar entrada do usuário
/// - Separar a lógica de UI da lógica de negócio
class ShelfScanningModal extends StatefulWidget {
  final String expectedAddress;
  final String expectedAddressDescription;
  final Function(String) onShelfScanned;
  final Function()? onBack;

  const ShelfScanningModal({
    super.key,
    required this.expectedAddress,
    required this.expectedAddressDescription,
    required this.onShelfScanned,
    this.onBack,
  });

  @override
  State<ShelfScanningModal> createState() => _ShelfScanningModalState();
}

class _ShelfScanningModalState extends State<ShelfScanningModal> {
  late final TextEditingController _scanController;
  late final FocusNode _focusNode;
  late final ShelfScanningService _shelfScanningService;
  late final AudioService _audioService;
  bool _isManualMode = false;
  bool _isClosingFromSuccess = false; // Flag para distinguir fechamento por sucesso vs botão voltar
  Timer? _validationTimer; // Timer para evitar validação duplicada

  @override
  void initState() {
    super.initState();
    _scanController = TextEditingController();
    _focusNode = FocusNode();
    _shelfScanningService = locator<ShelfScanningService>();
    _audioService = locator<AudioService>();

    // Adicionar listener para detectar entrada do scanner
    _scanController.addListener(_onScannerInput);

    // Solicitar foco após o modal ser construído (modo scan por padrão)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _enableScannerMode();
      }
    });
  }

  @override
  void dispose() {
    _scanController.removeListener(_onScannerInput);
    _scanController.dispose();
    _focusNode.dispose();
    _validationTimer?.cancel(); // Cancelar timer se existir
    super.dispose();
  }

  /// Detecta entrada do scanner (baseado no carrinho scan)
  void _onScannerInput() {
    if (_isManualMode || _scanController.text.isEmpty) return;

    // Processar entrada do scanner
    _processScannerInput();
  }

  /// Processa entrada específica do scanner
  void _processScannerInput() {
    final text = _scanController.text.trim();

    // Se o texto contém caracteres de controle (Enter), processar imediatamente
    if (_hasEnterCharacter(text)) {
      final cleanedText = _cleanBarcodeText(text);
      if (cleanedText.isNotEmpty) {
        _handleCompleteBarcode(cleanedText);
      }
      return;
    }

    // Para códigos de barras normais, processar após um pequeno delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scanController.text.trim() == text) {
        _handleCompleteBarcode(text);
      }
    });
  }

  /// Processa código de barras completo detectado pelo scanner
  void _handleCompleteBarcode(String barcode) {
    _clearScannerFieldAfterDelay();
    _validateShelfInput();
  }

  /// Limpa o campo do scanner após um delay para o usuário visualizar
  void _clearScannerFieldAfterDelay() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _scanController.clear();
      }
    });
  }

  /// Verifica se o texto contém caracteres de controle (Enter)
  bool _hasEnterCharacter(String text) {
    return RegExp(r'[\n\r\t]').hasMatch(text);
  }

  /// Limpa o texto do código de barras removendo caracteres não numéricos
  String _cleanBarcodeText(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  void _validateShelfInput() {
    // Cancelar timer anterior se existir
    _validationTimer?.cancel();

    // Criar novo timer para executar validação após um pequeno delay
    _validationTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      final input = _scanController.text.trim();
      if (input.isEmpty) return;

      print('🔍 DEBUG: Iniciando validação para: $input');
      final isValid = _shelfScanningService.validateScannedAddress(
        scannedAddress: input,
        expectedAddress: widget.expectedAddress,
        expectedAddressDescription: widget.expectedAddressDescription,
        isManualMode: _isManualMode,
      );

      if (isValid) {
        print('🔍 DEBUG: Validação passou - fechando modal por sucesso');
        _isClosingFromSuccess = true; // Marcar que está fechando por sucesso
        Navigator.of(context).pop();
        widget.onShelfScanned(input);
      } else {
        print('🔍 DEBUG: Validação falhou - mostrando erro');
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
        backgroundColor: Colors.red,
      ),
    );

    _audioService.playError();
  }

  void _toggleInputMode() {
    setState(() {
      _isManualMode = !_isManualMode;
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

  /// Habilita modo scanner com fechamento do teclado (baseado no KeyboardToggleController)
  void _enableScannerMode() {
    _hideKeyboard();

    Future.delayed(UIConstants.shortDelay, () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  /// Habilita modo teclado com abertura automática (baseado no KeyboardToggleController)
  void _enableKeyboardMode() {
    _focusNode.unfocus();

    Future.delayed(UIConstants.shortDelay, () {
      if (mounted) {
        _focusNode.requestFocus();
        _forceKeyboardShow();
      }
    });
  }

  /// Força a abertura do teclado (baseado no KeyboardToggleController)
  void _forceKeyboardShow() {
    Future.delayed(UIConstants.shortLoadingDelay, () {
      if (mounted) {
        try {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        } catch (e) {
          // Fallback: tentar novamente
          Future.delayed(UIConstants.shortDelay, () {
            if (mounted) {
              _focusNode.requestFocus();
            }
          });
        }
      }
    });
  }

  /// Esconde o teclado (baseado no KeyboardToggleController)
  void _hideKeyboard() {
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    } catch (e) {
      // Fallback: usar unfocus para fechar teclado
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('🔍 DEBUG: WillPopScope chamado - _isClosingFromSuccess: $_isClosingFromSuccess');
        // Se está fechando por sucesso, não chamar onBack
        if (_isClosingFromSuccess) {
          print('🔍 DEBUG: Fechando por sucesso - permitindo fechamento normal');
          return true; // Permitir fechamento normal
        }

        // Se tem callback onBack, chamá-lo
        if (widget.onBack != null) {
          print('🔍 DEBUG: Chamando onBack callback');
          widget.onBack!();
          return false; // Não fazer pop automático, o callback já faz
        }

        print('🔍 DEBUG: Não permitindo fechamento');
        return false; // Não permitir fechamento
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9 + 13, // Largura padrão + 13px
        child: AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.orange, size: UIConstants.largeIconSize),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Prateleira',
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue, size: UIConstants.mediumIconSize),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.expectedAddressDescription,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.smallPadding),
              TextField(
                controller: _scanController,
                focusNode: _focusNode,
                autofocus: false, // Não abrir teclado automaticamente
                enableInteractiveSelection: _isManualMode, // Permitir seleção apenas em modo manual
                keyboardType: _isManualMode ? TextInputType.text : TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(
                  labelText: 'Código da Prateleira',
                  border: OutlineInputBorder(),
                  prefixIcon: GestureDetector(
                    onTap: _toggleInputMode,
                    child: Icon(_isManualMode ? Icons.keyboard : Icons.qr_code_scanner, color: Colors.orange),
                  ),
                ),
                onSubmitted: (_) => _validateShelfInput(),
              ),
            ],
          ),
          actions: [if (widget.onBack != null) TextButton(onPressed: widget.onBack, child: const Text('Voltar'))],
        ),
      ),
    );
  }
}
