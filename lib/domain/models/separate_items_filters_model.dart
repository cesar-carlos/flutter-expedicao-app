class SeparateItemsFiltersModel {
  final String? codProduto;
  final String? codigoBarras;
  final String? nomeProduto;
  final String? enderecoDescricao;

  const SeparateItemsFiltersModel({this.codProduto, this.codigoBarras, this.nomeProduto, this.enderecoDescricao});

  factory SeparateItemsFiltersModel.fromJson(Map<String, dynamic> json) {
    return SeparateItemsFiltersModel(
      codProduto: json['codProduto'],
      codigoBarras: json['codigoBarras'],
      nomeProduto: json['nomeProduto'],
      enderecoDescricao: json['enderecoDescricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codProduto': codProduto,
      'codigoBarras': codigoBarras,
      'nomeProduto': nomeProduto,
      'enderecoDescricao': enderecoDescricao,
    };
  }

  bool get isEmpty => codProduto == null && codigoBarras == null && nomeProduto == null && enderecoDescricao == null;

  bool get isNotEmpty => !isEmpty;

  SeparateItemsFiltersModel copyWith({
    String? codProduto,
    String? codigoBarras,
    String? nomeProduto,
    String? enderecoDescricao,
  }) {
    return SeparateItemsFiltersModel(
      codProduto: codProduto ?? this.codProduto,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nomeProduto: nomeProduto ?? this.nomeProduto,
      enderecoDescricao: enderecoDescricao ?? this.enderecoDescricao,
    );
  }

  SeparateItemsFiltersModel clear() {
    return const SeparateItemsFiltersModel();
  }

  @override
  String toString() {
    return 'SeparateItemsFiltersModel('
        'codProduto: $codProduto, '
        'codigoBarras: $codigoBarras, '
        'nomeProduto: $nomeProduto, '
        'enderecoDescricao: $enderecoDescricao'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparateItemsFiltersModel &&
        other.codProduto == codProduto &&
        other.codigoBarras == codigoBarras &&
        other.nomeProduto == nomeProduto &&
        other.enderecoDescricao == enderecoDescricao;
  }

  @override
  int get hashCode {
    return Object.hash(codProduto, codigoBarras, nomeProduto, enderecoDescricao);
  }
}
