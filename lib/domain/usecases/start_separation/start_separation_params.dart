import 'package:exp/domain/models/expedition_origem_model.dart';

/// Parâmetros para iniciar uma separação
class StartSeparationParams {
  final int codEmpresa;
  final ExpeditionOrigem origem;
  final int codOrigem;

  const StartSeparationParams({required this.codEmpresa, required this.origem, required this.codOrigem});

  /// Valida se os parâmetros são válidos
  bool get isValid => validationErrors.isEmpty;

  /// Retorna uma lista de erros de validação
  List<String> get validationErrors {
    final errors = <String>[];
    if (codEmpresa <= 0) errors.add('Código da empresa deve ser maior que zero');
    if (codOrigem <= 0) errors.add('Código da origem deve ser maior que zero');

    return errors;
  }

  /// Retorna uma descrição dos parâmetros para logging
  String get description {
    return 'StartSeparationParams('
        'codEmpresa: $codEmpresa, '
        'origem: ${origem.code}, '
        'codOrigem: $codOrigem'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StartSeparationParams &&
        other.codEmpresa == codEmpresa &&
        other.origem == origem &&
        other.codOrigem == codOrigem;
  }

  @override
  int get hashCode => Object.hash(codEmpresa, origem, codOrigem);

  @override
  String toString() => description;
}
