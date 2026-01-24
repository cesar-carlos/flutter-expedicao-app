import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ApiErrorResponseSchema {
  ApiErrorResponseSchema._();

  static final schema = z.map({
    'Error': CommonSchemas.nonEmptyStringSchema,
    'Message': CommonSchemas.optionalStringSchema,
    'StatusCode': CommonSchemas.integerSchema,
    'Timestamp': CommonSchemas.optionalDateTimeSchema,
    'Path': CommonSchemas.optionalStringSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da resposta de erro da API: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
