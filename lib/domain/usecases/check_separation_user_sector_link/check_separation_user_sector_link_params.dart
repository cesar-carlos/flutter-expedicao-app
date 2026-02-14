class CheckSeparationUserSectorLinkParams {
  final int codEmpresa;
  final int codSepararEstoque;
  final int codSetorEstoque;
  final int codUsuario;

  const CheckSeparationUserSectorLinkParams({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.codSetorEstoque,
    required this.codUsuario,
  });

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];
    if (codEmpresa <= 0) errors.add('Código da empresa deve ser maior que zero');
    if (codSepararEstoque <= 0) errors.add('Código da separação deve ser maior que zero');
    if (codSetorEstoque <= 0) errors.add('Código do setor estoque deve ser maior que zero');
    if (codUsuario <= 0) errors.add('Código do usuário deve ser maior que zero');
    return errors;
  }
}
