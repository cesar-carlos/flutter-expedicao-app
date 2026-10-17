import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class CreateUserRequestSchema {
  CreateUserRequestSchema._();

  static final schema = z.map({
    'Nome': z
        .string()
        .min(1, message: 'Nome é obrigatório')
        .refine((value) => value.trim().length <= 100, message: 'Nome deve ter no máximo 100 caracteres')
        .transform((value) => value.trim()),
    'Username': z
        .string()
        .min(1, message: 'Usuário é obrigatório')
        .refine((value) => value.trim().length <= 50, message: 'Usuário deve ter no máximo 50 caracteres')
        .transform((value) => value.trim()),
    'Password': z
        .string()
        .min(4, message: 'Senha deve ter pelo menos 4 caracteres')
        .max(60, message: 'Senha deve ter no máximo 60 caracteres'),
    'Email': z
        .string()
        .refine((value) {
          final trimmed = value.trim();
          if (trimmed.isEmpty) return true;
          final emailRegex = RegExp(r'^[\w.\-]+@[\w\-]+(\.[\w\-]+)*\.[a-zA-Z]{2,24}$');
          return emailRegex.hasMatch(trimmed);
        }, message: 'Email deve ter formato válido')
        .transform((value) {
          final trimmed = value.trim();
          return trimmed.isEmpty ? null : trimmed;
        })
        .optional(),
    'Telefone': CommonSchemas.optionalStringSchema,
    'FotoUsuario': CommonSchemas.optionalStringSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da criação de usuário: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
