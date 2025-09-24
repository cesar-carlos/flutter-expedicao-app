/// Parâmetros para cancelar itens de separação
class CancelItemSeparationParams {
  final int codEmpresa;
  final int codSepararEstoque;
  final int codCarrinhoPercurso;
  final String itemCarrinhoPercurso;

  const CancelItemSeparationParams({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.codCarrinhoPercurso,
    required this.itemCarrinhoPercurso,
  });

  /// Valida se os parâmetros são válidos
  bool get isValid {
    return codEmpresa > 0 && 
           codSepararEstoque > 0 && 
           codCarrinhoPercurso > 0 && 
           itemCarrinhoPercurso.isNotEmpty;
  }

  /// Retorna uma lista de erros de validação
  List<String> get validationErrors {
    final errors = <String>[];

    if (codEmpresa <= 0) {
      errors.add('Código da empresa deve ser maior que zero');
    }

    if (codSepararEstoque <= 0) {
      errors.add('Código de separar estoque deve ser maior que zero');
    }

    if (codCarrinhoPercurso <= 0) {
      errors.add('Código do carrinho percurso deve ser maior que zero');
    }

    if (itemCarrinhoPercurso.isEmpty) {
      errors.add('Item carrinho percurso não pode estar vazio');
    }

    return errors;
  }

  /// Retorna uma descrição dos parâmetros para logging
  String get description {
    return 'CancelItemSeparationParams('
        'codEmpresa: $codEmpresa, '
        'codSepararEstoque: $codSepararEstoque, '
        'codCarrinhoPercurso: $codCarrinhoPercurso, '
        'itemCarrinhoPercurso: $itemCarrinhoPercurso'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelItemSeparationParams &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.codCarrinhoPercurso == codCarrinhoPercurso &&
        other.itemCarrinhoPercurso == itemCarrinhoPercurso;
  }

  @override
  int get hashCode => Object.hash(
        codEmpresa,
        codSepararEstoque,
        codCarrinhoPercurso,
        itemCarrinhoPercurso,
      );

  @override
  String toString() => description;
}
