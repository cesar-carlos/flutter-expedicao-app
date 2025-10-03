import 'package:zard/zard.dart';

import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de ExpeditionCancellationModel
class ExpeditionCancellationSchema {
  ExpeditionCancellationSchema._();

  /// Schema para ExpeditionCancellationModel
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodCancelamento': CommonSchemas.integerSchema,
    'Origem': EnumSchemas.expeditionOrigemSchema,
    'CodOrigem': CommonSchemas.integerSchema,
    'ItemOrigem': CommonSchemas.nonEmptyStringSchema,
    'CodMotivoCancelamento': CommonSchemas.optionalIntegerSchema,
    'DataCancelamento': CommonSchemas.dateTimeSchema,
    'HoraCancelamento': CommonSchemas.nonEmptyStringSchema,
    'CodUsuarioCancelamento': CommonSchemas.integerSchema,
    'NomeUsuarioCancelamento': CommonSchemas.nonEmptyStringSchema,
    'ObservacaoCancelamento': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados de cancelamento de expedição
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do cancelamento: $e';
    }
  }

  /// Validação segura para cancelamento
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
