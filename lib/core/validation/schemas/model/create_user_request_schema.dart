import 'package:zard/zard.dart';

import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de CreateUserRequest
class CreateUserRequestSchema {
  CreateUserRequestSchema._();

  /// Schema para CreateUserRequest
  static final schema = z.map({
    'Nome': z
        .string()
        .min(1, message: 'Nome é obrigatório')
        .transform((value) => value.trim())
        .refine((value) => value.length <= 100, message: 'Nome deve ter no máximo 100 caracteres'),
    'Username': z
        .string()
        .min(1, message: 'Usuário é obrigatório')
        .transform((value) => value.trim())
        .refine((value) => value.length <= 50, message: 'Usuário deve ter no máximo 50 caracteres'),
    'Password': z
        .string()
        .min(4, message: 'Senha deve ter pelo menos 4 caracteres')
        .max(60, message: 'Senha deve ter no máximo 60 caracteres'),
    'Email': z
        .string()
        .optional()
        .refine((value) {
          if (value.trim().isEmpty) return true;
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          return emailRegex.hasMatch(value.trim());
        }, message: 'Email deve ter formato válido')
        .transform((value) => value.trim()),
    'Telefone': CommonSchemas.optionalStringSchema,
    'FotoUsuario': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados de criação de usuário
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da criação de usuário: $e';
    }
  }

  /// Validação segura para criação de usuário
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
