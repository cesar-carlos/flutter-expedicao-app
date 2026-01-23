import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/model_schema/app_user_schema.dart';
import 'package:data7_expedicao/core/results/index.dart';

class CreateUserResponseSchema {
  CreateUserResponseSchema._();

  static final schema = z.map({
    'Success': CommonSchemas.booleanSchema,
    'Message': CommonSchemas.optionalStringSchema,
    'User': AppUserSchema.schema.optional(),
    'CodLoginApp': CommonSchemas.optionalIntegerSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da resposta da criação de usuário: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
