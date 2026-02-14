class GetSeparationConsultationParams {
  final int codEmpresa;
  final int codSepararEstoque;

  const GetSeparationConsultationParams({
    required this.codEmpresa,
    required this.codSepararEstoque,
  });

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];
    if (codEmpresa <= 0) errors.add('Código da empresa deve ser maior que zero');
    if (codSepararEstoque <= 0) errors.add('Código da separação deve ser maior que zero');
    return errors;
  }
}
