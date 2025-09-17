import 'package:exp/core/utils/date_helper.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/domain/models/entity_type_model.dart';

/// Modelo para consulta de separação de expedição
class SeparateConsultationModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final int codTipoOperacaoExpedicao;
  final String nomeTipoOperacaoExpedicao;
  final ExpeditionSituation situacao;
  final EntityType tipoEntidade;
  final DateTime dataEmissao;
  final String horaEmissao;
  final int codEntidade;
  final String nomeEntidade;
  final int codPrioridade;
  final String nomePrioridade;
  final String? historico;
  final String? observacao;

  const SeparateConsultationModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.origem,
    required this.codOrigem,
    required this.codTipoOperacaoExpedicao,
    required this.nomeTipoOperacaoExpedicao,
    required this.situacao,
    required this.tipoEntidade,
    required this.dataEmissao,
    required this.horaEmissao,
    required this.codEntidade,
    required this.nomeEntidade,
    required this.codPrioridade,
    required this.nomePrioridade,
    this.historico,
    this.observacao,
  });

  factory SeparateConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return SeparateConsultationModel(
        codEmpresa: json['CodEmpresa'] ?? 0,
        codSepararEstoque: json['CodSepararEstoque'] ?? 0,
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem'] as String),
        codOrigem: json['CodOrigem'] ?? 0,
        codTipoOperacaoExpedicao: json['CodTipoOperacaoExpedicao'] ?? 0,
        nomeTipoOperacaoExpedicao: json['NomeTipoOperacaoExpedicao'] ?? '',
        situacao: ExpeditionSituation.fromCode(json['Situacao'] as String? ?? '') ?? ExpeditionSituation.aguardando,
        tipoEntidade: EntityType.fromCode(json['TipoEntidade'] as String? ?? '') ?? EntityType.cliente,
        dataEmissao: DateHelper.tryStringToDate(json['DataEmissao']),
        horaEmissao: json['HoraEmissao'] ?? '',
        codEntidade: json['CodEntidade'] ?? 0,
        nomeEntidade: json['NomeEntidade'] ?? '',
        codPrioridade: json['CodPrioridade'] ?? 0,
        nomePrioridade: json['NomePrioridade'] ?? '',
        historico: json['Historico'],
        observacao: json['Observacao'],
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'CodTipoOperacaoExpedicao': codTipoOperacaoExpedicao,
      'NomeTipoOperacaoExpedicao': nomeTipoOperacaoExpedicao,
      'Situacao': situacao.code,
      'TipoEntidade': tipoEntidade.code,
      'DataEmissao': dataEmissao.toIso8601String(),
      'HoraEmissao': horaEmissao,
      'CodEntidade': codEntidade,
      'NomeEntidade': nomeEntidade,
      'CodPrioridade': codPrioridade,
      'NomePrioridade': nomePrioridade,
      'Historico': historico,
      'Observacao': observacao,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparateConsultationModel &&
        other.codSepararEstoque == codSepararEstoque &&
        other.codEmpresa == codEmpresa;
  }

  @override
  int get hashCode => codSepararEstoque.hashCode ^ codEmpresa.hashCode;

  /// Retorna o código do tipo de entidade
  String get tipoEntidadeCode => tipoEntidade.code;

  /// Retorna a descrição do tipo de entidade
  String get tipoEntidadeDescription => tipoEntidade.description;

  @override
  String toString() {
    return 'SeparateConsultationModel(codSepararEstoque: $codSepararEstoque, origem: ${origem.description}, situacao: ${situacao.description}, tipoEntidade: ${tipoEntidade.description}, nomeEntidade: $nomeEntidade)';
  }
}
