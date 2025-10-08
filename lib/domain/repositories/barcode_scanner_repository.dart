import 'package:result_dart/result_dart.dart';

/// Repository para scanner de código de barras via câmera
///
/// Esta interface abstrai a implementação específica de scanner,
/// facilitando a troca de pacotes no futuro.
abstract class BarcodeScannerRepository {
  /// Abre a câmera para escanear um código de barras
  ///
  /// Retorna:
  /// - Success com o código escaneado (String)
  /// - Failure se houve erro ou cancelamento
  Future<Result<String>> scanBarcode();
}
