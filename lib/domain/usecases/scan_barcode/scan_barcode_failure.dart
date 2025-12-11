import 'package:data7_expedicao/core/results/app_failure.dart';

class ScanBarcodeFailure extends AppFailure {
  const ScanBarcodeFailure({required super.message, super.code, super.exception});

  @override
  String get userMessage => message;

  factory ScanBarcodeFailure.cancelled() {
    return const ScanBarcodeFailure(message: 'Scan cancelado pelo usuário', code: 'SCAN_CANCELLED');
  }

  factory ScanBarcodeFailure.emptyBarcode() {
    return const ScanBarcodeFailure(message: 'Código de barras vazio', code: 'EMPTY_BARCODE');
  }

  factory ScanBarcodeFailure.scannerError(String details) {
    return ScanBarcodeFailure(message: 'Erro ao escanear código de barras: $details', code: 'SCANNER_ERROR');
  }

  factory ScanBarcodeFailure.permissionDenied() {
    return const ScanBarcodeFailure(message: 'Permissão de câmera negada', code: 'PERMISSION_DENIED');
  }

  @override
  String toString() => 'ScanBarcodeFailure: $message';
}
