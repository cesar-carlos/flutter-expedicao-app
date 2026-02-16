class CheckSeparationUserSectorCompletionParams {
  final int codEmpresa;
  final int codSepararEstoque;
  final int codSetorEstoque;
  final int codUsuario;

  const CheckSeparationUserSectorCompletionParams({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.codSetorEstoque,
    required this.codUsuario,
  });

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];
    if (codEmpresa <= 0) errors.add('Codigo da empresa deve ser maior que zero');
    if (codSepararEstoque <= 0) errors.add('Codigo da separacao deve ser maior que zero');
    if (codSetorEstoque <= 0) errors.add('Codigo do setor estoque deve ser maior que zero');
    if (codUsuario <= 0) errors.add('Codigo do usuario deve ser maior que zero');
    return errors;
  }
}
