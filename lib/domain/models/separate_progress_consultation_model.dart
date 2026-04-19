import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

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
    // Bug anterior: `json['Origem'] as String` direto crashava com
    // TypeError se viesse null. Agora usa parseStringOr.
    return SeparateProgressConsultationModel(
      codEmpresa: JsonParse.parseIntOr(json['CodEmpresa'], 0),
      codSepararEstoque: JsonParse.parseIntOr(json['CodSepararEstoque'], 0),
      origem: ExpeditionOrigem.fromCodeWithFallback(JsonParse.parseStringOr(json['Origem'], '')),
      codOrigem: JsonParse.parseIntOr(json['CodOrigem'], 0),
      situacao: ExpeditionSituation.fromCode(JsonParse.parseStringOr(json['Situacao'], '')) ??
          ExpeditionSituation.aguardando,
      processoSeparacao: ExpeditionSituation.fromCode(JsonParse.parseStringOr(json['ProcessoSeparacao'], '')) ??
          ExpeditionSituation.aguardando,
    );
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
