import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de ApiErrorResponse
class ApiErrorResponseSchema {
  ApiErrorResponseSchema._();

  /// Schema para ApiErrorResponse
  static final schema = z.map({
    'Error': CommonSchemas.nonEmptyStringSchema,
    'Message': CommonSchemas.optionalStringSchema,
    'StatusCode': CommonSchemas.integerSchema,
    'Timestamp': CommonSchemas.optionalDateTimeSchema,
    'Path': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados de resposta de erro da API
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da resposta de erro da API: $e';
    }
  }

  /// Validação segura para resposta de erro da API
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
