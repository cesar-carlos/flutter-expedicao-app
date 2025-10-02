import 'package:zard/zard.dart';

import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/validation/schemas/model_schema/index.dart';
import 'package:exp/core/results/index.dart';

/// Schemas para validação de models de usuário
///
/// Esta classe mantém compatibilidade com o código existente,
/// mas agora delega para os schemas individuais na pasta model/
class UserValidators {
  UserValidators._();

  // === SCHEMAS DE VALIDAÇÃO DE SENHA ===

  /// Schema para senha forte
  static final strongPasswordSchema = z
      .string()
      .min(8, message: 'Senha deve ter pelo menos 8 caracteres')
      .refine(
        (value) => RegExp(r'(?=.*[a-z])').hasMatch(value),
        message: 'Senha deve conter pelo menos uma letra minúscula',
      )
      .refine(
        (value) => RegExp(r'(?=.*[A-Z])').hasMatch(value),
        message: 'Senha deve conter pelo menos uma letra maiúscula',
      )
      .refine((value) => RegExp(r'(?=.*\d)').hasMatch(value), message: 'Senha deve conter pelo menos um número')
      .refine(
        (value) => RegExp(r'(?=.*[^\da-zA-Z])').hasMatch(value),
        message: 'Senha deve conter pelo menos um caractere especial',
      );

  /// Schema para confirmação de senha
  static confirmPasswordSchema(String originalPassword) {
    return z
        .map({
          'password': z.string(),
          'confirmPassword': z.string().min(1, message: 'Confirmação de senha é obrigatória'),
        })
        .refine((data) {
          return data['confirmPassword'] == originalPassword;
        }, message: 'As senhas não coincidem');
  }

  // === MÉTODOS DE VALIDAÇÃO ===
  // Delegam para os schemas individuais para manter compatibilidade

  /// Valida dados de login
  static Map<String, dynamic> validateLogin(Map<String, dynamic> data) => LoginRequestSchema.validate(data);

  /// Valida dados de criação de usuário
  static Map<String, dynamic> validateCreateUser(Map<String, dynamic> data) => CreateUserRequestSchema.validate(data);

  /// Valida dados do usuário da aplicação
  static Map<String, dynamic> validateAppUser(Map<String, dynamic> data) => AppUserSchema.validate(data);

  /// Valida preferências do usuário
  static Map<String, dynamic> validateUserPreferences(Map<String, dynamic> data) =>
      UserPreferencesSchema.validate(data);

  // === VALIDAÇÃO SEGURA ===
  // Delegam para os schemas individuais para manter compatibilidade

  /// Validação segura para login
  static Result<Map<String, dynamic>> safeValidateLogin(Map<String, dynamic> data) =>
      LoginRequestSchema.safeValidate(data);

  /// Validação segura para criação de usuário
  static Result<Map<String, dynamic>> safeValidateCreateUser(Map<String, dynamic> data) =>
      CreateUserRequestSchema.safeValidate(data);

  // === VALIDAÇÕES ESPECÍFICAS ===

  /// Valida se o usuário está ativo
  static bool isUserActive(String activeStatus) {
    return EnumSchemas.activeStatusToBool(activeStatus);
  }

  /// Valida se o email é válido
  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return true; // Opcional
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Valida se o telefone é válido
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return true; // Opcional
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 10 && cleanPhone.length <= 11;
  }

  /// Valida força da senha
  static ({bool isStrong, List<String> issues}) validatePasswordStrength(String password) {
    final issues = <String>[];

    if (password.length < 8) {
      issues.add('Deve ter pelo menos 8 caracteres');
    }

    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      issues.add('Deve conter pelo menos uma letra minúscula');
    }

    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      issues.add('Deve conter pelo menos uma letra maiúscula');
    }

    if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
      issues.add('Deve conter pelo menos um número');
    }

    if (!RegExp(r'(?=.*[^\da-zA-Z])').hasMatch(password)) {
      issues.add('Deve conter pelo menos um caractere especial');
    }

    return (isStrong: issues.isEmpty, issues: issues);
  }
}
