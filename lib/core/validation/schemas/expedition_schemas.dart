import 'package:zard/zard.dart';
import 'common_schemas.dart';
import 'enum_schemas.dart';

/// Schemas para validação de models de expedição
class ExpeditionSchemas {
  ExpeditionSchemas._();

  // === EXPEDITION CANCELLATION ===

  /// Schema para ExpeditionCancellationModel
  static final cancellationSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codCancelamento': CommonSchemas.idSchema,
    'origem': EnumSchemas.expeditionOrigemSchema,
    'codOrigem': CommonSchemas.idSchema,
    'itemOrigem': CommonSchemas.nonEmptyStringSchema,
    'codMotivoCancelamento': CommonSchemas.optionalIdSchema,
    'dataCancelamento': CommonSchemas.dateTimeSchema,
    'horaCancelamento': CommonSchemas.nonEmptyStringSchema,
    'codUsuarioCancelamento': CommonSchemas.idSchema,
    'nomeUsuarioCancelamento': CommonSchemas.nonEmptyStringSchema,
    'observacaoCancelamento': CommonSchemas.optionalStringSchema,
  });

  // === EXPEDITION CART ===

  /// Schema para ExpeditionCartModel
  static final cartSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codExpedicaoCarrinho': CommonSchemas.idSchema,
    'codRota': CommonSchemas.idSchema,
    'nomeRota': CommonSchemas.nonEmptyStringSchema,
    'situacao': EnumSchemas.expeditionCartSituationSchema,
    'dataEmissao': CommonSchemas.dateTimeSchema,
    'horaEmissao': CommonSchemas.nonEmptyStringSchema,
    'codMotorista': CommonSchemas.optionalIdSchema,
    'nomeMotorista': CommonSchemas.optionalStringSchema,
    'codVeiculo': CommonSchemas.optionalIdSchema,
    'placaVeiculo': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === EXPEDITION CART CONSULTATION ===

  /// Schema para ExpeditionCartConsultationModel
  static final cartConsultationSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codExpedicaoCarrinho': CommonSchemas.idSchema,
    'codRota': CommonSchemas.idSchema,
    'nomeRota': CommonSchemas.nonEmptyStringSchema,
    'situacao': EnumSchemas.expeditionCartSituationSchema,
    'dataEmissao': CommonSchemas.dateTimeSchema,
    'horaEmissao': CommonSchemas.nonEmptyStringSchema,
    'codMotorista': CommonSchemas.optionalIdSchema,
    'nomeMotorista': CommonSchemas.optionalStringSchema,
    'codVeiculo': CommonSchemas.optionalIdSchema,
    'placaVeiculo': CommonSchemas.optionalStringSchema,
    'quantidadeExpedicoes': CommonSchemas.quantitySchema,
    'quantidadeItens': CommonSchemas.quantitySchema,
    'pesoTotal': CommonSchemas.optionalQuantitySchema,
    'volumeTotal': CommonSchemas.optionalQuantitySchema,
    'valorTotal': CommonSchemas.optionalMonetarySchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === EXPEDITION CART ROUTE ===

  /// Schema para ExpeditionCartRouteModel
  static final cartRouteSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codExpedicaoCarrinhoRota': CommonSchemas.idSchema,
    'codExpedicaoCarrinho': CommonSchemas.idSchema,
    'codRota': CommonSchemas.idSchema,
    'nomeRota': CommonSchemas.nonEmptyStringSchema,
    'sequencia': CommonSchemas.idSchema,
    'codEntidade': CommonSchemas.idSchema,
    'nomeEntidade': CommonSchemas.nonEmptyStringSchema,
    'endereco': CommonSchemas.optionalStringSchema,
    'bairro': CommonSchemas.optionalStringSchema,
    'cidade': CommonSchemas.optionalStringSchema,
    'uf': CommonSchemas.optionalStringSchema,
    'cep': CommonSchemas.optionalStringSchema,
    'telefone': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === EXPEDITION CART ROUTE INTERNSHIP ===

  /// Schema para ExpeditionCartRouteInternshipModel
  static final cartRouteInternshipSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codExpedicaoCarrinhoRotaEstagio': CommonSchemas.idSchema,
    'codExpedicaoCarrinhoRota': CommonSchemas.idSchema,
    'codEstagio': CommonSchemas.idSchema,
    'nomeEstagio': CommonSchemas.nonEmptyStringSchema,
    'sequencia': CommonSchemas.idSchema,
    'situacao': EnumSchemas.expeditionSituationSchema,
    'dataInicio': CommonSchemas.optionalDateTimeSchema,
    'horaInicio': CommonSchemas.optionalStringSchema,
    'dataFim': CommonSchemas.optionalDateTimeSchema,
    'horaFim': CommonSchemas.optionalStringSchema,
    'codUsuarioInicio': CommonSchemas.optionalIdSchema,
    'nomeUsuarioInicio': CommonSchemas.optionalStringSchema,
    'codUsuarioFim': CommonSchemas.optionalIdSchema,
    'nomeUsuarioFim': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === EXPEDITION CART ROUTE INTERNSHIP GROUP ===

  /// Schema para ExpeditionCartRouteInternshipGroupModel
  static final cartRouteInternshipGroupSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codExpedicaoCarrinhoRotaEstagioGrupo': CommonSchemas.idSchema,
    'codExpedicaoCarrinhoRotaEstagio': CommonSchemas.idSchema,
    'codGrupo': CommonSchemas.idSchema,
    'nomeGrupo': CommonSchemas.nonEmptyStringSchema,
    'sequencia': CommonSchemas.idSchema,
    'situacao': EnumSchemas.expeditionSituationSchema,
    'dataInicio': CommonSchemas.optionalDateTimeSchema,
    'horaInicio': CommonSchemas.optionalStringSchema,
    'dataFim': CommonSchemas.optionalDateTimeSchema,
    'horaFim': CommonSchemas.optionalStringSchema,
    'codUsuarioInicio': CommonSchemas.optionalIdSchema,
    'nomeUsuarioInicio': CommonSchemas.optionalStringSchema,
    'codUsuarioFim': CommonSchemas.optionalIdSchema,
    'nomeUsuarioFim': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === MÉTODOS DE VALIDAÇÃO ===

  /// Valida dados de cancelamento de expedição
  static Map<String, dynamic> validateCancellation(Map<String, dynamic> data) {
    try {
      return cancellationSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do cancelamento: $e';
    }
  }

  /// Valida dados do carrinho de expedição
  static Map<String, dynamic> validateCart(Map<String, dynamic> data) {
    try {
      return cartSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do carrinho: $e';
    }
  }

  /// Valida dados da consulta do carrinho
  static Map<String, dynamic> validateCartConsultation(
    Map<String, dynamic> data,
  ) {
    try {
      return cartConsultationSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta do carrinho: $e';
    }
  }

  /// Valida dados da rota do carrinho
  static Map<String, dynamic> validateCartRoute(Map<String, dynamic> data) {
    try {
      return cartRouteSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação da rota do carrinho: $e';
    }
  }

  /// Valida dados do estágio da rota
  static Map<String, dynamic> validateCartRouteInternship(
    Map<String, dynamic> data,
  ) {
    try {
      return cartRouteInternshipSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do estágio da rota: $e';
    }
  }

  /// Valida dados do grupo do estágio
  static Map<String, dynamic> validateCartRouteInternshipGroup(
    Map<String, dynamic> data,
  ) {
    try {
      return cartRouteInternshipGroupSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do grupo do estágio: $e';
    }
  }

  // === VALIDAÇÃO SEGURA ===

  /// Validação segura para cancelamento
  static ({bool success, Map<String, dynamic>? data, String? error})
  safeValidateCancellation(Map<String, dynamic> data) {
    try {
      final result = cancellationSchema.parse(data);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

  /// Validação segura para carrinho
  static ({bool success, Map<String, dynamic>? data, String? error})
  safeValidateCart(Map<String, dynamic> data) {
    try {
      final result = cartSchema.parse(data);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }
}
