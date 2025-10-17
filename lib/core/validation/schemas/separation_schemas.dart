import 'package:data7_expedicao/core/validation/schemas/model_schema/index.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schemas para validação de models de separação
///
/// Esta classe mantém compatibilidade com o código existente,
/// mas agora delega para os schemas individuais na pasta model/
class SeparationSchemas {
  SeparationSchemas._();

  // === SCHEMAS DELEGADOS ===
  // Delegam para os schemas individuais para manter compatibilidade

  /// Schema para SeparateConsultationModel
  static final separateConsultationSchema = SeparateConsultationSchema.schema;

  /// Schema para SeparateModel
  static final separateSchema = SeparateSchema.schema;

  /// Schema para SeparateItemConsultationModel
  static final separateItemConsultationSchema = SeparateItemConsultationSchema.schema;

  /// Schema para SeparateItemModel
  static final separateItemSchema = SeparateItemSchema.schema;

  /// Schema para SeparationItemConsultationModel
  static final separationItemConsultationSchema = SeparationItemConsultationSchema.schema;

  /// Schema para SeparationItemModel
  static final separationItemSchema = SeparationItemSchema.schema;

  /// Schema para filtros de separação
  static final separationFiltersSchema = SeparationFiltersSchema.schema;

  /// Schema para SeparationUserSectorModel
  static final separationUserSectorSchema = SeparationUserSectorSchema.schema;

  /// Schema para SeparationUserSectorConsultationModel
  static final separationUserSectorConsultationSchema = SeparationUserSectorConsultationSchema.schema;

  // === MÉTODOS DE VALIDAÇÃO ===
  // Delegam para os schemas individuais para manter compatibilidade

  /// Valida dados de consulta de separação
  static Map<String, dynamic> validateSeparateConsultation(Map<String, dynamic> data) =>
      SeparateConsultationSchema.validate(data);

  /// Valida dados de separação
  static Map<String, dynamic> validateSeparate(Map<String, dynamic> data) => SeparateSchema.validate(data);

  /// Valida dados do item de separação
  static Map<String, dynamic> validateSeparateItem(Map<String, dynamic> data) => SeparateItemSchema.validate(data);

  /// Valida filtros de separação
  static Map<String, dynamic> validateSeparationFilters(Map<String, dynamic> filters) =>
      SeparationFiltersSchema.validate(filters);

  /// Valida dados de separação por usuário e setor
  static Map<String, dynamic> validateSeparationUserSector(Map<String, dynamic> data) =>
      SeparationUserSectorSchema.validate(data);

  /// Valida dados de consulta de separação por usuário e setor
  static Map<String, dynamic> validateSeparationUserSectorConsultation(Map<String, dynamic> data) =>
      SeparationUserSectorConsultationSchema.validate(data);

  // === VALIDAÇÃO SEGURA ===
  // Delegam para os schemas individuais para manter compatibilidade

  /// Validação segura para consulta de separação
  static Result<Map<String, dynamic>> safeValidateSeparateConsultation(Map<String, dynamic> data) =>
      SeparateConsultationSchema.safeValidate(data);

  /// Validação segura para filtros
  static Result<Map<String, dynamic>> safeValidateSeparationFilters(Map<String, dynamic> filters) =>
      SeparationFiltersSchema.safeValidate(filters);

  /// Validação segura para separação por usuário e setor
  static Result<Map<String, dynamic>> safeValidateSeparationUserSector(Map<String, dynamic> data) =>
      SeparationUserSectorSchema.safeValidate(data);

  /// Validação segura para consulta de separação por usuário e setor
  static Result<Map<String, dynamic>> safeValidateSeparationUserSectorConsultation(Map<String, dynamic> data) =>
      SeparationUserSectorConsultationSchema.safeValidate(data);

  // === VALIDAÇÕES DE REGRAS DE NEGÓCIO ===

  /// Valida se a quantidade separada não excede a solicitada
  static bool validateSeparatedQuantity(double solicitada, double separada) {
    return separada <= solicitada;
  }

  /// Valida se a quantidade pendente está correta
  static bool validatePendingQuantity(double solicitada, double separada, double pendente) {
    return (solicitada - separada) == pendente;
  }

  /// Valida se a situação do item é compatível com as quantidades
  static bool validateItemSituationWithQuantities(String situacao, double solicitada, double separada) {
    if (separada == 0) {
      return ['P', 'A'].contains(situacao); // Pendente ou Aguardando
    } else if (separada == solicitada) {
      return ['S', 'F'].contains(situacao); // Separado ou Finalizado
    } else if (separada < solicitada) {
      return ['PS', 'P'].contains(situacao); // Parcialmente Separado ou Pendente
    }
    return false;
  }

  // === SCHEMAS PARA USECASES ===
  // Delegam para os schemas individuais para manter compatibilidade

  /// Schema para AddItemSeparationParams
  static final addItemSeparationParamsSchema = AddItemSeparationParamsSchema.schema;

  /// Schema para CancelCartItemSeparationParams
  static final cancelCartItemSeparationParamsSchema = CancelCartItemSeparationParamsSchema.schema;

  // === VALIDAÇÃO SEGURA PARA USECASES ===
  // Delegam para os schemas individuais para manter compatibilidade

  /// Validação segura para AddItemSeparationParams
  static Result<Map<String, dynamic>> safeValidateAddItemSeparationParams(Map<String, dynamic> data) =>
      AddItemSeparationParamsSchema.safeValidate(data);

  /// Validação segura para CancelCartItemSeparationParams
  static Result<Map<String, dynamic>> safeValidateCancelCartItemSeparationParams(Map<String, dynamic> data) =>
      CancelCartItemSeparationParamsSchema.safeValidate(data);
}
