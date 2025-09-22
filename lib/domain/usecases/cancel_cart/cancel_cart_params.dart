import 'package:exp/domain/models/expedition_origem_model.dart';

/// Parâmetros para cancelar um carrinho
class CancelCartParams {
  final int codEmpresa;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final int codCarrinho;

  const CancelCartParams({
    required this.codEmpresa,
    required this.origem,
    required this.codOrigem,
    required this.codCarrinho,
  });

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
      errors.add('Código do carrinho deve ser maior que zero');
    }

    if (codOrigem <= 0) {
      errors.add('Código de origem deve ser maior que zero');
    }

    return errors;
  }

  /// Retorna uma descrição dos parâmetros para logging
  String get description {
    return 'CancelCartParams('
        'codEmpresa: $codEmpresa, '
        'codCarrinho: $codCarrinho, '
        'origem: ${origem.description}, '
        'codOrigem: $codOrigem'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelCartParams &&
        other.codEmpresa == codEmpresa &&
        other.codCarrinho == codCarrinho &&
        other.origem == origem &&
        other.codOrigem == codOrigem;
  }

  @override
  int get hashCode => Object.hash(codEmpresa, codCarrinho, origem, codOrigem);

  @override
  String toString() => description;
}
