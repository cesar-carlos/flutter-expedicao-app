import 'package:exp/core/constants/app_strings.dart';

/// Classe utilitária com validadores comuns para formulários
class FormValidators {
  // Construtor privado para evitar instanciação
  FormValidators._();

  /// Validador para campo de usuário
  /// Verifica se o campo não está vazio ou contém apenas espaços
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.usernameRequired;
    }
    return null;
  }

  /// Validador para campo de senha
  /// Verifica se a senha não está vazia e tem pelo menos 4 caracteres
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 4) {
      return AppStrings.passwordMinLength;
    }
    if (value.length > 60) {
      return AppStrings.passwordMaxLength;
    }
    return null;
  }

  /// Validador para campo de nome
  /// Verifica se o nome não está vazio e tem no máximo 30 caracteres
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    if (value.trim().length > 30) {
      return AppStrings.nameMaxLength;
    }
    return null;
  }

  /// Validador para confirmação de senha
  /// Verifica se a confirmação coincide com a senha original
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }
    if (value != originalPassword) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }

  /// Validador para URL da API
  /// Verifica se a URL não está vazia
  static String? apiUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.urlRequired;
    }
    return null;
  }

  /// Validador para porta da API
  /// Verifica se a porta é um número válido entre 1 e 65535
  static String? apiPort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.portRequired;
    }
    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) {
      return AppStrings.portInvalid;
    }
    return null;
  }

  /// Validador para email
  /// Verifica se o email tem formato válido
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, digite um email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Por favor, digite um email válido';
    }
    return null;
  }

  /// Validador para campos obrigatórios genéricos
  /// Pode ser usado para qualquer campo que não pode estar vazio
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, digite ${fieldName ?? 'este campo'}';
    }
    return null;
  }

  /// Validador para campo numérico
  /// Verifica se o valor é um número válido
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, digite ${fieldName ?? 'um número'}';
    }
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Este campo'} deve ser um número válido';
    }
    return null;
  }

  /// Validador para tamanho mínimo de texto
  /// Verifica se o texto tem pelo menos o tamanho mínimo especificado
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite ${fieldName ?? 'este campo'}';
    }
    if (value.length < minLength) {
      return '${fieldName ?? 'Este campo'} deve ter pelo menos $minLength caracteres';
    }
    return null;
  }

  /// Validador para tamanho máximo de texto
  /// Verifica se o texto não excede o tamanho máximo especificado
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Este campo'} deve ter no máximo $maxLength caracteres';
    }
    return null;
  }

  /// Validador combinado para senha com critérios específicos
  /// Verifica tamanho mínimo e pode incluir outros critérios
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 4) {
      return AppStrings.passwordMinLength;
    }
    // Pode adicionar mais critérios aqui (maiúscula, minúscula, números, etc.)
    return null;
  }
}
