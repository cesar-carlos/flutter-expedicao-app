import '../schemas/expedition_schemas.dart';
import '../schemas/separation_schemas.dart';
import '../schemas/user_schemas.dart';
import '../schemas/pagination_schemas.dart';
import '../schemas/enum_schemas.dart';

/// Validadores específicos para models do domínio
class ModelValidators {
  ModelValidators._();

  // === EXPEDITION VALIDATORS ===

  /// Valida ExpeditionCancellationModel
  static String? validateExpeditionCancellation(Map<String, dynamic> data) {
    try {
      ExpeditionSchemas.validateCancellation(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida ExpeditionCartModel
  static String? validateExpeditionCart(Map<String, dynamic> data) {
    try {
      ExpeditionSchemas.validateCart(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida ExpeditionCartConsultationModel
  static String? validateExpeditionCartConsultation(Map<String, dynamic> data) {
    try {
      ExpeditionSchemas.validateCartConsultation(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida ExpeditionCartRouteModel
  static String? validateExpeditionCartRoute(Map<String, dynamic> data) {
    try {
      ExpeditionSchemas.validateCartRoute(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida ExpeditionCartRouteInternshipModel
  static String? validateExpeditionCartRouteInternship(
    Map<String, dynamic> data,
  ) {
    try {
      ExpeditionSchemas.validateCartRouteInternship(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida ExpeditionCartRouteInternshipGroupModel
  static String? validateExpeditionCartRouteInternshipGroup(
    Map<String, dynamic> data,
  ) {
    try {
      ExpeditionSchemas.validateCartRouteInternshipGroup(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // === SEPARATION VALIDATORS ===

  /// Valida SeparateConsultationModel
  static String? validateSeparateConsultation(Map<String, dynamic> data) {
    try {
      SeparationSchemas.validateSeparateConsultation(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida SeparateModel
  static String? validateSeparate(Map<String, dynamic> data) {
    try {
      SeparationSchemas.validateSeparate(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida SeparateItemModel
  static String? validateSeparateItem(Map<String, dynamic> data) {
    try {
      SeparationSchemas.validateSeparateItem(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida SeparateItemConsultationModel
  static String? validateSeparateItemConsultation(Map<String, dynamic> data) {
    try {
      SeparationSchemas.separateItemConsultationSchema.parse(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida SeparationItemModel
  static String? validateSeparationItem(Map<String, dynamic> data) {
    try {
      SeparationSchemas.separationItemSchema.parse(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida SeparationItemConsultationModel
  static String? validateSeparationItemConsultation(Map<String, dynamic> data) {
    try {
      SeparationSchemas.separationItemConsultationSchema.parse(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida filtros de separação
  static String? validateSeparationFilters(Map<String, dynamic> filters) {
    try {
      SeparationSchemas.validateSeparationFilters(filters);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // === USER VALIDATORS ===

  /// Valida AppUser
  static String? validateAppUser(Map<String, dynamic> data) {
    try {
      UserSchemas.validateAppUser(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida AppUserConsultation
  static String? validateAppUserConsultation(Map<String, dynamic> data) {
    try {
      UserSchemas.appUserConsultationSchema.parse(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida LoginRequest
  static String? validateLoginRequest(Map<String, dynamic> data) {
    try {
      UserSchemas.validateLogin(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida CreateUserRequest
  static String? validateCreateUserRequest(Map<String, dynamic> data) {
    try {
      UserSchemas.validateCreateUser(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida UserPreferences
  static String? validateUserPreferences(Map<String, dynamic> data) {
    try {
      UserSchemas.validateUserPreferences(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // === PAGINATION VALIDATORS ===

  /// Valida Pagination
  static String? validatePagination(Map<String, dynamic> data) {
    try {
      PaginationSchemas.validatePagination(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida QueryBuilder
  static String? validateQueryBuilder(Map<String, dynamic> data) {
    try {
      PaginationSchemas.validateQueryBuilder(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida QueryParam
  static String? validateQueryParam(Map<String, dynamic> data) {
    try {
      PaginationSchemas.validateQueryParam(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Valida QueryOrderBy
  static String? validateQueryOrderBy(Map<String, dynamic> data) {
    try {
      PaginationSchemas.validateQueryOrderBy(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // === ENUM VALIDATORS ===

  /// Valida código de origem
  static String? validateOrigemCode(String? code) {
    if (code == null || code.trim().isEmpty) return null; // Opcional
    return EnumSchemas.isValidOrigem(code) ? null : 'Código de origem inválido';
  }

  /// Valida código de situação
  static String? validateSituationCode(String? code) {
    if (code == null || code.trim().isEmpty) return null; // Opcional
    return EnumSchemas.isValidSituation(code)
        ? null
        : 'Código de situação inválido';
  }

  /// Valida código de tipo de entidade
  static String? validateEntityTypeCode(String? code) {
    if (code == null || code.trim().isEmpty) return null; // Opcional
    return EnumSchemas.isValidEntityType(code)
        ? null
        : 'Código de tipo de entidade inválido';
  }

  /// Valida status ativo
  static String? validateActiveStatus(String? status) {
    if (status == null || status.trim().isEmpty) return null; // Opcional
    return EnumSchemas.isValidActiveStatus(status)
        ? null
        : 'Status ativo inválido (deve ser S ou N)';
  }

  // === VALIDATORS COMPOSTOS ===

  /// Valida dados completos de separação com regras de negócio
  static String? validateSeparationWithBusinessRules(
    Map<String, dynamic> data,
  ) {
    // Primeira validação: estrutura dos dados
    final structureError = validateSeparateConsultation(data);
    if (structureError != null) return structureError;

    // Segunda validação: regras de negócio
    try {
      final codEmpresa = data['codEmpresa'] as int?;
      final codSepararEstoque = data['codSepararEstoque'] as int?;
      final dataEmissao = data['dataEmissao'] as String?;

      // Regra: empresa deve ser válida
      if (codEmpresa == null || codEmpresa <= 0) {
        return 'Código da empresa deve ser maior que zero';
      }

      // Regra: código de separação deve ser válido
      if (codSepararEstoque == null || codSepararEstoque <= 0) {
        return 'Código de separação deve ser maior que zero';
      }

      // Regra: data de emissão não pode ser no futuro
      if (dataEmissao != null) {
        final emissionDate = DateTime.tryParse(dataEmissao);
        if (emissionDate != null && emissionDate.isAfter(DateTime.now())) {
          return 'Data de emissão não pode ser no futuro';
        }
      }

      return null;
    } catch (e) {
      return 'Erro na validação de regras de negócio: $e';
    }
  }

  /// Valida dados de usuário com regras de negócio
  static String? validateUserWithBusinessRules(Map<String, dynamic> data) {
    // Primeira validação: estrutura dos dados
    final structureError = validateAppUser(data);
    if (structureError != null) return structureError;

    // Segunda validação: regras de negócio
    try {
      final nome = data['nome'] as String?;
      final ativo = data['ativo'] as String?;
      final codUsuario = data['codUsuario'] as int?;

      // Regra: nome não pode conter apenas números
      if (nome != null && RegExp(r'^\d+$').hasMatch(nome.trim())) {
        return 'Nome não pode conter apenas números';
      }

      // Regra: se tem código de usuário, deve estar ativo
      if (codUsuario != null && codUsuario > 0) {
        if (ativo != 'S') {
          return 'Usuário com código definido deve estar ativo';
        }
      }

      return null;
    } catch (e) {
      return 'Erro na validação de regras de negócio do usuário: $e';
    }
  }

  // === UTILITÁRIOS ===

  /// Converte objeto para Map<String, dynamic> de forma segura
  static Map<String, dynamic>? objectToMap(dynamic object) {
    if (object == null) return null;

    if (object is Map<String, dynamic>) {
      return object;
    }

    // Se o objeto tem método toJson, usa ele
    if (object.runtimeType.toString().contains('Model')) {
      try {
        return (object as dynamic).toJson() as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Valida qualquer model usando seu tipo
  static String? validateModel(dynamic model, String modelType) {
    final data = objectToMap(model);
    if (data == null)
      return 'Não foi possível converter o modelo para validação';

    switch (modelType.toLowerCase()) {
      // Expedition models
      case 'expeditioncancellationmodel':
        return validateExpeditionCancellation(data);
      case 'expeditioncartmodel':
        return validateExpeditionCart(data);
      case 'expeditioncartconsultationmodel':
        return validateExpeditionCartConsultation(data);

      // Separation models
      case 'separateconsultationmodel':
        return validateSeparateConsultation(data);
      case 'separatemodel':
        return validateSeparate(data);
      case 'separateitemmodel':
        return validateSeparateItem(data);

      // User models
      case 'appuser':
        return validateAppUser(data);
      case 'loginrequest':
        return validateLoginRequest(data);
      case 'createuserrequest':
        return validateCreateUserRequest(data);

      // Pagination models
      case 'pagination':
        return validatePagination(data);
      case 'querybuilder':
        return validateQueryBuilder(data);

      default:
        return 'Tipo de modelo não reconhecido: $modelType';
    }
  }
}
