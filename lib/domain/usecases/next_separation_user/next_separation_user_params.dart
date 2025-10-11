import 'package:exp/domain/models/user_system_models.dart';

/// Parâmetros para buscar a próxima separação disponível para um usuário
class NextSeparationUserParams {
  final int codEmpresa;
  final int codUsuario;
  final int? codSetorEstoque;
  final UserSystemModel? userSystemModel;

  const NextSeparationUserParams({
    required this.codEmpresa,
    required this.codUsuario,
    this.codSetorEstoque,
    this.userSystemModel,
  });

  /// Valida se os parâmetros são válidos
  bool get isValid => validationErrors.isEmpty;

  /// Retorna uma lista de erros de validação
  List<String> get validationErrors {
    final errors = <String>[];

    if (codEmpresa <= 0) errors.add('Código da empresa deve ser maior que zero');
    if (codUsuario <= 0) errors.add('Código do usuário deve ser maior que zero');
    if (userSystemModel == null) errors.add('Dados do usuário do sistema não fornecidos');
    return errors;
  }

  /// Verifica se o usuário possui setor estoque
  bool get hasValidSector => codSetorEstoque != null && codSetorEstoque! > 0;

  /// Retorna uma descrição dos parâmetros para logging
  String get description {
    return 'NextSeparationUserParams('
        'codUsuario: $codUsuario, '
        'codEmpresa: $codEmpresa, '
        'codSetorEstoque: $codSetorEstoque, '
        'userSystemModel: ${userSystemModel?.nomeUsuario ?? "null"}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NextSeparationUserParams &&
        other.codUsuario == codUsuario &&
        other.codEmpresa == codEmpresa &&
        other.codSetorEstoque == codSetorEstoque &&
        other.userSystemModel == userSystemModel;
  }

  @override
  int get hashCode => Object.hash(codUsuario, codEmpresa, codSetorEstoque, userSystemModel);

  @override
  String toString() => description;
}
