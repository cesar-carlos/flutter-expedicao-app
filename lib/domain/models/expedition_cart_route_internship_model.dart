import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ExpeditionCartRouteInternshipModel {
  final int codEmpresa;
  final int codCarrinhoPercurso;
  final String item;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final int codPercursoEstagio;
  final int codCarrinho;
  final ExpeditionSituation situacao;
  final DateTime dataInicio;
  final String horaInicio;
  final int codUsuarioInicio;
  final String nomeUsuarioInicio;
  final DateTime? dataFinalizacao;
  final String? horaFinalizacao;
  final int? codUsuarioFinalizacao;
  final String? nomeUsuarioFinalizacao;

  ExpeditionCartRouteInternshipModel({
    required this.codEmpresa,
    required this.codCarrinhoPercurso,
    required this.item,
    required this.origem,
    required this.codOrigem,
    required this.codPercursoEstagio,
    required this.codCarrinho,
    required this.situacao,
    required this.dataInicio,
    required this.horaInicio,
    required this.codUsuarioInicio,
    required this.nomeUsuarioInicio,
    this.dataFinalizacao,
    this.horaFinalizacao,
    this.codUsuarioFinalizacao,
    this.nomeUsuarioFinalizacao,
  });

  ExpeditionCartRouteInternshipModel copyWith({
    int? codEmpresa,
    int? codCarrinhoPercurso,
    String? item,
    ExpeditionOrigem? origem,
    int? codOrigem,
    int? codPercursoEstagio,
    int? codCarrinho,
    ExpeditionSituation? situacao,
    DateTime? dataInicio,
    String? horaInicio,
    int? codUsuarioInicio,
    String? nomeUsuarioInicio,
    DateTime? dataFinalizacao,
    String? horaFinalizacao,
    int? codUsuarioFinalizacao,
    String? nomeUsuarioFinalizacao,
  }) {
    return ExpeditionCartRouteInternshipModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      item: item ?? this.item,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      codPercursoEstagio: codPercursoEstagio ?? this.codPercursoEstagio,
      codCarrinho: codCarrinho ?? this.codCarrinho,
      situacao: situacao ?? this.situacao,
      dataInicio: dataInicio ?? this.dataInicio,
      horaInicio: horaInicio ?? this.horaInicio,
      codUsuarioInicio: codUsuarioInicio ?? this.codUsuarioInicio,
      nomeUsuarioInicio: nomeUsuarioInicio ?? this.nomeUsuarioInicio,
      dataFinalizacao: dataFinalizacao ?? this.dataFinalizacao,
      horaFinalizacao: horaFinalizacao ?? this.horaFinalizacao,
      codUsuarioFinalizacao: codUsuarioFinalizacao ?? this.codUsuarioFinalizacao,
      nomeUsuarioFinalizacao: nomeUsuarioFinalizacao ?? this.nomeUsuarioFinalizacao,
    );
  }

  factory ExpeditionCartRouteInternshipModel.fromJson(Map<String, dynamic> json) {
    // Refatorado para usar JsonParse helpers (parsing defensivo).
    // Bug critico anterior: `DateTime.parse(json['DataInicio'])` SEM
    // try/catch crashava se a string viesse mal formatada — propagava
    // FormatException para o caller. Agora usa parseDateTimeOr com
    // fallback para epoch 0 (data claramente invalida que outras
    // camadas podem detectar).
    return ExpeditionCartRouteInternshipModel(
      codEmpresa: JsonParse.parseIntOr(json['CodEmpresa'], 0),
      codCarrinhoPercurso: JsonParse.parseIntOr(json['CodCarrinhoPercurso'], 0),
      item: JsonParse.parseStringOr(json['Item'], ''),
      origem: ExpeditionOrigem.fromCodeWithFallback(JsonParse.parseStringOr(json['Origem'], '')),
      codOrigem: JsonParse.parseIntOr(json['CodOrigem'], 0),
      codPercursoEstagio: JsonParse.parseIntOr(json['CodPercursoEstagio'], 0),
      codCarrinho: JsonParse.parseIntOr(json['CodCarrinho'], 0),
      situacao: ExpeditionSituation.fromCode(JsonParse.parseStringOr(json['Situacao'], '')) ??
          ExpeditionSituation.naoLocalizada,
      dataInicio: JsonParse.parseDateTimeOr(json['DataInicio'], DateTime.fromMillisecondsSinceEpoch(0)),
      horaInicio: JsonParse.parseStringOr(json['HoraInicio'], '00:00:00'),
      codUsuarioInicio: JsonParse.parseIntOr(json['CodUsuarioInicio'], 0),
      nomeUsuarioInicio: JsonParse.parseStringOr(json['NomeUsuarioInicio'], ''),
      dataFinalizacao: AppHelper.tryStringToDateOrNull(json['DataFinalizacao']),
      horaFinalizacao: JsonParse.parseStringOrNull(json['HoraFinalizacao']),
      codUsuarioFinalizacao: JsonParse.parseInt(json['CodUsuarioFinalizacao']),
      nomeUsuarioFinalizacao: JsonParse.parseStringOrNull(json['NomeUsuarioFinalizacao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'Item': item,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'CodPercursoEstagio': codPercursoEstagio,
      'CodCarrinho': codCarrinho,
      'Situacao': situacao.code,
      'DataInicio': dataInicio.toIso8601String(),
      'HoraInicio': horaInicio,
      'CodUsuarioInicio': codUsuarioInicio,
      'NomeUsuarioInicio': nomeUsuarioInicio,
      'DataFinalizacao': dataFinalizacao?.toIso8601String(),
      'HoraFinalizacao': horaFinalizacao,
      'CodUsuarioFinalizacao': codUsuarioFinalizacao,
      'NomeUsuarioFinalizacao': nomeUsuarioFinalizacao,
    };
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCartRouteInternshipModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCartRouteInternshipModel.fromJson(json));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCartRouteInternshipModel &&
        other.codEmpresa == codEmpresa &&
        other.codCarrinhoPercurso == codCarrinhoPercurso &&
        other.item == item;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codCarrinhoPercurso.hashCode ^ item.hashCode;

  /// Retorna o código da situação
  String get situacaoCode => situacao.code;

  /// Retorna a descrição da situação
  String get situacaoDescription => situacao.description;

  /// Retorna o código da origem
  String get origemCode => origem.code;

  /// Retorna a descrição da origem
  String get origemDescription => origem.description;

  @override
  String toString() {
    return '''
      ExpedicaoPercursoEstagioModel(
        codEmpresa: $codEmpresa, 
        odCarrinhoPercurso: $codCarrinhoPercurso, 
        item: $item, 
        origem: ${origem.description}, 
        codOrigem: $codOrigem, 
        codPercursoEstagio: $codPercursoEstagio, 
        codCarrinho: $codCarrinho, 
        situacao: ${situacao.description}, 
        dataInicio: $dataInicio, 
        horaInicio: $horaInicio, 
        codUsuarioInicio: $codUsuarioInicio, 
        nomeUsuarioInicio: $nomeUsuarioInicio, 
        dataFinalizacao: $dataFinalizacao, 
        horaFinalizacao: $horaFinalizacao, 
        codUsuarioFinalizacao: $codUsuarioFinalizacao, 
        nomeUsuarioFinalizacao: $nomeUsuarioFinalizacao
    )''';
  }
}
