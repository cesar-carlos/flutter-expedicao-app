import 'package:zard/zard.dart';

import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de UserPreferences
class UserPreferencesSchema {
  UserPreferencesSchema._();

  /// Schema para UserPreferences
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

  /// Valida preferências do usuário
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação das preferências: $e';
    }
  }

  /// Validação segura para preferências do usuário
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
