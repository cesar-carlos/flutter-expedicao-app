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

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];

    if (codEmpresa <= 0) {
      errors.add('Código da empresa deve ser maior que zero');
    }

    if (codCarrinhoPercurso <= 0) {
      errors.add('Código do carrinho percurso deve ser maior que zero');
    }

    if (itemCarrinhoPercurso.isEmpty) {
      errors.add('Item carrinho percurso não pode estar vazio');
    } else if (itemCarrinhoPercurso.length > 5) {
      errors.add('Item carrinho percurso deve ter no máximo 5 caracteres');
    }

    if (codSepararEstoque <= 0) {
      errors.add('Código de separar estoque deve ser maior que zero');
    }

    return errors;
  }

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
