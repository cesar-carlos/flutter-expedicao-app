import 'package:data7_expedicao/core/utils/date_helper.dart';
import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/core/results/index.dart';

class SeparationUserSectorModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final String item;
  final int codSetorEstoque;
  final DateTime dataLancamento;
  final String horaLancamento;
  final int codUsuario;
  final String nomeUsuario;
  final String estacaoSeparacao;

  const SeparationUserSectorModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.item,
    required this.codSetorEstoque,
    required this.dataLancamento,
    required this.horaLancamento,
    required this.codUsuario,
    required this.nomeUsuario,
    required this.estacaoSeparacao,
  });

  SeparationUserSectorModel copyWith({
    int? codEmpresa,
    int? codSepararEstoque,
    String? item,
    int? codSetorEstoque,
    DateTime? dataLancamento,
    String? horaLancamento,
    int? codUsuario,
    String? nomeUsuario,
    String? estacaoSeparacao,
  }) {
    return SeparationUserSectorModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codSepararEstoque: codSepararEstoque ?? this.codSepararEstoque,
      item: item ?? this.item,
      codSetorEstoque: codSetorEstoque ?? this.codSetorEstoque,
      dataLancamento: dataLancamento ?? this.dataLancamento,
      horaLancamento: horaLancamento ?? this.horaLancamento,
      codUsuario: codUsuario ?? this.codUsuario,
      nomeUsuario: nomeUsuario ?? this.nomeUsuario,
      estacaoSeparacao: estacaoSeparacao ?? this.estacaoSeparacao,
    );
  }

  factory SeparationUserSectorModel.fromJson(Map<String, dynamic> json) {
    return SeparationUserSectorModel(
      codEmpresa: JsonParse.parseIntOr(json['CodEmpresa'], 0),
      codSepararEstoque: JsonParse.parseIntOr(json['CodSepararEstoque'], 0),
      item: JsonParse.parseStringOr(json['Item'], ''),
      codSetorEstoque: JsonParse.parseIntOr(json['CodSetorEstoque'], 0),
      dataLancamento: DateHelper.tryStringToDate(json['DataLancamento']),
      horaLancamento: JsonParse.parseStringOr(json['HoraLancamento'], '00:00:00'),
      codUsuario: JsonParse.parseIntOr(json['CodUsuario'], 0),
      nomeUsuario: JsonParse.parseStringOr(json['NomeUsuario'], ''),
      estacaoSeparacao: JsonParse.parseStringOr(json['EstacaoSeparacao'], ''),
    );
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<SeparationUserSectorModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => SeparationUserSectorModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'Item': item,
      'CodSetorEstoque': codSetorEstoque,
      'DataLancamento': dataLancamento.toIso8601String(),
      'HoraLancamento': horaLancamento,
      'CodUsuario': codUsuario,
      'NomeUsuario': nomeUsuario,
      'EstacaoSeparacao': estacaoSeparacao,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparationUserSectorModel &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.item == item &&
        other.codSetorEstoque == codSetorEstoque;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codSepararEstoque.hashCode ^ item.hashCode ^ codSetorEstoque.hashCode;

  @override
  String toString() {
    return '''SeparationUserSectorModel(
        codEmpresa: $codEmpresa, 
        codSepararEstoque: $codSepararEstoque, 
        item: $item,
        codSetorEstoque: $codSetorEstoque,
        dataLancamento: $dataLancamento, 
        horaLancamento: $horaLancamento, 
        codUsuario: $codUsuario, 
        nomeUsuario: $nomeUsuario, 
        estacaoSeparacao: $estacaoSeparacao
)''';
  }
}
