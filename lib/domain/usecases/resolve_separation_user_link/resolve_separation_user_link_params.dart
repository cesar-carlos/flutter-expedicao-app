import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';

class ResolveSeparationUserLinkParams {
  final SeparateConsultationModel separation;
  final int codUsuario;
  final int codSetorEstoque;

  const ResolveSeparationUserLinkParams({
    required this.separation,
    required this.codUsuario,
    required this.codSetorEstoque,
  });

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];
    if (codUsuario <= 0) errors.add('Código do usuário deve ser maior que zero');
    if (codSetorEstoque <= 0) errors.add('Código do setor estoque deve ser maior que zero');
    return errors;
  }
}
