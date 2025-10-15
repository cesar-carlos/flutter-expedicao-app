import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BarcodeScanner extends StatefulWidget {
  final Function(String) onBarcodeScanned;
  final bool isLoading;

  const BarcodeScanner({super.key, required this.onBarcodeScanned, this.isLoading = false});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final _barcodeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _scanTimer;
  bool _keyboardEnabled = false; // Estado do teclado

  @override
  void initState() {
    super.initState();

    // Listener para detectar quando o scanner termina de enviar o código
    _barcodeController.addListener(_onScannerInput);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onScannerInput() {
    // Cancelar timer anterior se existir
    _scanTimer?.cancel();

    // Diferentes estratégias para scanner vs teclado
    if (!_keyboardEnabled && _barcodeController.text.isNotEmpty) {
      final currentLength = _barcodeController.text.length;
      final text = _barcodeController.text.trim();

      // Verificar se há caracteres de controle no texto completo
      if (text.contains('\n') || text.contains('\r') || text.contains('\t')) {
        // Se há caractere de controle, processar imediatamente
        _processScannedCode();
        return;
      }

      // Detectar códigos EAN-13 (13 dígitos) imediatamente
      if (currentLength == 13 && RegExp(r'^\d{13}$').hasMatch(text)) {
        _processScannedCode();
        return;
      }

      // Detectar códigos de 14-16 dígitos imediatamente
      if (currentLength >= 14 && currentLength <= 16 && RegExp(r'^\d+$').hasMatch(text)) {
        _processScannedCode();
        return;
      }

      // Para outros tamanhos, usar timer baseado no comprimento
      final waitTime = _getWaitTimeForLength(currentLength);
      _scanTimer = Timer(Duration(milliseconds: waitTime), () {
        if (_barcodeController.text.isNotEmpty) {
          _processScannedCode();
        }
      });
    }
  }

  /// Retorna o tempo de espera baseado no comprimento do código
  int _getWaitTimeForLength(int length) {
    if (length < 6) return 1000; // Aguardar mais dados
    if (length >= 6 && length < 13) return 800; // Tempo maior para códigos menores aguardarem mais entrada
    if (length >= 13 && length <= 16) return 300; // Tempo reduzido para códigos completos
    return 200; // Processar rápido para códigos longos
  }

  void _processBarcode(String text) {
    if (text.isEmpty || widget.isLoading) return;

    // Limpar caracteres especiais que podem vir do scanner (incluindo Enter/Return)
    final cleanText = text.replaceAll(RegExp(r'[^\d]'), '');

    // Validar comprimento para evitar códigos incompletos
    final minLength = _keyboardEnabled ? 3 : 6;

    if (cleanText.length >= minLength) {
      // Processar código válido
      widget.onBarcodeScanned(cleanText);

      // Limpar campo e restaurar foco
      _barcodeController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _processScannedCode() {
    final text = _barcodeController.text.trim();
    _processBarcode(text);
  }

  void _toggleKeyboard() {
    if (mounted) {
      setState(() {
        _keyboardEnabled = !_keyboardEnabled;
      });
    }

    // Gerenciar foco baseado no modo selecionado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_keyboardEnabled) {
          // Modo teclado: forçar abertura do teclado virtual
          _focusNode.unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _focusNode.requestFocus();
          });
        } else {
          // Modo scanner: fechar teclado virtual e manter foco para scanner físico
          _focusNode.unfocus();
          FocusScope.of(context).unfocus();
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _focusNode.requestFocus();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _barcodeController.removeListener(_onScannerInput);
    _barcodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.secondaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code_scanner, size: 48, color: colorScheme.primary),

          const SizedBox(height: 12),

          Text(
            'Escaneie o Código de Barras',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            _keyboardEnabled
                ? 'Digite o código de barras e pressione Enter'
                : 'Posicione o leitor sobre o código de barras do carrinho',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _barcodeController,
            focusNode: _focusNode,
            enabled: !widget.isLoading,
            autofocus: true,
            textInputAction: TextInputAction.done,
            keyboardType: _keyboardEnabled ? TextInputType.number : TextInputType.none,
            inputFormatters: _keyboardEnabled ? [FilteringTextInputFormatter.digitsOnly] : null,
            enableInteractiveSelection: _keyboardEnabled,
            showCursor: true,
            decoration: InputDecoration(
              labelText: 'Código de Barras',
              hintText: _keyboardEnabled ? 'Digite o código...' : 'Aguardando scanner',
              prefixIcon: IconButton(
                icon: Icon(_keyboardEnabled ? Icons.keyboard : Icons.qr_code_scanner, color: colorScheme.primary),
                onPressed: _toggleKeyboard,
                tooltip: _keyboardEnabled ? 'Usar scanner' : 'Usar teclado',
              ),
              suffixIcon: widget.isLoading
                  ? Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                          onPressed: () {
                            _barcodeController.clear();
                            _focusNode.requestFocus();
                          },
                        ),
                        IconButton(
                          onPressed: _barcodeController.text.isNotEmpty ? () => _onScanPressed() : null,
                          icon: const Icon(Icons.search),
                          tooltip: 'Buscar carrinho',
                        ),
                      ],
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            onFieldSubmitted: (value) => _onScanPressed(),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.isLoading ? null : _onScanPressed,
              icon: widget.isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                    )
                  : const Icon(Icons.search, size: 18),
              label: Text(widget.isLoading ? 'Buscando...' : 'Buscar Carrinho'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onScanPressed() {
    final text = _barcodeController.text.trim();
    _processBarcode(text);
  }
}
