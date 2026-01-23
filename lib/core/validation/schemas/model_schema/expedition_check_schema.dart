import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ExpeditionCheckSchema {
  ExpeditionCheckSchema._();

  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodConferir': CommonSchemas.integerSchema,
    'Origem': EnumSchemas.expeditionOrigemSchema,
    'CodOrigem': CommonSchemas.integerSchema,
    'CodPrioridade': CommonSchemas.integerSchema,
    'Situacao': EnumSchemas.expeditionCartRouterSituationSchema,
    'Data': CommonSchemas.dateTimeSchema,
    'Hora': CommonSchemas.nonEmptyStringSchema,
    'Historico': CommonSchemas.optionalStringSchema,
    'Observacao': CommonSchemas.optionalStringSchema,
    'CodMotivoCancelamento': CommonSchemas.optionalIntegerSchema,
    'DataCancelamento': CommonSchemas.optionalDateTimeSchema,
    'HoraCancelamento': CommonSchemas.optionalStringSchema,
    'CodUsuarioCancelamento': CommonSchemas.optionalIntegerSchema,
    'NomeUsuarioCancelamento': CommonSchemas.optionalStringSchema,
    'ObservacaoCancelamento': CommonSchemas.optionalStringSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da conferência de expedição: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
