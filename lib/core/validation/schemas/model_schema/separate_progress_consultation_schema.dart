import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de SeparateProgressConsultationModel
class SeparateProgressConsultationSchema {
  SeparateProgressConsultationSchema._();

  /// Schema para SeparateProgressConsultationModel
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSepararEstoque': CommonSchemas.integerSchema,
    'Origem': EnumSchemas.expeditionOrigemSchema,
    'CodOrigem': CommonSchemas.integerSchema,
    'Situacao': EnumSchemas.expeditionSituationSchema,
    'ProcessoSeparacao': CommonSchemas.nonEmptyStringSchema,
  });

  /// Valida dados de consulta de progresso de separação
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta de progresso de separação: $e';
    }
  }

  /// Validação segura para consulta de progresso de separação
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
