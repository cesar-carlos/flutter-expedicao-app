import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class UserPreferencesSchema {
  UserPreferencesSchema._();

  static final schema = z.map({
    'theme': z.string().optional(),
    'language': z.string().optional(),
    'notifications': CommonSchemas.optionalBooleanSchema,
    'autoLogin': CommonSchemas.optionalBooleanSchema,
    'biometricAuth': CommonSchemas.optionalBooleanSchema,
    'apiUrl': CommonSchemas.optionalStringSchema,
    'apiPort': CommonSchemas.optionalStringSchema,
    'useHttps': CommonSchemas.optionalBooleanSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação das preferências: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
