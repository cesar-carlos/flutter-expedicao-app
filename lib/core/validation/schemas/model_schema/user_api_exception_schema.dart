import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class UserApiExceptionSchema {
  UserApiExceptionSchema._();

  static final schema = z.map({
    'message': CommonSchemas.nonEmptyStringSchema,
    'statusCode': CommonSchemas.optionalIntegerSchema,
    'errorCode': CommonSchemas.optionalStringSchema,
    'details': CommonSchemas.optionalStringSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da exceção da API: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
