class SeparationFiltersModel {
  final String? codSepararEstoque;
  final String? origem;
  final String? codOrigem;
  final String? situacao;
  final DateTime? dataEmissao;

  const SeparationFiltersModel({this.codSepararEstoque, this.origem, this.codOrigem, this.situacao, this.dataEmissao});

  factory SeparationFiltersModel.fromJson(Map<String, dynamic> json) {
    return SeparationFiltersModel(
      codSepararEstoque: json['codSepararEstoque'],
      origem: json['origem'],
      codOrigem: json['codOrigem'],
      situacao: json['situacao'],
      dataEmissao: json['dataEmissao'] != null ? DateTime.parse(json['dataEmissao']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codSepararEstoque': codSepararEstoque,
      'origem': origem,
      'codOrigem': codOrigem,
      'situacao': situacao,
      'dataEmissao': dataEmissao?.toIso8601String(),
    };
  }

  bool get isEmpty =>
      codSepararEstoque == null && origem == null && codOrigem == null && situacao == null && dataEmissao == null;

  bool get isNotEmpty => !isEmpty;

  SeparationFiltersModel copyWith({
    String? codSepararEstoque,
    String? origem,
    String? codOrigem,
    String? situacao,
    DateTime? dataEmissao,
  }) {
    return SeparationFiltersModel(
      codSepararEstoque: codSepararEstoque ?? this.codSepararEstoque,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      situacao: situacao ?? this.situacao,
      dataEmissao: dataEmissao ?? this.dataEmissao,
    );
  }

  SeparationFiltersModel clear() {
    return const SeparationFiltersModel();
  }

  @override
  String toString() {
    return 'SeparationFiltersModel('
        'codSepararEstoque: $codSepararEstoque, '
        'origem: $origem, '
        'codOrigem: $codOrigem, '
        'situacao: $situacao, '
        'dataEmissao: $dataEmissao'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparationFiltersModel &&
        other.codSepararEstoque == codSepararEstoque &&
        other.origem == origem &&
        other.codOrigem == codOrigem &&
        other.situacao == situacao &&
        other.dataEmissao == dataEmissao;
  }

  @override
  int get hashCode {
    return Object.hash(codSepararEstoque, origem, codOrigem, situacao, dataEmissao);
  }
}
