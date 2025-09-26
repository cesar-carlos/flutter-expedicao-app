/// Sistema de validação completo para models do domínio
///
/// Este arquivo exporta todos os schemas, validadores e extensions
/// para facilitar o uso do sistema de validação.
///
/// Uso básico:
/// ```dart
/// import 'package:exp/core/validation/index.dart';
///
/// // Usando extensions nos models
/// final model = SeparateConsultationModel(...);
/// if (!model.isValid) {
///   print('Erro: ${model.validate()}');
/// }
///
/// // Usando schemas diretamente
/// final result = UserSchemas.safeValidateLogin(loginData);
/// if (!result.success) {
///   print('Erro: ${result.error}');
/// }
///
/// // Usando schemas específicos do projeto
/// final itemId = CommonSchemas.itemIdSchema.parse('00001');
/// final sessionId = CommonSchemas.sessionIdSchema.parse('abc123_socket-id');
///
/// // Usando schemas individuais de models
/// final cartData = ExpeditionCartSchema.validate(cartJson);
/// final cancellationResult = ExpeditionCancellationSchema.safeValidate(data);
///
/// // Usando validadores
/// final error = ModelValidators.validateExpeditionCart(cartData);
/// if (error != null) {
///   print('Erro: $error');
/// }
/// ```

library;

// === SCHEMAS ===
export 'schemas/common_schemas.dart';
export 'schemas/enum_schemas.dart';
export 'schemas/separation_schemas.dart';
export 'schemas/user_schemas.dart';
export 'schemas/pagination_schemas.dart';

// === MODEL SCHEMAS (Individual) ===
export 'schemas/model/index.dart';

// === EXTENSIONS ===
export 'validation_extensions.dart';

// === UTILITÁRIOS ===

/// Classe principal do sistema de validação
class ValidationSystem {
  ValidationSystem._();

  /// Versão do sistema de validação
  static const String version = '1.0.0';

  /// Verifica se o sistema de validação está disponível
  static bool get isAvailable => true;

  /// Lista todos os tipos de modelo suportados
  static List<String> get supportedModelTypes => [
    // Expedition models
    'ExpeditionCancellationModel',
    'ExpeditionCartModel',
    'ExpeditionCartConsultationModel',
    'ExpeditionCartRouteModel',
    'ExpeditionCartRouteInternshipModel',
    'ExpeditionCartRouteInternshipGroupModel',

    // Separation models
    'SeparateConsultationModel',
    'SeparateModel',
    'SeparateItemModel',
    'SeparateItemConsultationModel',
    'SeparationItemModel',
    'SeparationItemConsultationModel',

    // User models
    'AppUser',
    'AppUserConsultation',
    'LoginRequest',
    'CreateUserRequest',
    'UserPreferences',

    // Pagination models
    'Pagination',
    'QueryBuilder',
    'QueryParam',
    'QueryOrderBy',
  ];

  /// Verifica se um tipo de modelo é suportado
  static bool isModelTypeSupported(String modelType) {
    return supportedModelTypes.contains(modelType);
  }

  /// Obtém informações sobre o sistema
  static Map<String, dynamic> get info => {
    'version': version,
    'isAvailable': isAvailable,
    'supportedModels': supportedModelTypes.length,
    'schemas': [
      'CommonSchemas',
      'EnumSchemas',
      'ExpeditionSchemas',
      'SeparationSchemas',
      'UserSchemas',
      'PaginationSchemas',
    ],
    'validators': ['ModelValidators'],
    'extensions': ['ValidationExtensions'],
  };
}
