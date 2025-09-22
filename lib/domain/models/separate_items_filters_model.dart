class SeparateItemsFiltersModel {
  final String? codProduto;
  final String? codigoBarras;
  final String? nomeProduto;
  final String? enderecoDescricao;
  final double? quantidadeMinima;
  final double? quantidadeMaxima;
  final double? quantidadeSeparacaoMinima;
  final double? quantidadeSeparacaoMaxima;

  const SeparateItemsFiltersModel({
    this.codProduto,
    this.codigoBarras,
    this.nomeProduto,
    this.enderecoDescricao,
    this.quantidadeMinima,
    this.quantidadeMaxima,
    this.quantidadeSeparacaoMinima,
    this.quantidadeSeparacaoMaxima,
  });

  factory SeparateItemsFiltersModel.fromJson(Map<String, dynamic> json) {
    return SeparateItemsFiltersModel(
      codProduto: json['codProduto'],
      codigoBarras: json['codigoBarras'],
      nomeProduto: json['nomeProduto'],
      enderecoDescricao: json['enderecoDescricao'],
      quantidadeMinima: json['quantidadeMinima']?.toDouble(),
      quantidadeMaxima: json['quantidadeMaxima']?.toDouble(),
      quantidadeSeparacaoMinima: json['quantidadeSeparacaoMinima']?.toDouble(),
      quantidadeSeparacaoMaxima: json['quantidadeSeparacaoMaxima']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codProduto': codProduto,
      'codigoBarras': codigoBarras,
      'nomeProduto': nomeProduto,
      'enderecoDescricao': enderecoDescricao,
      'quantidadeMinima': quantidadeMinima,
      'quantidadeMaxima': quantidadeMaxima,
      'quantidadeSeparacaoMinima': quantidadeSeparacaoMinima,
      'quantidadeSeparacaoMaxima': quantidadeSeparacaoMaxima,
    };
  }

  bool get isEmpty =>
      codProduto == null &&
      codigoBarras == null &&
      nomeProduto == null &&
      enderecoDescricao == null &&
      quantidadeMinima == null &&
      quantidadeMaxima == null &&
      quantidadeSeparacaoMinima == null &&
      quantidadeSeparacaoMaxima == null;

  bool get isNotEmpty => !isEmpty;

  SeparateItemsFiltersModel copyWith({
    String? codProduto,
    String? codigoBarras,
    String? nomeProduto,
    String? enderecoDescricao,
    double? quantidadeMinima,
    double? quantidadeMaxima,
    double? quantidadeSeparacaoMinima,
    double? quantidadeSeparacaoMaxima,
  }) {
    return SeparateItemsFiltersModel(
      codProduto: codProduto ?? this.codProduto,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nomeProduto: nomeProduto ?? this.nomeProduto,
      enderecoDescricao: enderecoDescricao ?? this.enderecoDescricao,
      quantidadeMinima: quantidadeMinima ?? this.quantidadeMinima,
      quantidadeMaxima: quantidadeMaxima ?? this.quantidadeMaxima,
      quantidadeSeparacaoMinima: quantidadeSeparacaoMinima ?? this.quantidadeSeparacaoMinima,
      quantidadeSeparacaoMaxima: quantidadeSeparacaoMaxima ?? this.quantidadeSeparacaoMaxima,
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
        'enderecoDescricao: $enderecoDescricao, '
        'quantidadeMinima: $quantidadeMinima, '
        'quantidadeMaxima: $quantidadeMaxima, '
        'quantidadeSeparacaoMinima: $quantidadeSeparacaoMinima, '
        'quantidadeSeparacaoMaxima: $quantidadeSeparacaoMaxima'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparateItemsFiltersModel &&
        other.codProduto == codProduto &&
        other.codigoBarras == codigoBarras &&
        other.nomeProduto == nomeProduto &&
        other.enderecoDescricao == enderecoDescricao &&
        other.quantidadeMinima == quantidadeMinima &&
        other.quantidadeMaxima == quantidadeMaxima &&
        other.quantidadeSeparacaoMinima == quantidadeSeparacaoMinima &&
        other.quantidadeSeparacaoMaxima == quantidadeSeparacaoMaxima;
  }

  @override
  int get hashCode {
    return Object.hash(
      codProduto,
      codigoBarras,
      nomeProduto,
      enderecoDescricao,
      quantidadeMinima,
      quantidadeMaxima,
      quantidadeSeparacaoMinima,
      quantidadeSeparacaoMaxima,
    );
  }
}
