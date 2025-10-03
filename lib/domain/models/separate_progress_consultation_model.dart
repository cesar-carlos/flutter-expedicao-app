import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/situation/expedition_situation_model.dart';
import 'package:exp/core/results/index.dart';

/// Modelo para consulta de separação de expedição
class SeparateProgressConsultationModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final ExpeditionSituation situacao;
  final ExpeditionSituation processoSeparacao;

  const SeparateProgressConsultationModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.origem,
    required this.codOrigem,
    required this.situacao,
    required this.processoSeparacao,
  });

  factory SeparateProgressConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return SeparateProgressConsultationModel(
        codEmpresa: json['CodEmpresa'] ?? 0,
        codSepararEstoque: json['CodSepararEstoque'] ?? 0,
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem'] as String),
        codOrigem: json['CodOrigem'] ?? 0,
        situacao: ExpeditionSituation.fromCode(json['Situacao'] as String? ?? '') ?? ExpeditionSituation.aguardando,
        processoSeparacao:
            ExpeditionSituation.fromCode(json['ProcessoSeparacao'] as String? ?? '') ?? ExpeditionSituation.aguardando,
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
      'Situacao': situacao.code,
      'ProcessoSeparacao': processoSeparacao.code,
    };
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<SeparateProgressConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => SeparateProgressConsultationModel.fromJson(json));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparateProgressConsultationModel &&
        other.codSepararEstoque == codSepararEstoque &&
        other.codEmpresa == codEmpresa;
  }

  @override
  int get hashCode => codSepararEstoque.hashCode ^ codEmpresa.hashCode;

  @override
  String toString() {
    return 'SeparateProgressConsultationModel(codSepararEstoque: $codSepararEstoque, origem: ${origem.description}, situacao: ${situacao.description}, processoSeparacao: $processoSeparacao)';
  }
}
