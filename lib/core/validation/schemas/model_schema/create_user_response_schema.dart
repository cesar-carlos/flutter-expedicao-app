import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/model_schema/app_user_schema.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de CreateUserResponse
class CreateUserResponseSchema {
  CreateUserResponseSchema._();

  /// Schema para CreateUserResponse
  static final schema = z.map({
    'Success': CommonSchemas.booleanSchema,
    'Message': CommonSchemas.optionalStringSchema,
    'User': AppUserSchema.schema.optional(),
    'CodLoginApp': CommonSchemas.optionalIntegerSchema,
  });

  /// Valida dados de resposta da criação de usuário
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da resposta da criação de usuário: $e';
    }
  }

  /// Validação segura para resposta da criação de usuário
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
