class SaveSeparationParams {
  final int codEmpresa;
  final int codSepararEstoque;

  const SaveSeparationParams({required this.codEmpresa, required this.codSepararEstoque});

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];
    if (codEmpresa <= 0) errors.add('Código da empresa deve ser maior que zero');
    if (codSepararEstoque <= 0) errors.add('Código de separar estoque deve ser maior que zero');
    return errors;
  }

  String get description {
    return 'SaveSeparationParams('
        'codEmpresa: $codEmpresa, '
        'codSepararEstoque: $codSepararEstoque'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveSeparationParams &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque;
  }

  @override
  int get hashCode => Object.hash(codEmpresa, codSepararEstoque);

  @override
  String toString() => description;
}
