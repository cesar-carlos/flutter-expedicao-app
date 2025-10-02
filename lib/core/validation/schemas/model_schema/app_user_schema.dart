import 'package:zard/zard.dart';

import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de AppUser
class AppUserSchema {
  AppUserSchema._();

  /// Schema para AppUser
  static final schema = z.map({
    'CodLoginApp': CommonSchemas.integerSchema,
    'Ativo': EnumSchemas.activeStatusSchema,
    'Nome': CommonSchemas.nonEmptyStringSchema,
    'CodUsuario': CommonSchemas.optionalIntegerSchema,
    'FotoUsuario': CommonSchemas.optionalStringSchema,
    'Senha': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados do usuário da aplicação
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do usuário: $e';
    }
  }

  /// Validação segura para usuário da aplicação
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
