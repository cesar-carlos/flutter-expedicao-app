import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/model_schema/app_user_schema.dart';
import 'package:data7_expedicao/core/results/index.dart';

class LoginResponseSchema {
  LoginResponseSchema._();

  static final schema = z.map({
    'success': CommonSchemas.booleanSchema,
    'message': CommonSchemas.optionalStringSchema,
    'user': AppUserSchema.schema.optional(),
    'token': CommonSchemas.optionalStringSchema,
    'refreshToken': CommonSchemas.optionalStringSchema,
    'expiresIn': CommonSchemas.optionalIntegerSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da resposta do login: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
