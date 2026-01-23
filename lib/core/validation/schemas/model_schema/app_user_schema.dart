import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class AppUserSchema {
  AppUserSchema._();

  static final schema = z.map({
    'CodLoginApp': CommonSchemas.integerSchema,
    'Ativo': EnumSchemas.activeStatusSchema,
    'Nome': CommonSchemas.nonEmptyStringSchema,
    'CodUsuario': CommonSchemas.optionalIntegerSchema,
    'FotoUsuario': CommonSchemas.optionalStringSchema,
    'Senha': CommonSchemas.optionalStringSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do usuário: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
