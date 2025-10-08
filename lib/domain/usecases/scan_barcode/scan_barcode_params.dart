/// Parâmetros para o caso de uso de scan de código de barras
///
/// Este caso de uso não requer parâmetros,
/// mas mantemos a classe para seguir o padrão do projeto
class ScanBarcodeParams {
  const ScanBarcodeParams();

  /// Sempre válido pois não há parâmetros para validar
  bool get isValid => true;

  /// Sempre retorna lista vazia pois não há validações
  List<String> get validationErrors => [];
}
