class DeleteItemSeparationParams {
  final int codEmpresa;
  final int codSepararEstoque;
  final String item;

  const DeleteItemSeparationParams({required this.codEmpresa, required this.codSepararEstoque, required this.item});

  bool get isValid {
    return codEmpresa > 0 && codSepararEstoque > 0 && item.isNotEmpty;
  }

  List<String> get validationErrors {
    final List<String> errors = [];
    if (codEmpresa <= 0) errors.add('Código da empresa deve ser maior que zero');
    if (codSepararEstoque <= 0) errors.add('Código de separar estoque deve ser maior que zero');
    if (item.isEmpty) errors.add('Item não pode estar vazio');
    return errors;
  }

  @override
  String toString() {
    return 'DeleteItemSeparationParams(codEmpresa: $codEmpresa, codSepararEstoque: $codSepararEstoque, item: $item)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteItemSeparationParams &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.item == item;
  }

  @override
  int get hashCode {
    return codEmpresa.hashCode ^ codSepararEstoque.hashCode ^ item.hashCode;
  }
}
