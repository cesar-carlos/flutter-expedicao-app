/// Parâmetros para salvar carrinho na separação
class SaveSeparationCartParams {
  final int codEmpresa;
  final int codCarrinhoPercurso;
  final String itemCarrinhoPercurso;
  final int codSepararEstoque;

  const SaveSeparationCartParams({
    required this.codEmpresa,
    required this.codCarrinhoPercurso,
    required this.itemCarrinhoPercurso,
    required this.codSepararEstoque,
  });

  @override
  String toString() {
    return '''
      SaveSeparationCartParams(
        codEmpresa: $codEmpresa,
        codCarrinhoPercurso: $codCarrinhoPercurso,
        itemCarrinhoPercurso: $itemCarrinhoPercurso,
        codSepararEstoque: $codSepararEstoque
      )''';
  }
}
