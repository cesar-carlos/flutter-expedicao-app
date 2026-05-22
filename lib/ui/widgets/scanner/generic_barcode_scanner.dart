import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:data7_expedicao/core/services/barcode_scanner_service.dart';
import 'package:data7_expedicao/di/locator.dart';

/// Widget genérico para scanner de códigos de barras
///
/// Este widget pode ser usado em qualquer lugar da aplicação onde
/// seja necessário capturar códigos de barras.
///
/// Características:
/// - Processamento com debounce automático
/// - Detecção de caracteres de controle
/// - Validação de comprimento configurável
/// - Feedback tátil opcional
/// - Suporte a entrada via teclado ou scanner
class GenericBarcodeScanner extends StatefulWidget {
  /// Callback chamado quando um código de barras válido é detectado
  final ValueChanged<String> onBarcodeScanned;

  /// Se true, mostra loading durante processamento
  final bool isLoading;

  /// Comprimento mínimo para códigos de barras (padrão: 6)
  final int minLength;

  /// Se true, permite entrada via teclado (padrão: false)
  final bool allowKeyboardInput;

  /// Se true, fornece feedback tátil (padrão: true)
  final bool enableTactileFeedback;

  /// Placeholder para o campo de texto
  final String? hintText;

  /// Estilo do campo de texto
  final TextStyle? textStyle;

  /// Decoração do campo de texto
  final InputDecoration? decoration;

  final BarcodeScannerService? scannerService;

  const GenericBarcodeScanner({
    super.key,
    required this.onBarcodeScanned,
    this.isLoading = false,
    this.minLength = 6,
    this.allowKeyboardInput = false,
    this.enableTactileFeedback = true,
    this.hintText,
    this.textStyle,
    this.decoration,
    this.scannerService,
  });

  @override
  State<GenericBarcodeScanner> createState() => _GenericBarcodeScannerState();
}

class _GenericBarcodeScannerState extends State<GenericBarcodeScanner> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final BarcodeScannerService _scannerService;

  @override
  void initState() {
    super.initState();
    _scannerService = widget.scannerService ?? locator<BarcodeScannerService>();
    _controller.addListener(_onInput);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Bug SSSSSSSSS: mounted check antes de requestFocus em
      // postFrameCallback (widget pode ser desmontado entre initState
      // e a primeira frame em cenarios de navegacao rapida).
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onInput);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInput() {
    if (!widget.allowKeyboardInput && _controller.text.isNotEmpty) {
      _scannerService.processBarcodeInputWithControlDetection(
        _controller.text,
        (barcode) => _processBarcode(),
        () => _processBarcode(),
      );
    }
  }

  void _processBarcode() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    // Limpar caracteres especiais
    final cleanText = _scannerService.cleanBarcodeText(text);

    // Validar comprimento
    if (cleanText.length >= widget.minLength) {
      // Fornecer feedback tátil se habilitado
      if (widget.enableTactileFeedback) {
        try {
          HapticFeedback.lightImpact();
        } catch (_) {
          // Dispositivo não suporta feedback tátil - ignorar silenciosamente
        }
      }

      // Chamar callback
      widget.onBarcodeScanned(cleanText);

      // Limpar campo e restaurar foco
      _controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Bug TTTTTTTTT: mounted check antes de requestFocus.
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: !widget.isLoading,
      style: widget.textStyle,
      keyboardType: widget.allowKeyboardInput ? TextInputType.text : TextInputType.none,
      textInputAction: widget.allowKeyboardInput ? TextInputAction.done : TextInputAction.none,
      enableInteractiveSelection: widget.allowKeyboardInput,
      decoration:
          widget.decoration ??
          InputDecoration(
            hintText: widget.hintText ?? 'Escaneie ou digite o código de barras',
            border: const OutlineInputBorder(),
            suffixIcon: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const Icon(Icons.qr_code_scanner),
          ),
      onSubmitted: (_) {
        if (widget.allowKeyboardInput) {
          _processBarcode();
        }
      },
    );
  }
}
