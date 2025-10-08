import 'package:exp/core/results/app_failure.dart';

/// Representa falhas no caso de uso de scan de código de barras
class ScanBarcodeFailure extends AppFailure {
  const ScanBarcodeFailure({required super.message, super.code, super.exception});

  @override
  String get userMessage => message;

  /// Falha quando o usuário cancela o scan
  factory ScanBarcodeFailure.cancelled() {
    return const ScanBarcodeFailure(message: 'Scan cancelado pelo usuário', code: 'SCAN_CANCELLED');
  }

  /// Falha quando o código de barras está vazio
  factory ScanBarcodeFailure.emptyBarcode() {
    return const ScanBarcodeFailure(message: 'Código de barras vazio', code: 'EMPTY_BARCODE');
  }

  /// Falha genérica do scanner
  factory ScanBarcodeFailure.scannerError(String details) {
    return ScanBarcodeFailure(message: 'Erro ao escanear código de barras: $details', code: 'SCANNER_ERROR');
  }

  /// Falha quando há erro de permissão de câmera
  factory ScanBarcodeFailure.permissionDenied() {
    return const ScanBarcodeFailure(message: 'Permissão de câmera negada', code: 'PERMISSION_DENIED');
  }

  @override
  String toString() => 'ScanBarcodeFailure: $message';
}
