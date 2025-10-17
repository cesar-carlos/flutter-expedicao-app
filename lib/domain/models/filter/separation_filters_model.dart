import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';

class SeparationFiltersModel {
  final String? codSepararEstoque;
  final String? origem;
  final String? codOrigem;
  final List<String>? situacoes; // Mudado de String? para List<String>?
  final DateTime? dataEmissao;
  final ExpeditionSectorStockModel? setorEstoque;

  const SeparationFiltersModel({
    this.codSepararEstoque,
    this.origem,
    this.codOrigem,
    this.situacoes,
    this.dataEmissao,
    this.setorEstoque,
  });

  factory SeparationFiltersModel.fromJson(Map<String, dynamic> json) {
    return SeparationFiltersModel(
      codSepararEstoque: json['codSepararEstoque'],
      origem: json['origem'],
      codOrigem: json['codOrigem'],
      situacoes: json['situacoes'] != null ? List<String>.from(json['situacoes']) : null,
      dataEmissao: json['dataEmissao'] != null ? DateTime.parse(json['dataEmissao']) : null,
      setorEstoque: json['setorEstoque'] != null ? ExpeditionSectorStockModel.fromJson(json['setorEstoque']) : null,
    );
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<SeparationFiltersModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => SeparationFiltersModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'codSepararEstoque': codSepararEstoque,
      'origem': origem,
      'codOrigem': codOrigem,
      'situacoes': situacoes,
      'dataEmissao': dataEmissao?.toIso8601String(),
      'setorEstoque': setorEstoque?.toJson(),
    };
  }

  bool get isEmpty =>
      codSepararEstoque == null &&
      origem == null &&
      codOrigem == null &&
      (situacoes == null || situacoes!.isEmpty) &&
      dataEmissao == null &&
      setorEstoque == null;

  bool get isNotEmpty => !isEmpty;

  SeparationFiltersModel copyWith({
    String? codSepararEstoque,
    String? origem,
    String? codOrigem,
    List<String>? situacoes,
    DateTime? dataEmissao,
    ExpeditionSectorStockModel? setorEstoque,
  }) {
    return SeparationFiltersModel(
      codSepararEstoque: codSepararEstoque ?? this.codSepararEstoque,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      situacoes: situacoes ?? this.situacoes,
      dataEmissao: dataEmissao ?? this.dataEmissao,
      setorEstoque: setorEstoque ?? this.setorEstoque,
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
        'situacoes: $situacoes, '
        'dataEmissao: $dataEmissao, '
        'setorEstoque: $setorEstoque'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparationFiltersModel &&
        other.codSepararEstoque == codSepararEstoque &&
        other.origem == origem &&
        other.codOrigem == codOrigem &&
        _listEquals(other.situacoes, situacoes) &&
        other.dataEmissao == dataEmissao &&
        other.setorEstoque == setorEstoque;
  }

  @override
  int get hashCode {
    return Object.hash(codSepararEstoque, origem, codOrigem, situacoes, dataEmissao, setorEstoque);
  }

  /// Compara duas listas para igualdade
  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
