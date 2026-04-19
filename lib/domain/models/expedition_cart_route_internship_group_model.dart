import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ExpeditionCartRouteInternshipGroupModel {
  final int codEmpresa;
  final int codCarrinhoPercurso;
  final String item;
  final ExpeditionOrigem origem;
  final String itemCarrinhoPercurso;
  final ExpeditionCartSituation situacao;
  final int codCarrinhoAgrupador;
  final DateTime dataLancamento;
  final String horaLancamento;
  final int codUsuarioLancamento;
  final String nomeUsuarioLancamento;

  ExpeditionCartRouteInternshipGroupModel({
    required this.codEmpresa,
    required this.codCarrinhoPercurso,
    required this.item,
    required this.origem,
    required this.itemCarrinhoPercurso,
    required this.situacao,
    required this.codCarrinhoAgrupador,
    required this.dataLancamento,
    required this.horaLancamento,
    required this.codUsuarioLancamento,
    required this.nomeUsuarioLancamento,
  });

  ExpeditionCartRouteInternshipGroupModel copyWith({
    int? codEmpresa,
    int? codCarrinhoPercurso,
    String? item,
    ExpeditionOrigem? origem,
    String? itemCarrinhoPercurso,
    ExpeditionCartSituation? situacao,
    int? codCarrinhoAgrupador,
    DateTime? dataLancamento,
    String? horaLancamento,
    int? codUsuarioLancamento,
    String? nomeUsuarioLancamento,
  }) {
    return ExpeditionCartRouteInternshipGroupModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      item: item ?? this.item,
      origem: origem ?? this.origem,
      itemCarrinhoPercurso: itemCarrinhoPercurso ?? this.itemCarrinhoPercurso,
      situacao: situacao ?? this.situacao,
      codCarrinhoAgrupador: codCarrinhoAgrupador ?? this.codCarrinhoAgrupador,
      dataLancamento: dataLancamento ?? this.dataLancamento,
      horaLancamento: horaLancamento ?? this.horaLancamento,
      codUsuarioLancamento: codUsuarioLancamento ?? this.codUsuarioLancamento,
      nomeUsuarioLancamento: nomeUsuarioLancamento ?? this.nomeUsuarioLancamento,
    );
  }

  factory ExpeditionCartRouteInternshipGroupModel.fromJson(Map<String, dynamic> json) {
    // Bug critico: `DateTime.parse(json['DataLancamento'])` sem
    // try/catch crashava com FormatException em datas malformadas.
    // Agora usa parseDateTimeOr com fallback epoch 0.
    return ExpeditionCartRouteInternshipGroupModel(
      codEmpresa: JsonParse.parseIntOr(json['CodEmpresa'], 0),
      codCarrinhoPercurso: JsonParse.parseIntOr(json['CodCarrinhoPercurso'], 0),
      item: JsonParse.parseStringOr(json['Item'], ''),
      origem: ExpeditionOrigem.fromCodeWithFallback(JsonParse.parseStringOr(json['Origem'], '')),
      itemCarrinhoPercurso: JsonParse.parseStringOr(json['ItemCarrinhoPercurso'], ''),
      situacao: ExpeditionCartSituation.fromCode(JsonParse.parseStringOr(json['Situacao'], '')) ??
          ExpeditionCartSituation.vazio,
      codCarrinhoAgrupador: JsonParse.parseIntOr(json['CodCarrinhoAgrupador'], 0),
      dataLancamento: JsonParse.parseDateTimeOr(json['DataLancamento'], DateTime.fromMillisecondsSinceEpoch(0)),
      horaLancamento: JsonParse.parseStringOr(json['HoraLancamento'], '00:00:00'),
      codUsuarioLancamento: JsonParse.parseIntOr(json['CodUsuarioLancamento'], 0),
      nomeUsuarioLancamento: JsonParse.parseStringOr(json['NomeUsuarioLancamento'], ''),
    );
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCartRouteInternshipGroupModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCartRouteInternshipGroupModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'Item': item,
      'Origem': origem.code,
      'ItemCarrinhoPercurso': itemCarrinhoPercurso,
      'Situacao': situacao.code,
      'CodCarrinhoAgrupador': codCarrinhoAgrupador,
      'DataLancamento': dataLancamento.toIso8601String(),
      'HoraLancamento': horaLancamento,
      'CodUsuarioLancamento': codUsuarioLancamento,
      'NomeUsuarioLancamento': nomeUsuarioLancamento,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCartRouteInternshipGroupModel &&
        other.codEmpresa == codEmpresa &&
        other.codCarrinhoPercurso == codCarrinhoPercurso &&
        other.item == item;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codCarrinhoPercurso.hashCode ^ item.hashCode;

  @override
  String toString() {
    return '''
      ExpeditionCartRouteInternshipGroupModel(
        codEmpresa: $codEmpresa, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        item: $item, 
        origem: ${origem.description} (${origem.code}),
        itemCarrinhoPercurso: $itemCarrinhoPercurso, 
        situacao: ${situacao.description} (${situacao.code}), 
        codCarrinhoAgrupador: $codCarrinhoAgrupador, 
        dataLancamento: $dataLancamento, 
        horaLancamento: $horaLancamento, 
        codUsuarioLancamento: $codUsuarioLancamento, 
        nomeUsuarioLancamento: $nomeUsuarioLancamento)
    )''';
  }
}
