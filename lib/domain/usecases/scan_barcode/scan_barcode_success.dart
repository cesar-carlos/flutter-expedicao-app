/// Resultado de sucesso do scan de código de barras
class ScanBarcodeSuccess {
  /// Código de barras escaneado
  final String barcode;

  /// Mensagem de sucesso
  final String message;

  const ScanBarcodeSuccess({required this.barcode, this.message = 'Código escaneado com sucesso'});

  @override
  String toString() => 'ScanBarcodeSuccess(barcode: $barcode, message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScanBarcodeSuccess && other.barcode == barcode && other.message == message;
  }

  @override
  int get hashCode => barcode.hashCode ^ message.hashCode;
}
