import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de SeparateConsultationModel
class SeparateConsultationSchema {
  SeparateConsultationSchema._();

  /// Schema para SeparateConsultationModel
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSepararEstoque': CommonSchemas.integerSchema,
    'Origem': EnumSchemas.expeditionOrigemSchema,
    'CodOrigem': CommonSchemas.integerSchema,
    'CodTipoOperacaoExpedicao': CommonSchemas.integerSchema,
    'NomeTipoOperacaoExpedicao': CommonSchemas.nonEmptyStringSchema,
    'Situacao': EnumSchemas.expeditionSituationSchema,
    'TipoEntidade': EnumSchemas.entityTypeSchema,
    'DataEmissao': CommonSchemas.dateTimeSchema,
    'HoraEmissao': CommonSchemas.nonEmptyStringSchema,
    'CodEntidade': CommonSchemas.integerSchema,
    'NomeEntidade': CommonSchemas.nonEmptyStringSchema,
    'CodPrioridade': CommonSchemas.integerSchema,
    'NomePrioridade': CommonSchemas.nonEmptyStringSchema,
    'Historico': CommonSchemas.optionalStringSchema,
    'Observacao': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados de consulta de separação
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta de separação: $e';
    }
  }

  /// Validação segura para consulta de separação
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
