import 'package:exp/core/utils/app_helper.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/situation_model.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionCartRouteInternshipConsultationModel {
  final int codEmpresa;
  final int codCarrinhoPercurso;
  final String item;
  final int codPercursoEstagio;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final ExpeditionSituation situacao;
  final Situation carrinhoAgrupador;
  final int? codCarrinhoAgrupador;
  final int codCarrinho;
  final String nomeCarrinho;
  final String codigoBarrasCarrinho;
  final Situation ativo;
  final int codUsuarioInicio;
  final String nomeUsuarioInicio;
  final DateTime dataInicio;
  final String horaInicio;
  final int? codUsuarioFinalizacao;
  final String? nomeUsuarioFinalizacao;
  final DateTime? dataFinalizacao;
  final String? horaFinalizacao;
  final int? codSetorEstoque;
  final String? nomeSetorEstoque;

  ExpeditionCartRouteInternshipConsultationModel({
    required this.codEmpresa,
    required this.codCarrinhoPercurso,
    required this.item,
    required this.codPercursoEstagio,
    required this.origem,
    required this.codOrigem,
    required this.situacao,
    required this.carrinhoAgrupador,
    this.codCarrinhoAgrupador,
    required this.codCarrinho,
    required this.nomeCarrinho,
    required this.codigoBarrasCarrinho,
    required this.ativo,
    required this.codUsuarioInicio,
    required this.nomeUsuarioInicio,
    required this.dataInicio,
    required this.horaInicio,
    this.codUsuarioFinalizacao,
    this.nomeUsuarioFinalizacao,
    this.dataFinalizacao,
    this.horaFinalizacao,
    this.codSetorEstoque,
    this.nomeSetorEstoque,
  });

  ExpeditionCartRouteInternshipConsultationModel copyWith({
    int? codEmpresa,
    int? codCarrinhoPercurso,
    String? item,
    int? codPercursoEstagio,
    ExpeditionOrigem? origem,
    int? codOrigem,
    ExpeditionSituation? situacao,
    Situation? carrinhoAgrupador,
    int? codCarrinhoAgrupador,
    int? codCarrinho,
    String? nomeCarrinho,
    String? codigoBarrasCarrinho,
    Situation? ativo,
    int? codUsuarioInicio,
    String? nomeUsuarioInicio,
    DateTime? dataInicio,
    String? horaInicio,
    int? codUsuarioFinalizacao,
    String? nomeUsuarioFinalizacao,
    DateTime? dataFinalizacao,
    String? horaFinalizacao,
    int? codSetorEstoque,
    String? nomeSetorEstoque,
  }) {
    return ExpeditionCartRouteInternshipConsultationModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      item: item ?? this.item,
      codPercursoEstagio: codPercursoEstagio ?? this.codPercursoEstagio,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      situacao: situacao ?? this.situacao,
      carrinhoAgrupador: carrinhoAgrupador ?? this.carrinhoAgrupador,
      codCarrinhoAgrupador: codCarrinhoAgrupador ?? this.codCarrinhoAgrupador,
      codCarrinho: codCarrinho ?? this.codCarrinho,
      nomeCarrinho: nomeCarrinho ?? this.nomeCarrinho,
      codigoBarrasCarrinho: codigoBarrasCarrinho ?? this.codigoBarrasCarrinho,
      ativo: ativo ?? this.ativo,
      codUsuarioInicio: codUsuarioInicio ?? this.codUsuarioInicio,
      nomeUsuarioInicio: nomeUsuarioInicio ?? this.nomeUsuarioInicio,
      dataInicio: dataInicio ?? this.dataInicio,
      horaInicio: horaInicio ?? this.horaInicio,
      codUsuarioFinalizacao: codUsuarioFinalizacao ?? this.codUsuarioFinalizacao,
      nomeUsuarioFinalizacao: nomeUsuarioFinalizacao ?? this.nomeUsuarioFinalizacao,
      dataFinalizacao: dataFinalizacao ?? this.dataFinalizacao,
      horaFinalizacao: horaFinalizacao ?? this.horaFinalizacao,
      codSetorEstoque: codSetorEstoque ?? this.codSetorEstoque,
      nomeSetorEstoque: nomeSetorEstoque ?? this.nomeSetorEstoque,
    );
  }

  factory ExpeditionCartRouteInternshipConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionCartRouteInternshipConsultationModel(
        codEmpresa: json['CodEmpresa'],
        codCarrinhoPercurso: json['CodCarrinhoPercurso'],
        item: json['Item'],
        codPercursoEstagio: json['CodPercursoEstagio'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem'] as String? ?? ''),
        codOrigem: json['CodOrigem'],
        situacao: ExpeditionSituation.fromCode(json['Situacao'] as String? ?? '') ?? ExpeditionSituation.aguardando,
        carrinhoAgrupador: Situation.fromCodeWithFallback(json['CarrinhoAgrupador'] as String? ?? ''),
        codCarrinhoAgrupador: json['CodCarrinhoAgrupador'],
        codCarrinho: json['CodCarrinho'],
        nomeCarrinho: json['NomeCarrinho'],
        codigoBarrasCarrinho: json['CodigoBarrasCarrinho'],
        ativo: Situation.fromCodeWithFallback(json['Ativo'] as String? ?? ''),
        codUsuarioInicio: json['CodUsuarioInicio'],
        nomeUsuarioInicio: json['NomeUsuarioInicio'],
        dataInicio: AppHelper.tryStringToDate(json['DataInicio']),
        horaInicio: json['HoraInicio'] ?? '00:00:00',
        codUsuarioFinalizacao: json['CodUsuarioFinalizacao'],
        nomeUsuarioFinalizacao: json['NomeUsuarioFinalizacao'],
        dataFinalizacao: AppHelper.tryStringToDateOrNull(json['DataFinalizacao']),
        horaFinalizacao: json['HoraFinalizacao'],
        codSetorEstoque: json['CodSetorEstoque'],
        nomeSetorEstoque: json['NomeSetorEstoque'],
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCartRouteInternshipConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCartRouteInternshipConsultationModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'Item': item,
      'CodPercursoEstagio': codPercursoEstagio,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'Situacao': situacao.code,
      'CarrinhoAgrupador': carrinhoAgrupador.code,
      'CodCarrinhoAgrupador': codCarrinhoAgrupador,
      'CodCarrinho': codCarrinho,
      'NomeCarrinho': nomeCarrinho,
      'CodigoBarrasCarrinho': codigoBarrasCarrinho,
      'Ativo': ativo.code,
      'CodUsuarioInicio': codUsuarioInicio,
      'NomeUsuarioInicio': nomeUsuarioInicio,
      'DataInicio': dataInicio.toIso8601String(),
      'HoraInicio': horaInicio,
      'CodUsuarioFinalizacao': codUsuarioFinalizacao,
      'NomeUsuarioFinalizacao': nomeUsuarioFinalizacao,
      'DataFinalizacao': dataFinalizacao?.toIso8601String(),
      'HoraFinalizacao': horaFinalizacao,
      'CodSetorEstoque': codSetorEstoque,
      'NomeSetorEstoque': nomeSetorEstoque,
    };
  }

  /// Retorna o código da situação
  String get situacaoCode => situacao.code;

  /// Retorna a descrição da situação
  String get situacaoDescription => situacao.description;

  /// Retorna o código do status ativo
  String get ativoCode => ativo.code;

  /// Retorna a descrição do status ativo
  String get ativoDescription => ativo.description;

  /// Retorna o código da origem
  String get origemCode => origem.code;

  /// Retorna a descrição da origem
  String get origemDescription => origem.description;

  /// Retorna o código do carrinho agrupador
  String get carrinhoAgrupadorCode => carrinhoAgrupador.code;

  /// Retorna a descrição do carrinho agrupador
  String get carrinhoAgrupadorDescription => carrinhoAgrupador.description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCartRouteInternshipConsultationModel &&
        other.codEmpresa == codEmpresa &&
        other.codCarrinhoPercurso == codCarrinhoPercurso &&
        other.item == item;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codCarrinhoPercurso.hashCode ^ item.hashCode;

  @override
  String toString() {
    return '''
      ExpedicaoCarrinhoPercursoConsultaModel(
        codEmpresa: $codEmpresa, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        item: $item, 
        codPercursoEstagio: $codPercursoEstagio, 
        origem: ${origem.description}, 
        codOrigem: $codOrigem, 
        situacao: ${situacao.description}, 
        carrinhoAgrupador: ${carrinhoAgrupador.description},
        codCarrinhoAgrupador: $codCarrinhoAgrupador,
        codCarrinho: $codCarrinho, 
        nomeCarrinho: $nomeCarrinho, 
        codigoBarrasCarrinho: $codigoBarrasCarrinho, 
        ativo: ${ativo.description}, 
        codUsuarioInicio: $codUsuarioInicio, 
        nomeUsuarioInicio: $nomeUsuarioInicio, 
        dataInicio: $dataInicio, 
        horaInicio: $horaInicio, 
        codUsuarioFinalizacao: $codUsuarioFinalizacao,
        nomeUsuarioFinalizacao: $nomeUsuarioFinalizacao,
        dataFinalizacao: $dataFinalizacao, 
        horaFinalizacao: $horaFinalizacao, 
        codSetorEstoque: $codSetorEstoque, 
        nomeSetorEstoque: $nomeSetorEstoque
    )''';
  }
}
