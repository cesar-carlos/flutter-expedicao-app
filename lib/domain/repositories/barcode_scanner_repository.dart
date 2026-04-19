import 'package:flutter/widgets.dart';
import 'package:result_dart/result_dart.dart';

/// Repository para scanner de código de barras via câmera
///
/// Esta interface abstrai a implementação específica de scanner,
/// facilitando a troca de pacotes no futuro.
abstract class BarcodeScannerRepository {
  /// Abre a câmera para escanear um código de barras.
  ///
  /// O [context] é obrigatório e usado pela implementação mobile para fazer
  /// `Navigator.push` da tela de câmera. Deve ser um `BuildContext` válido
  /// e ainda montado no momento da chamada.
  ///
  /// Retorna:
  /// - Success com o código escaneado (String)
  /// - Failure se houve erro ou cancelamento
  Future<Result<String>> scanBarcode({required BuildContext context});
}
