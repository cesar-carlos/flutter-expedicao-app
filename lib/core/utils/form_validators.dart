import 'package:zard/zard.dart';
import 'package:exp/core/constants/app_strings.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/entity_type_model.dart';

/// Classe utilitária com validadores comuns para formulários usando Zard
/// Mantém compatibilidade com TextFormField e adiciona validação robusta
class FormValidators {
  // Construtor privado para evitar instanciação
  FormValidators._();

  // === SCHEMAS ZARD BÁSICOS ===

  /// Schema para validação de username
  static final _usernameSchema = z
      .string()
      .min(1, message: AppStrings.usernameRequired)
      .transform((value) => value.trim());

  /// Schema para validação de senha
  static final _passwordSchema = z
      .string()
      .min(1, message: AppStrings.passwordRequired)
      .min(4, message: AppStrings.passwordMinLength)
      .max(60, message: AppStrings.passwordMaxLength);

  /// Schema para validação de nome
  static final _nameSchema = z
      .string()
      .min(1, message: AppStrings.nameRequired)
      .transform((value) => value.trim())
      .refine((value) => value.length <= 30, message: AppStrings.nameMaxLength);

  /// Schema para validação de email
  static final _emailSchema = z
      .string()
      .min(1, message: 'Por favor, digite um email')
      .email(message: 'Por favor, digite um email válido')
      .transform((value) => value.trim());

  /// Schema para URL da API
  static final _apiUrlSchema = z
      .string()
      .min(1, message: AppStrings.urlRequired)
      .transform((value) => value.trim());

  /// Schema para porta da API
  static final _apiPortSchema = z
      .string()
      .min(1, message: AppStrings.portRequired)
      .transform((value) => value.trim())
      .refine((value) {
        final port = int.tryParse(value);
        return port != null && port >= 1 && port <= 65535;
      }, message: AppStrings.portInvalid);

  /// Schema para campo numérico genérico
  static Schema<String> _numericSchema({String? fieldName}) {
    return z
        .string()
        .min(1, message: 'Por favor, digite ${fieldName ?? 'um número'}')
        .transform((value) => value.trim())
        .refine(
          (value) => double.tryParse(value) != null,
          message: '${fieldName ?? 'Este campo'} deve ser um número válido',
        );
  }

  /// Schema para campo obrigatório genérico
  static Schema<String> _requiredSchema({String? fieldName}) {
    return z
        .string()
        .min(1, message: 'Por favor, digite ${fieldName ?? 'este campo'}')
        .transform((value) => value.trim());
  }

  // === SCHEMAS DE NEGÓCIO ===

  /// Schema para código de separação
  static final _codSepararEstoqueSchema = z
      .string()
      .optional()
      .transform((value) {
        if (value.trim().isEmpty) return null;
        return value.trim();
      })
      .refine((value) {
        if (value == null) return true;
        return int.tryParse(value) != null;
      }, message: 'Código deve ser numérico');

  /// Schema para origem
  static final _origemSchema = z.string().optional().refine((value) {
    if (value.isEmpty) return true;
    return ExpeditionOrigem.isValidOrigem(value);
  }, message: 'Origem inválida');

  /// Schema para situação
  static final _situacaoSchema = z.string().optional().refine((value) {
    if (value.isEmpty) return true;
    return ExpeditionSituation.isValidSituation(value);
  }, message: 'Situação inválida');

  /// Schema para tipo de entidade
  static final _tipoEntidadeSchema = z.string().refine((value) {
    return EntityType.isValidType(value);
  }, message: 'Tipo de entidade inválido (deve ser C ou F)');

  // === MÉTODOS DE VALIDAÇÃO COMPATÍVEIS COM TextFormField ===

  /// Validador para campo de usuário
  /// Verifica se o campo não está vazio ou contém apenas espaços
  static String? username(String? value) {
    try {
      _usernameSchema.parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para campo de senha
  /// Verifica se a senha não está vazia e tem pelo menos 4 caracteres
  static String? password(String? value) {
    try {
      _passwordSchema.parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para campo de nome
  /// Verifica se o nome não está vazio e tem no máximo 30 caracteres
  static String? name(String? value) {
    try {
      _nameSchema.parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para confirmação de senha
  /// Verifica se a confirmação coincide com a senha original
  static String? confirmPassword(String? value, String? originalPassword) {
    if (originalPassword == null) return 'Senha original é obrigatória';

    try {
      z
          .map({
            'password': z.string(),
            'confirmPassword': z.string().min(
              1,
              message: AppStrings.confirmPasswordRequired,
            ),
          })
          .refine((data) {
            return data['confirmPassword'] == data['password'];
          }, message: AppStrings.passwordsDoNotMatch)
          .parse({
            'password': originalPassword,
            'confirmPassword': value ?? '',
          });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para URL da API
  /// Verifica se a URL não está vazia
  static String? apiUrl(String? value) {
    try {
      _apiUrlSchema.parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para porta da API
  /// Verifica se a porta é um número válido entre 1 e 65535
  static String? apiPort(String? value) {
    try {
      _apiPortSchema.parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para email
  /// Verifica se o email tem formato válido
  static String? email(String? value) {
    try {
      _emailSchema.parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para campos obrigatórios genéricos
  /// Pode ser usado para qualquer campo que não pode estar vazio
  static String? required(String? value, {String? fieldName}) {
    try {
      _requiredSchema(fieldName: fieldName).parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para campo numérico
  /// Verifica se o valor é um número válido
  static String? numeric(String? value, {String? fieldName}) {
    try {
      _numericSchema(fieldName: fieldName).parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para tamanho mínimo de texto
  /// Verifica se o texto tem pelo menos o tamanho mínimo especificado
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    try {
      z
          .string()
          .min(1, message: 'Por favor, digite ${fieldName ?? 'este campo'}')
          .min(
            minLength,
            message:
                '${fieldName ?? 'Este campo'} deve ter pelo menos $minLength caracteres',
          )
          .parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para tamanho máximo de texto
  /// Verifica se o texto não excede o tamanho máximo especificado
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    try {
      z
          .string()
          .optional()
          .refine(
            (value) => value.length <= maxLength,
            message:
                '${fieldName ?? 'Este campo'} deve ter no máximo $maxLength caracteres',
          )
          .parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador combinado para senha com critérios específicos
  /// Verifica tamanho mínimo e pode incluir outros critérios
  static String? strongPassword(String? value) {
    return password(value); // Reutiliza validação de senha com Zard
  }

  // === NOVOS VALIDADORES DE NEGÓCIO ===

  /// Validador para código de separação
  /// Verifica se é um número válido ou campo vazio (opcional)
  static String? codSepararEstoque(String? value) {
    try {
      _codSepararEstoqueSchema.parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para origem
  /// Verifica se a origem é válida conforme enum ExpeditionOrigem
  static String? origem(String? value) {
    try {
      _origemSchema.parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para situação
  /// Verifica se a situação é válida conforme enum ExpeditionSituation
  static String? situacao(String? value) {
    try {
      _situacaoSchema.parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Validador para tipo de entidade
  /// Verifica se o tipo é 'C' (Cliente) ou 'F' (Fornecedor)
  static String? tipoEntidade(String? value) {
    try {
      _tipoEntidadeSchema.parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // === SCHEMAS COMPLEXOS PARA VALIDAÇÃO DE OBJETOS ===

  /// Schema para filtros de separação
  static final separationFiltersSchema = z.map({
    'codSepararEstoque': _codSepararEstoqueSchema,
    'origem': _origemSchema,
    'codOrigem': _codSepararEstoqueSchema, // Reutiliza validação numérica
    'situacao': _situacaoSchema,
    'dataEmissao': z.date().optional(),
  });

  /// Schema para dados de login
  static final loginSchema = z.map({
    'username': _usernameSchema,
    'password': _passwordSchema,
  });

  /// Schema para dados de registro
  static final registerSchema = z.map({
    'name': _nameSchema,
    'username': _usernameSchema,
    'email': _emailSchema,
    'password': _passwordSchema,
  });

  /// Schema para configuração da API
  static final apiConfigSchema = z.map({
    'url': _apiUrlSchema,
    'port': _apiPortSchema,
    'useHttps': z.bool().optional(),
  });

  // === MÉTODOS DE VALIDAÇÃO AVANÇADA ===

  /// Valida filtros de separação completos
  /// Retorna os dados validados ou lança exceção
  static Map<String, dynamic> validateSeparationFilters(
    Map<String, dynamic> filters,
  ) {
    try {
      return separationFiltersSchema.parse(filters);
    } catch (e) {
      throw 'Erro na validação dos filtros: $e';
    }
  }

  /// Valida dados de login
  /// Retorna os dados validados ou lança exceção
  static Map<String, dynamic> validateLogin(Map<String, dynamic> data) {
    try {
      return loginSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do login: $e';
    }
  }

  /// Valida dados de registro
  /// Retorna os dados validados ou lança exceção
  static Map<String, dynamic> validateRegister(Map<String, dynamic> data) {
    try {
      return registerSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do registro: $e';
    }
  }

  /// Valida configuração da API
  /// Retorna os dados validados ou lança exceção
  static Map<String, dynamic> validateApiConfig(Map<String, dynamic> config) {
    try {
      return apiConfigSchema.parse(config);
    } catch (e) {
      throw 'Erro na validação da configuração: $e';
    }
  }

  // === MÉTODOS DE VALIDAÇÃO SEGURA (sem exceções) ===

  /// Validação segura que retorna resultado ao invés de exception
  static ({bool success, Map<String, dynamic>? data, String? error})
  safeParseSeparationFilters(Map<String, dynamic> filters) {
    try {
      final result = separationFiltersSchema.parse(filters);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

  /// Validação segura para login
  static ({bool success, Map<String, dynamic>? data, String? error})
  safeParseLogin(Map<String, dynamic> data) {
    try {
      final result = loginSchema.parse(data);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

  /// Validação segura para registro
  static ({bool success, Map<String, dynamic>? data, String? error})
  safeParseRegister(Map<String, dynamic> data) {
    try {
      final result = registerSchema.parse(data);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

  /// Validação segura para configuração da API
  static ({bool success, Map<String, dynamic>? data, String? error})
  safeParseApiConfig(Map<String, dynamic> config) {
    try {
      final result = apiConfigSchema.parse(config);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

  // === UTILITÁRIOS DE TRANSFORMAÇÃO ===

  /// Transforma string em número inteiro (com validação)
  static int? parseIntSafely(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }

  /// Transforma string em número decimal (com validação)
  static double? parseDoubleSafely(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  /// Limpa e normaliza string
  static String? normalizeString(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
