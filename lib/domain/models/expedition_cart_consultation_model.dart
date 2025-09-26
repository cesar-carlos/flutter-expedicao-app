import 'package:exp/core/utils/app_helper.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/situation_model.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionCartConsultationModel {
  final int codEmpresa;
  final int codCarrinho;
  final String descricaoCarrinho;
  final Situation ativo;
  final ExpeditionCartSituation situacao;
  final String codigoBarras;
  final int? codCarrinhoPercurso;
  final int? codPercursoEstagio;
  final String? descricaoPercursoEstagio;
  final ExpeditionOrigem origem;
  final int? codOrigem;
  final DateTime? dataInicio;
  final String? horaInicio;
  final int? codUsuarioInicio;
  final String? nomeUsuarioInicio;
  final int? codSetorEstoque;
  final String? nomeSetorEstoque;

  ExpeditionCartConsultationModel({
    required this.codEmpresa,
    required this.codCarrinho,
    required this.descricaoCarrinho,
    required this.ativo,
    required this.situacao,
    required this.codigoBarras,
    this.codCarrinhoPercurso,
    this.codPercursoEstagio,
    this.descricaoPercursoEstagio,
    this.origem = ExpeditionOrigem.vazio,
    this.codOrigem,
    this.dataInicio,
    this.horaInicio,
    this.codUsuarioInicio,
    this.nomeUsuarioInicio,
    this.codSetorEstoque,
    this.nomeSetorEstoque,
  });

  factory ExpeditionCartConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionCartConsultationModel(
        codEmpresa: json['CodEmpresa'],
        codCarrinho: json['CodCarrinho'],
        descricaoCarrinho: json['Descricao'],
        ativo: Situation.fromCodeWithFallback(json['Ativo'] as String? ?? ''),
        situacao: ExpeditionCartSituation.fromCode(json['Situacao'] as String? ?? '') ?? ExpeditionCartSituation.vazio,
        codigoBarras: json['CodigoBarras'],
        codCarrinhoPercurso: json['CodCarrinhoPercurso'],
        codPercursoEstagio: json['CodPercursoEstagio'],
        descricaoPercursoEstagio: json['DescricaoPercursoEstagio'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem'] as String? ?? ''),
        codOrigem: json['CodOrigem'],
        dataInicio: AppHelper.tryStringToDateOrNull(json['DataInicio']),
        horaInicio: json['HoraInicio'],
        codUsuarioInicio: json['CodUsuarioInicio'],
        nomeUsuarioInicio: json['NomeUsuarioInicio'],
        codSetorEstoque: json['CodSetorEstoque'],
        nomeSetorEstoque: json['NomeSetorEstoque'],
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCartConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCartConsultationModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodCarrinho': codCarrinho,
      'Descricao': descricaoCarrinho,
      'Ativo': ativo.code,
      'Situacao': situacao.code,
      'CodigoBarras': codigoBarras,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'CodPercursoEstagio': codPercursoEstagio,
      'DescricaoPercursoEstagio': descricaoPercursoEstagio,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'DataInicio': dataInicio?.toIso8601String(),
      'HoraInicio': horaInicio,
      'CodUsuarioInicio': codUsuarioInicio,
      'NomeUsuarioInicio': nomeUsuarioInicio,
      'CodSetorEstoque': codSetorEstoque,
      'NomeSetorEstoque': nomeSetorEstoque,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCartConsultationModel &&
        other.codEmpresa == codEmpresa &&
        other.codCarrinho == codCarrinho;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codCarrinho.hashCode;

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

  @override
  String toString() {
    return '''
      ExpeditionCartConsultationModel(
        codEmpresa: $codEmpresa, 
        codCarrinho: $codCarrinho, 
        descricaoCarrinho: $descricaoCarrinho, 
        ativo: ${ativo.description}, 
        situacao: ${situacao.description}, 
        codigoBarras: $codigoBarras, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        codPercursoEstagio: $codPercursoEstagio, 
        descricaoPercursoEstagio: $descricaoPercursoEstagio, 
        origem: ${origem.description}, 
        codOrigem: $codOrigem, 
        dataInicio: $dataInicio, 
        horaInicio: $horaInicio, 
        codUsuarioInicio: $codUsuarioInicio, 
        nomeUsuarioInicio: $nomeUsuarioInicio, 
        codSetorEstoque: $codSetorEstoque, 
        nomeSetorEstoque: $nomeSetorEstoque
    )''';
  }
}
