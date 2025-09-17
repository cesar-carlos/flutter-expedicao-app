import 'package:zard/zard.dart';
import 'common_schemas.dart';
import 'enum_schemas.dart';

/// Schemas para validação de models de usuário
class UserSchemas {
  UserSchemas._();

  // === APP USER ===

  /// Schema para AppUser
  static final appUserSchema = z.map({
    'codLoginApp': CommonSchemas.idSchema,
    'ativo': EnumSchemas.activeStatusSchema,
    'nome': CommonSchemas.nonEmptyStringSchema,
    'codUsuario': CommonSchemas.optionalIdSchema,
    'fotoUsuario': CommonSchemas.optionalStringSchema,
    'senha': CommonSchemas.optionalStringSchema,
  });

  // === APP USER CONSULTATION ===

  /// Schema para AppUserConsultation
  static final appUserConsultationSchema = z.map({
    'codLoginApp': CommonSchemas.idSchema,
    'ativo': EnumSchemas.activeStatusSchema,
    'nome': CommonSchemas.nonEmptyStringSchema,
    'codUsuario': CommonSchemas.optionalIdSchema,
    'nomeUsuario': CommonSchemas.optionalStringSchema,
    'fotoUsuario': CommonSchemas.optionalStringSchema,
    'email': CommonSchemas.optionalStringSchema,
    'telefone': CommonSchemas.optionalStringSchema,
    'dataCriacao': CommonSchemas.optionalDateTimeSchema,
    'dataUltimoAcesso': CommonSchemas.optionalDateTimeSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === LOGIN REQUEST ===

  /// Schema para LoginRequest
  static final loginRequestSchema = z.map({
    'username': z.string().min(1, message: 'Usuário é obrigatório').transform((value) => value.trim()),
    'password': z
        .string()
        .min(1, message: 'Senha é obrigatória')
        .min(4, message: 'Senha deve ter pelo menos 4 caracteres')
        .max(60, message: 'Senha deve ter no máximo 60 caracteres'),
  });

  // === LOGIN RESPONSE ===

  /// Schema para LoginResponse
  static final loginResponseSchema = z.map({
    'success': CommonSchemas.booleanSchema,
    'message': CommonSchemas.optionalStringSchema,
    'user': appUserSchema.optional(),
    'token': CommonSchemas.optionalStringSchema,
    'refreshToken': CommonSchemas.optionalStringSchema,
    'expiresIn': CommonSchemas.optionalIdSchema,
  });

  // === CREATE USER REQUEST ===

  /// Schema para CreateUserRequest
  static final createUserRequestSchema = z.map({
    'nome': z
        .string()
        .min(1, message: 'Nome é obrigatório')
        .transform((value) => value.trim())
        .refine((value) => value.length <= 100, message: 'Nome deve ter no máximo 100 caracteres'),
    'username': z
        .string()
        .min(1, message: 'Usuário é obrigatório')
        .transform((value) => value.trim())
        .refine((value) => value.length <= 50, message: 'Usuário deve ter no máximo 50 caracteres'),
    'password': z
        .string()
        .min(4, message: 'Senha deve ter pelo menos 4 caracteres')
        .max(60, message: 'Senha deve ter no máximo 60 caracteres'),
    'email': z
        .string()
        .optional()
        .refine((value) {
          if (value.trim().isEmpty) return true;
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          return emailRegex.hasMatch(value.trim());
        }, message: 'Email deve ter formato válido')
        .transform((value) => value.trim()),
    'telefone': CommonSchemas.optionalStringSchema,
    'fotoUsuario': CommonSchemas.optionalStringSchema,
  });

  // === CREATE USER RESPONSE ===

  /// Schema para CreateUserResponse
  static final createUserResponseSchema = z.map({
    'success': CommonSchemas.booleanSchema,
    'message': CommonSchemas.optionalStringSchema,
    'user': appUserSchema.optional(),
    'codLoginApp': CommonSchemas.optionalIdSchema,
  });

  // === USER API EXCEPTION ===

  /// Schema para UserApiException
  static final userApiExceptionSchema = z.map({
    'message': CommonSchemas.nonEmptyStringSchema,
    'statusCode': CommonSchemas.optionalIdSchema,
    'errorCode': CommonSchemas.optionalStringSchema,
    'details': CommonSchemas.optionalStringSchema,
  });

  // === API ERROR RESPONSE ===

  /// Schema para ApiErrorResponse
  static final apiErrorResponseSchema = z.map({
    'error': CommonSchemas.nonEmptyStringSchema,
    'message': CommonSchemas.optionalStringSchema,
    'statusCode': CommonSchemas.idSchema,
    'timestamp': CommonSchemas.optionalDateTimeSchema,
    'path': CommonSchemas.optionalStringSchema,
  });

  // === USER PREFERENCES ===

  /// Schema para UserPreferences
  static final userPreferencesSchema = z.map({
    'theme': z.string().optional(),
    'language': z.string().optional(),
    'notifications': CommonSchemas.optionalBooleanSchema,
    'autoLogin': CommonSchemas.optionalBooleanSchema,
    'biometricAuth': CommonSchemas.optionalBooleanSchema,
    'apiUrl': CommonSchemas.optionalStringSchema,
    'apiPort': CommonSchemas.optionalStringSchema,
    'useHttps': CommonSchemas.optionalBooleanSchema,
  });

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

  /// Valida dados de login
  static Map<String, dynamic> validateLogin(Map<String, dynamic> data) {
    try {
      return loginRequestSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do login: $e';
    }
  }

  /// Valida dados de criação de usuário
  static Map<String, dynamic> validateCreateUser(Map<String, dynamic> data) {
    try {
      return createUserRequestSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação da criação de usuário: $e';
    }
  }

  /// Valida dados do usuário da aplicação
  static Map<String, dynamic> validateAppUser(Map<String, dynamic> data) {
    try {
      return appUserSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do usuário: $e';
    }
  }

  /// Valida preferências do usuário
  static Map<String, dynamic> validateUserPreferences(Map<String, dynamic> data) {
    try {
      return userPreferencesSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação das preferências: $e';
    }
  }

  // === VALIDAÇÃO SEGURA ===

  /// Validação segura para login
  static ({bool success, Map<String, dynamic>? data, String? error}) safeValidateLogin(Map<String, dynamic> data) {
    try {
      final result = loginRequestSchema.parse(data);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

  /// Validação segura para criação de usuário
  static ({bool success, Map<String, dynamic>? data, String? error}) safeValidateCreateUser(Map<String, dynamic> data) {
    try {
      final result = createUserRequestSchema.parse(data);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

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
