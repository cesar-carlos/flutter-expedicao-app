import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/expedition_item_situation_model.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionCartRouteInternshipGroupConsultationModel {
  final int codEmpresa;
  final int codCarrinhoPercurso;
  final String? itemAgrupamento;
  final String itemCarrinhoPercurso;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final ExpeditionItemSituation situacao;
  final ExpeditionSituation situacaoPercurso;
  final int? codPercursoEstagio;
  final String? descricaoPercursoEstagio;
  final int? codCarrinhoAgrupador;
  final int codCarrinho;
  final String nomeCarrinho;
  final String codigoBarrasCarrinho;
  final String carrinhoAgrupador;
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
    required this.carrinhoAgrupador,
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
    ExpeditionItemSituation? situacao,
    ExpeditionSituation? situacaoPercurso,
    int? codPercursoEstagio,
    String? descricaoPercursoEstagio,
    int? codCarrinhoAgrupador,
    String? nomeCarrinhoAgrupador,
    int? codCarrinho,
    String? nomeCarrinho,
    String? codigoBarrasCarrinho,
    String? carrinhoAgrupador,
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
    try {
      return ExpeditionCartRouteInternshipGroupConsultationModel(
        codEmpresa: json['CodEmpresa'],
        codCarrinhoPercurso: json['CodCarrinhoPercurso'],
        itemAgrupamento: json['ItemAgrupamento'],
        itemCarrinhoPercurso: json['ItemCarrinhoPercurso'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem']),
        codOrigem: json['CodOrigem'],
        situacao: ExpeditionItemSituation.fromCode(json['Situacao']) ?? ExpeditionItemSituation.vazio,
        situacaoPercurso: ExpeditionSituation.fromCode(json['SituacaoPercurso']) ?? ExpeditionSituation.aguardando,
        codPercursoEstagio: json['CodPercursoEstagio'],
        descricaoPercursoEstagio: json['DescricaoPercursoEstagio'],
        codCarrinhoAgrupador: json['CodCarrinhoAgrupador'],
        nomeCarrinhoAgrupador: json['NomeCarrinhoAgrupador'],
        codCarrinho: json['CodCarrinho'],
        nomeCarrinho: json['NomeCarrinho'],
        codigoBarrasCarrinho: json['CodigoBarrasCarrinho'],
        carrinhoAgrupador: json['CarrinhoAgrupador'],
        dataInicio: DateTime.parse(json['DataInicio']),
        horaInicio: json['HoraInicio'],
        codUsuarioInicio: json['CodUsuarioInicio'],
        nomeUsuarioInicio: json['NomeUsuarioInicio'],
      );
    } catch (_) {
      rethrow;
    }
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
      'CarrinhoAgrupador': carrinhoAgrupador,
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
        carrinhoAgrupador: $carrinhoAgrupador,
        dataInicio: $dataInicio, 
        horaInicio: $horaInicio, 
        codUsuarioInicio: $codUsuarioInicio, 
        nomeUsuarioInicio: $nomeUsuarioInicio
    )''';
  }
}
