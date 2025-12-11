class CancelItemSeparationParams {
  final int codEmpresa;
  final int codSepararEstoque;
  final String item;

  const CancelItemSeparationParams({required this.codEmpresa, required this.codSepararEstoque, required this.item});

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];

    if (codEmpresa <= 0) {
      errors.add('Código da empresa deve ser maior que zero');
    }

    if (codSepararEstoque <= 0) {
      errors.add('Código de separar estoque deve ser maior que zero');
    }

    if (item.isEmpty) {
      errors.add('Item não pode estar vazio');
    } else if (item.length > 5) {
      errors.add('Item deve ter no máximo 5 caracteres');
    }

    return errors;
  }

  String get description {
    return 'CancelItemSeparationParams('
        'codEmpresa: $codEmpresa, '
        'codSepararEstoque: $codSepararEstoque, '
        'item: $item'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelItemSeparationParams &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.item == item;
  }

  @override
  int get hashCode => Object.hash(codEmpresa, codSepararEstoque, item);

  @override
  String toString() => description;
}
