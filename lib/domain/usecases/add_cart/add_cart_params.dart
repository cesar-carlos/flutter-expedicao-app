import 'package:exp/domain/models/expedition_origem_model.dart';

/// Parâmetros para adicionar um carrinho à separação
class AddCartParams {
  final int codEmpresa;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final int codCarrinho;

  const AddCartParams({
    required this.codEmpresa,
    required this.origem,
    required this.codOrigem,
    required this.codCarrinho,
  });

  @override
  String toString() {
    return 'AddCartParams('
        'codEmpresa: $codEmpresa, '
        'origem: ${origem.description}, '
        'codOrigem: $codOrigem'
        'codCarrinho: $codCarrinho, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddCartParams &&
        other.codEmpresa == codEmpresa &&
        other.origem == origem &&
        other.codOrigem == codOrigem &&
        other.codCarrinho == codCarrinho;
  }

  @override
  int get hashCode {
    return Object.hash(codEmpresa, origem, codOrigem, codCarrinho);
  }

  /// Valida se os parâmetros são válidos
  bool get isValid {
    return codEmpresa > 0 && codOrigem > 0 && codCarrinho > 0;
  }

  /// Retorna uma lista de erros de validação
  List<String> get validationErrors {
    final errors = <String>[];

    if (codEmpresa <= 0) {
      errors.add('Código da empresa deve ser maior que zero');
    }

    if (codCarrinho <= 0) {
      errors.add('Código do carrinho é obrigatório');
    }

    if (codOrigem <= 0) {
      errors.add('Código de origem deve ser maior que zero');
    }

    return errors;
  }
}
