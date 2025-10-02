import 'package:exp/core/utils/app_helper.dart';
import 'package:exp/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionCartRouteModel {
  final int codEmpresa;
  final int codCarrinhoPercurso;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final ExpeditionCartSituation situacao;
  final DateTime dataInicio;
  final String horaInicio;
  final DateTime? dataFinalizacao;
  final String? horaFinalizacao;

  ExpeditionCartRouteModel({
    required this.codEmpresa,
    required this.codCarrinhoPercurso,
    required this.origem,
    required this.codOrigem,
    required this.situacao,
    required this.dataInicio,
    required this.horaInicio,
    this.dataFinalizacao,
    this.horaFinalizacao,
  });

  ExpeditionCartRouteModel copyWith({
    int? codEmpresa,
    int? codCarrinhoPercurso,
    ExpeditionOrigem? origem,
    int? codOrigem,
    ExpeditionCartSituation? situacao,
    DateTime? dataInicio,
    String? horaInicio,
    DateTime? dataFinalizacao,
    String? horaFinalizacao,
  }) {
    return ExpeditionCartRouteModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      situacao: situacao ?? this.situacao,
      dataInicio: dataInicio ?? this.dataInicio,
      horaInicio: horaInicio ?? this.horaInicio,
      dataFinalizacao: dataFinalizacao ?? this.dataFinalizacao,
      horaFinalizacao: horaFinalizacao ?? this.horaFinalizacao,
    );
  }

  factory ExpeditionCartRouteModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionCartRouteModel(
        codEmpresa: json['CodEmpresa'],
        codCarrinhoPercurso: json['CodCarrinhoPercurso'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem'] as String? ?? ''),
        codOrigem: json['CodOrigem'],
        situacao: ExpeditionCartSituation.fromCode(json['Situacao']) ?? ExpeditionCartSituation.vazio,
        dataInicio: AppHelper.tryStringToDate(json['DataInicio']),
        horaInicio: json['HoraInicio'] ?? '00:00:00',
        dataFinalizacao: AppHelper.tryStringToDateOrNull(json['DataFinalizacao']),
        horaFinalizacao: json['HoraFinalizacao'],
      );
    } catch (_) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'Situacao': situacao.code,
      'DataInicio': dataInicio.toIso8601String(),
      'HoraInicio': horaInicio,
      'DataFinalizacao': dataFinalizacao?.toIso8601String(),
      'HoraFinalizacao': horaFinalizacao,
    };
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCartRouteModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCartRouteModel.fromJson(json));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCartRouteModel &&
        other.codEmpresa == codEmpresa &&
        other.codCarrinhoPercurso == codCarrinhoPercurso;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codCarrinhoPercurso.hashCode;

  /// Retorna o código da origem
  String get origemCode => origem.code;

  /// Retorna a descrição da origem
  String get origemDescription => origem.description;

  @override
  String toString() {
    return '''
      ExpeditionRouteModel(
        codEmpresa: $codEmpresa, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        origem: ${origem.description}, 
        codOrigem: $codOrigem, 
        situacao: ${situacao.description}, 
        dataInicio: $dataInicio, 
        horaInicio: $horaInicio, 
        dataFinalizacao: $dataFinalizacao, 
        horaFinalizacao: $horaFinalizacao
    )''';
  }
}
