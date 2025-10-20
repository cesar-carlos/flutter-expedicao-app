import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_router_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/tipo_fator_conversao_model.dart';
import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';

/// Schemas para validação de enums específicos do domínio
class EnumSchemas {
  EnumSchemas._();

  // === SCHEMAS DE ORIGEM ===

  /// Schema para ExpeditionOrigem
  static final expeditionOrigemSchema = CommonSchemas.enumSchema(ExpeditionOrigem.getAllCodes(), 'Origem da expedição');

  /// Schema opcional para ExpeditionOrigem
  static final optionalExpeditionOrigemSchema = CommonSchemas.optionalEnumSchema(
    ExpeditionOrigem.getAllCodes(),
    'Origem da expedição',
  );

  /// Schema para ExpeditionSituation
  static final expeditionSituationSchema = CommonSchemas.enumSchema(
    ExpeditionSituation.getAllCodes(),
    'Situação da expedição',
  );

  /// Schema opcional para ExpeditionSituation
  static final optionalExpeditionSituationSchema = CommonSchemas.optionalEnumSchema(
    ExpeditionSituation.getAllCodes(),
    'Situação da expedição',
  );

  /// Schema para ExpeditionItemSituation
  static final expeditionItemSituationSchema = CommonSchemas.enumSchema(
    ExpeditionItemSituation.getAllCodes(),
    'Situação do item de expedição',
  );

  /// Schema opcional para ExpeditionItemSituation
  static final optionalExpeditionItemSituationSchema = CommonSchemas.optionalEnumSchema(
    ExpeditionItemSituation.getAllCodes(),
    'Situação do item de expedição',
  );

  /// Schema para ExpeditionCartSituation
  static final expeditionCartSituationSchema = CommonSchemas.enumSchema(
    ExpeditionCartSituation.getAllCodes(),
    'Situação do carrinho de expedição',
  );

  /// Schema opcional para ExpeditionCartSituation
  static final optionalExpeditionCartSituationSchema = CommonSchemas.optionalEnumSchema(
    ExpeditionCartSituation.getAllCodes(),
    'Situação do carrinho de expedição',
  );

  /// Schema para ExpeditionCartRouterSituation
  static final expeditionCartRouterSituationSchema = CommonSchemas.enumSchema(
    ExpeditionCartRouterSituation.getAllCodes(),
    'Situação do roteador do carrinho de expedição',
  );

  /// Schema opcional para ExpeditionCartRouterSituation
  static final optionalExpeditionCartRouterSituationSchema = CommonSchemas.optionalEnumSchema(
    ExpeditionCartRouterSituation.getAllCodes(),
    'Situação do roteador do carrinho de expedição',
  );

  /// Schema para EntityType
  static final entityTypeSchema = CommonSchemas.enumSchema(EntityType.getAllCodes(), 'Tipo de entidade');

  /// Schema opcional para EntityType
  static final optionalEntityTypeSchema = CommonSchemas.optionalEnumSchema(
    EntityType.getAllCodes(),
    'Tipo de entidade',
  );

  /// Schema para Situation (S/N)
  static final situationSchema = CommonSchemas.enumSchema(Situation.getAllCodes(), 'Situação');

  /// Schema opcional para Situation
  static final optionalSituationSchema = CommonSchemas.optionalEnumSchema(Situation.getAllCodes(), 'Situação');

  /// Schema para TipoFatorConversao (M/D)
  static final tipoFatorConversaoSchema = CommonSchemas.enumSchema(
    TipoFatorConversao.getAllCodes(),
    'Tipo de fator de conversão',
  );

  /// Schema opcional para TipoFatorConversao
  static final optionalTipoFatorConversaoSchema = CommonSchemas.optionalEnumSchema(
    TipoFatorConversao.getAllCodes(),
    'Tipo de fator de conversão',
  );

  /// Schema para status ativo (S/N)
  static final activeStatusSchema = CommonSchemas.enumSchema(['S', 'N', 's', 'n'], 'Status ativo');

  /// Schema opcional para status ativo
  static final optionalActiveStatusSchema = CommonSchemas.optionalEnumSchema(['S', 'N', 's', 'n'], 'Status ativo');

  // === MÉTODOS UTILITÁRIOS ===

  /// Valida se um código de origem é válido
  static bool isValidOrigem(String? code) {
    if (code == null) return false;
    return ExpeditionOrigem.isValidOrigem(code);
  }

  /// Valida se um código de situação é válido
  static bool isValidSituation(String? code) {
    if (code == null) return false;
    return ExpeditionSituation.isValidSituation(code);
  }

  /// Valida se um código de tipo de entidade é válido
  static bool isValidEntityType(String? code) {
    if (code == null) return false;
    return EntityType.isValidType(code);
  }

  /// Valida se um status ativo é válido
  static bool isValidActiveStatus(String? status) {
    if (status == null) return false;
    return ['S', 'N', 's', 'n'].contains(status);
  }

  /// Normaliza status ativo para maiúscula
  static String normalizeActiveStatus(String status) {
    return status.toUpperCase();
  }

  /// Converte status ativo para booleano
  static bool activeStatusToBool(String status) {
    return normalizeActiveStatus(status) == 'S';
  }

  /// Converte booleano para status ativo
  static String boolToActiveStatus(bool active) {
    return active ? 'S' : 'N';
  }
}
