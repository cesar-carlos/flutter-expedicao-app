import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_router_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ExpeditionCartRouteInternshipGroupConsultationModel {
  final int codEmpresa;
  final int codCarrinhoPercurso;
  final String? itemAgrupamento;
  final String itemCarrinhoPercurso;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final ExpeditionCartRouterSituation situacao;
  final ExpeditionSituation situacaoPercurso;
  final int? codPercursoEstagio;
  final String? descricaoPercursoEstagio;
  final int? codCarrinhoAgrupador;
  final int codCarrinho;
  final String nomeCarrinho;
  final String codigoBarrasCarrinho;
  final Situation carrinhoAgrupador;
  final String? nomeCarrinhoAgrupador;
  final DateTime dataInicio;
  final String horaInicio;
  final int codUsuarioInicio;
  final String nomeUsuarioInicio;

  ExpeditionCartRouteInternshipGroupConsultationModel({
    required this.codEmpresa,
    required this.codCarrinhoPercurso,
    this.itemAgrupamento,
    required this.itemCarrinhoPercurso,
    required this.origem,
    required this.codOrigem,
    required this.situacao,
    required this.situacaoPercurso,
    this.codPercursoEstagio,
    this.descricaoPercursoEstagio,
    this.codCarrinhoAgrupador,
    this.nomeCarrinhoAgrupador,
    required this.codCarrinho,
    required this.nomeCarrinho,
    required this.codigoBarrasCarrinho,
    this.carrinhoAgrupador = Situation.inativo,
    required this.dataInicio,
    required this.horaInicio,
    required this.codUsuarioInicio,
    required this.nomeUsuarioInicio,
  });

  ExpeditionCartRouteInternshipGroupConsultationModel copyWith({
    int? codEmpresa,
    int? codCarrinhoPercurso,
    String? itemAgrupamento,
    String? itemCarrinhoPercurso,
    ExpeditionOrigem? origem,
    int? codOrigem,
    ExpeditionCartRouterSituation? situacao,
    ExpeditionSituation? situacaoPercurso,
    int? codPercursoEstagio,
    String? descricaoPercursoEstagio,
    int? codCarrinhoAgrupador,
    String? nomeCarrinhoAgrupador,
    int? codCarrinho,
    String? nomeCarrinho,
    String? codigoBarrasCarrinho,
    Situation? carrinhoAgrupador,
    DateTime? dataInicio,
    String? horaInicio,
    int? codUsuarioInicio,
    String? nomeUsuarioInicio,
  }) {
    return ExpeditionCartRouteInternshipGroupConsultationModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      itemAgrupamento: itemAgrupamento ?? this.itemAgrupamento,
      itemCarrinhoPercurso: itemCarrinhoPercurso ?? this.itemCarrinhoPercurso,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      situacao: situacao ?? this.situacao,
      situacaoPercurso: situacaoPercurso ?? this.situacaoPercurso,
      codPercursoEstagio: codPercursoEstagio ?? this.codPercursoEstagio,
      descricaoPercursoEstagio: descricaoPercursoEstagio ?? this.descricaoPercursoEstagio,
      codCarrinhoAgrupador: codCarrinhoAgrupador ?? this.codCarrinhoAgrupador,
      nomeCarrinhoAgrupador: nomeCarrinhoAgrupador ?? this.nomeCarrinhoAgrupador,
      codCarrinho: codCarrinho ?? this.codCarrinho,
      nomeCarrinho: nomeCarrinho ?? this.nomeCarrinho,
      codigoBarrasCarrinho: codigoBarrasCarrinho ?? this.codigoBarrasCarrinho,
      carrinhoAgrupador: carrinhoAgrupador ?? this.carrinhoAgrupador,
      dataInicio: dataInicio ?? this.dataInicio,
      horaInicio: horaInicio ?? this.horaInicio,
      codUsuarioInicio: codUsuarioInicio ?? this.codUsuarioInicio,
      nomeUsuarioInicio: nomeUsuarioInicio ?? this.nomeUsuarioInicio,
    );
  }

  factory ExpeditionCartRouteInternshipGroupConsultationModel.fromJson(Map<String, dynamic> json) {
    // Bug critico: `DateTime.parse(json['DataInicio'])` sem try/catch
    // crashava com FormatException em datas malformadas.
    final carrinhoAgrupRaw = json['CarrinhoAgrupador'];
    return ExpeditionCartRouteInternshipGroupConsultationModel(
      codEmpresa: JsonParse.parseIntOr(json['CodEmpresa'], 0),
      codCarrinhoPercurso: JsonParse.parseIntOr(json['CodCarrinhoPercurso'], 0),
      itemAgrupamento: JsonParse.parseStringOrNull(json['ItemAgrupamento']),
      itemCarrinhoPercurso: JsonParse.parseStringOr(json['ItemCarrinhoPercurso'], ''),
      origem: ExpeditionOrigem.fromCodeWithFallback(JsonParse.parseStringOr(json['Origem'], '')),
      codOrigem: JsonParse.parseIntOr(json['CodOrigem'], 0),
      situacao: ExpeditionCartRouterSituation.fromCode(JsonParse.parseStringOr(json['Situacao'], '')) ??
          ExpeditionCartRouterSituation.vazio,
      situacaoPercurso: ExpeditionSituation.fromCode(JsonParse.parseStringOr(json['SituacaoPercurso'], '')) ??
          ExpeditionSituation.aguardando,
      codPercursoEstagio: JsonParse.parseInt(json['CodPercursoEstagio']),
      descricaoPercursoEstagio: JsonParse.parseStringOrNull(json['DescricaoPercursoEstagio']),
      codCarrinhoAgrupador: JsonParse.parseInt(json['CodCarrinhoAgrupador']),
      nomeCarrinhoAgrupador: JsonParse.parseStringOrNull(json['NomeCarrinhoAgrupador']),
      codCarrinho: JsonParse.parseIntOr(json['CodCarrinho'], 0),
      nomeCarrinho: JsonParse.parseStringOr(json['NomeCarrinho'], ''),
      codigoBarrasCarrinho: JsonParse.parseStringOr(json['CodigoBarrasCarrinho'], ''),
      carrinhoAgrupador:
          carrinhoAgrupRaw != null ? Situation.fromCodeWithFallback(carrinhoAgrupRaw.toString()) : Situation.inativo,
      dataInicio: JsonParse.parseDateTimeOr(json['DataInicio'], DateTime.fromMillisecondsSinceEpoch(0)),
      horaInicio: JsonParse.parseStringOr(json['HoraInicio'], '00:00:00'),
      codUsuarioInicio: JsonParse.parseIntOr(json['CodUsuarioInicio'], 0),
      nomeUsuarioInicio: JsonParse.parseStringOr(json['NomeUsuarioInicio'], ''),
    );
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCartRouteInternshipGroupConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCartRouteInternshipGroupConsultationModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'ItemAgrupamento': itemAgrupamento,
      'ItemCarrinhoPercurso': itemCarrinhoPercurso,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'Situacao': situacao.code,
      'SituacaoPercurso': situacaoPercurso.code,
      'CodPercursoEstagio': codPercursoEstagio,
      'DescricaoPercursoEstagio': descricaoPercursoEstagio,
      'CodCarrinhoAgrupador': codCarrinhoAgrupador,
      'NomeCarrinhoAgrupador': nomeCarrinhoAgrupador,
      'CodCarrinho': codCarrinho,
      'NomeCarrinho': nomeCarrinho,
      'CodigoBarrasCarrinho': codigoBarrasCarrinho,
      'CarrinhoAgrupador': carrinhoAgrupador.code,
      'DataInicio': dataInicio.toIso8601String(),
      'HoraInicio': horaInicio,
      'CodUsuarioInicio': codUsuarioInicio,
      'NomeUsuarioInicio': nomeUsuarioInicio,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCartRouteInternshipGroupConsultationModel &&
        other.codEmpresa == codEmpresa &&
        other.codCarrinhoPercurso == codCarrinhoPercurso &&
        itemAgrupamento == other.itemAgrupamento &&
        itemCarrinhoPercurso == other.itemCarrinhoPercurso;
  }

  @override
  int get hashCode =>
      codEmpresa.hashCode ^ codCarrinhoPercurso.hashCode ^ itemAgrupamento.hashCode ^ itemCarrinhoPercurso.hashCode;

  @override
  String toString() {
    return '''
      ExpeditionCartRouteInternshipGroupConsultationModel(
        codEmpresa: $codEmpresa, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        itemCarrinhoPercurso: $itemCarrinhoPercurso, 
        itemAgrupamento: $itemAgrupamento, 
        origem: ${origem.description} (${origem.code}), 
        codOrigem: $codOrigem,
        situacao: ${situacao.description} (${situacao.code}), 
        situacaoPercurso: ${situacaoPercurso.description} (${situacaoPercurso.code}),
        codCarrinhoAgrupador: $codCarrinhoAgrupador, 
        nomeCarrinhoAgrupador: $nomeCarrinhoAgrupador, 
        codCarrinho: $codCarrinho, 
        nomeCarrinho: $nomeCarrinho, 
        codigoBarrasCarrinho: $codigoBarrasCarrinho,
        carrinhoAgrupador: ${carrinhoAgrupador.code} (${carrinhoAgrupador.description}),
        dataInicio: $dataInicio, 
        horaInicio: $horaInicio, 
        codUsuarioInicio: $codUsuarioInicio, 
        nomeUsuarioInicio: $nomeUsuarioInicio
    )''';
  }
}
