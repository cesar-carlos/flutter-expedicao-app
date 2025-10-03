import 'package:zard/zard.dart';

import 'package:exp/core/results/index.dart';

/// Schema para validação de LoginRequest
class LoginRequestSchema {
  LoginRequestSchema._();

  /// Schema para LoginRequest
  static final schema = z.map({
    'username': z.string().min(1, message: 'Usuário é obrigatório').transform((value) => value.trim()),
    'password': z
        .string()
        .min(1, message: 'Senha é obrigatória')
        .min(4, message: 'Senha deve ter pelo menos 4 caracteres')
        .max(60, message: 'Senha deve ter no máximo 60 caracteres'),
  });

  /// Valida dados de login
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do login: $e';
    }
  }

  /// Validação segura para login
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
