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
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focar automaticamente no campo para facilitar o escaneamento
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer.withOpacity(0.3), colorScheme.secondaryContainer.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          // Ícone e título
          Icon(Icons.qr_code_scanner, size: 64, color: colorScheme.primary),

          const SizedBox(height: 16),

          Text(
            'Escaneie o Código de Barras',
            style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Posicione o leitor sobre o código de barras do carrinho',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Campo de entrada do código de barras
          TextFormField(
            controller: _barcodeController,
            focusNode: _focusNode,
            enabled: !widget.isLoading,
            autofocus: true,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Código de Barras',
              hintText: 'Digite ou escaneie o código',
              prefixIcon: Icon(Icons.barcode_reader, color: colorScheme.primary),
              suffixIcon: widget.isLoading
                  ? Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                    )
                  : IconButton(
                      onPressed: _barcodeController.text.isNotEmpty ? () => _onScanPressed() : null,
                      icon: const Icon(Icons.search),
                      tooltip: 'Buscar carrinho',
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            onFieldSubmitted: (value) => _onScanPressed(),
          ),

          const SizedBox(height: 16),

          // Botão manual para escanear
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.isLoading ? null : _onScanPressed,
              icon: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                    )
                  : const Icon(Icons.search),
              label: Text(widget.isLoading ? 'Buscando...' : 'Buscar Carrinho'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onScanPressed() {
    if (_barcodeController.text.isNotEmpty && !widget.isLoading) {
      widget.onBarcodeScanned(_barcodeController.text.trim());
      // Manter o foco para facilitar novos escaneamentos
      _focusNode.requestFocus();
    }
  }
}
