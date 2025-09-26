import 'package:exp/core/validation/schemas/model/index.dart';
import 'package:exp/core/results/index.dart';

/// Schemas para validação de models de expedição
///
/// Esta classe mantém compatibilidade com o código existente,
/// mas agora delega para os schemas individuais na pasta model/
class ExpeditionSchemas {
  ExpeditionSchemas._();

  // === EXPEDITION CANCELLATION ===

  /// Schema para ExpeditionCancellationModel
  static final cancellationSchema = ExpeditionCancellationSchema.schema;

  // === EXPEDITION CART ===

  /// Schema para ExpeditionCartModel
  static final cartSchema = ExpeditionCartSchema.schema;

  // === EXPEDITION CART CONSULTATION ===

  /// Schema para ExpeditionCartConsultationModel
  static final cartConsultationSchema = ExpeditionCartConsultationSchema.schema;

  // === EXPEDITION CART ROUTE ===

  /// Schema para ExpeditionCartRouteModel
  static final cartRouteSchema = ExpeditionCartRouteSchema.schema;

  // === EXPEDITION CART ROUTE INTERNSHIP ===

  /// Schema para ExpeditionCartRouteInternshipModel
  static final cartRouteInternshipSchema = ExpeditionCartRouteInternshipSchema.schema;

  // === EXPEDITION CART ROUTE INTERNSHIP GROUP ===

  /// Schema para ExpeditionCartRouteInternshipGroupModel
  static final cartRouteInternshipGroupSchema = ExpeditionCartRouteInternshipGroupSchema.schema;

  // === MÉTODOS DE VALIDAÇÃO ===
  // Delegam para os schemas individuais para manter compatibilidade

  /// Valida dados de cancelamento de expedição
  static Map<String, dynamic> validateCancellation(Map<String, dynamic> data) =>
      ExpeditionCancellationSchema.validate(data);

  /// Valida dados do carrinho de expedição
  static Map<String, dynamic> validateCart(Map<String, dynamic> data) => ExpeditionCartSchema.validate(data);

  /// Valida dados da consulta do carrinho
  static Map<String, dynamic> validateCartConsultation(Map<String, dynamic> data) =>
      ExpeditionCartConsultationSchema.validate(data);

  /// Valida dados da rota do carrinho
  static Map<String, dynamic> validateCartRoute(Map<String, dynamic> data) => ExpeditionCartRouteSchema.validate(data);

  /// Valida dados do estágio da rota
  static Map<String, dynamic> validateCartRouteInternship(Map<String, dynamic> data) =>
      ExpeditionCartRouteInternshipSchema.validate(data);

  /// Valida dados do grupo do estágio
  static Map<String, dynamic> validateCartRouteInternshipGroup(Map<String, dynamic> data) =>
      ExpeditionCartRouteInternshipGroupSchema.validate(data);

  // === VALIDAÇÃO SEGURA ===
  // Delegam para os schemas individuais para manter compatibilidade

  /// Validação segura para cancelamento
  static Result<Map<String, dynamic>> safeValidateCancellation(Map<String, dynamic> data) =>
      ExpeditionCancellationSchema.safeValidate(data);

  /// Validação segura para carrinho
  static Result<Map<String, dynamic>> safeValidateCart(Map<String, dynamic> data) =>
      ExpeditionCartSchema.safeValidate(data);

  /// Validação segura para consulta do carrinho
  static Result<Map<String, dynamic>> safeValidateCartConsultation(Map<String, dynamic> data) =>
      ExpeditionCartConsultationSchema.safeValidate(data);

  /// Validação segura para rota do carrinho
  static Result<Map<String, dynamic>> safeValidateCartRoute(Map<String, dynamic> data) =>
      ExpeditionCartRouteSchema.safeValidate(data);

  /// Validação segura para estágio da rota
  static Result<Map<String, dynamic>> safeValidateCartRouteInternship(Map<String, dynamic> data) =>
      ExpeditionCartRouteInternshipSchema.safeValidate(data);

  /// Validação segura para grupo do estágio
  static Result<Map<String, dynamic>> safeValidateCartRouteInternshipGroup(Map<String, dynamic> data) =>
      ExpeditionCartRouteInternshipGroupSchema.safeValidate(data);
}
