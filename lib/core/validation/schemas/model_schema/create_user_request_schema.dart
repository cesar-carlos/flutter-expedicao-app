import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class CreateUserRequestSchema {
  CreateUserRequestSchema._();

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
          // Bug latente anterior: regex `[\w-]{2,4}` no final do TLD
          // rejeitava dominios validos com TLD > 4 chars (.travel,
          // .museum, .tech, .design) ou multi-segmento (.com.br).
          // Mesmo bug ja foi corrigido em UserValidators.isValidEmail
          // — aqui aplicamos a mesma regex consolidada.
          final emailRegex = RegExp(r'^[\w.\-]+@[\w\-]+(\.[\w\-]+)*\.[a-zA-Z]{2,24}$');
          return emailRegex.hasMatch(value.trim());
        }, message: 'Email deve ter formato válido')
        .transform((value) => value.trim()),
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
