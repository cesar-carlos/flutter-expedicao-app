/// Parâmetros para cancelar um carrinho
class CancelCartParams {
  final int codEmpresa;
  final int codCarrinhoPercurso;
  final String item;

  const CancelCartParams({required this.codEmpresa, required this.codCarrinhoPercurso, required this.item});

  /// Valida se os parâmetros são válidos
  bool get isValid {
    return codEmpresa > 0 && codCarrinhoPercurso > 0 && item.isNotEmpty;
  }

  /// Retorna uma lista de erros de validação
  List<String> get validationErrors {
    final errors = <String>[];

    if (codEmpresa <= 0) {
      errors.add('Código da empresa deve ser maior que zero');
    }

    if (codCarrinhoPercurso <= 0) {
      errors.add('Código do carrinho percurso deve ser maior que zero');
    }

    if (item.isEmpty) {
      errors.add('Código do carrinho deve ser maior que zero');
    }

    return errors;
  }

  /// Retorna uma descrição dos parâmetros para logging
  String get description {
    return 'CancelCartParams('
        'codEmpresa: $codEmpresa, '
        'codCarrinhoPercurso: $codCarrinhoPercurso, '
        'item: $item'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelCartParams &&
        other.codEmpresa == codEmpresa &&
        other.codCarrinhoPercurso == codCarrinhoPercurso &&
        other.item == item;
  }

  @override
  int get hashCode => Object.hash(codEmpresa, codCarrinhoPercurso, item);

  @override
  String toString() => description;
}
