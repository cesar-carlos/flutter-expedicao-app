import 'package:zard/zard.dart';
import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de ExpeditionCheckConsultationModel
class ExpeditionCheckConsultationSchema {
  ExpeditionCheckConsultationSchema._();

  /// Schema para ExpeditionCheckConsultationModel
  /// Baseado nos campos reais do modelo
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodConferir': CommonSchemas.integerSchema,
    'Origem': EnumSchemas.expeditionOrigemSchema,
    'CodOrigem': CommonSchemas.integerSchema,
    'Situacao': EnumSchemas.expeditionCartRouterSituationSchema,
    'CodCarrinhoPercurso': CommonSchemas.integerSchema,
    'DataLancamento': CommonSchemas.dateTimeSchema,
    'HoraLancamento': CommonSchemas.nonEmptyStringSchema,
    'TipoEntidade': EnumSchemas.entityTypeSchema,
    'CodEntidade': CommonSchemas.integerSchema,
    'NomeEntidade': CommonSchemas.nonEmptyStringSchema,
    'CodPrioridade': CommonSchemas.integerSchema,
    'NomePrioridade': CommonSchemas.nonEmptyStringSchema,
    'Historico': CommonSchemas.optionalStringSchema,
    'Observacao': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados de consulta de conferência de expedição
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta de conferência de expedição: $e';
    }
  }

  /// Validação segura para consulta de conferência de expedição
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
