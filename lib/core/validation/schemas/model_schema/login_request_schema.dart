import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/results/index.dart';

class LoginRequestSchema {
  LoginRequestSchema._();

  static final schema = z.map({
    'username': z.string().min(1, message: 'Usuário é obrigatório').transform((value) => value.trim()),
    'password': z
        .string()
        .min(1, message: 'Senha é obrigatória')
        .min(4, message: 'Senha deve ter pelo menos 4 caracteres')
        .max(60, message: 'Senha deve ter no máximo 60 caracteres'),
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do login: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
