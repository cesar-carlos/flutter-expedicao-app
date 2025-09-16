import 'package:zard/zard.dart';
import 'common_schemas.dart';
import 'enum_schemas.dart';

/// Schemas para validação de models de separação
class SeparationSchemas {
  SeparationSchemas._();

  // === SEPARATE CONSULTATION ===

  /// Schema para SeparateConsultationModel
  static final separateConsultationSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codSepararEstoque': CommonSchemas.idSchema,
    'origem': EnumSchemas.expeditionOrigemSchema,
    'codOrigem': CommonSchemas.idSchema,
    'codTipoOperacaoExpedicao': CommonSchemas.idSchema,
    'nomeTipoOperacaoExpedicao': CommonSchemas.nonEmptyStringSchema,
    'situacao': EnumSchemas.expeditionSituationSchema,
    'tipoEntidade': EnumSchemas.entityTypeSchema,
    'dataEmissao': CommonSchemas.dateTimeSchema,
    'horaEmissao': CommonSchemas.nonEmptyStringSchema,
    'codEntidade': CommonSchemas.idSchema,
    'nomeEntidade': CommonSchemas.nonEmptyStringSchema,
    'codPrioridade': CommonSchemas.idSchema,
    'nomePrioridade': CommonSchemas.nonEmptyStringSchema,
    'historico': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === SEPARATE MODEL ===

  /// Schema para SeparateModel
  static final separateSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codSepararEstoque': CommonSchemas.idSchema,
    'origem': EnumSchemas.expeditionOrigemSchema,
    'codOrigem': CommonSchemas.idSchema,
    'codTipoOperacaoExpedicao': CommonSchemas.idSchema,
    'nomeTipoOperacaoExpedicao': CommonSchemas.nonEmptyStringSchema,
    'situacao': EnumSchemas.expeditionSituationSchema,
    'tipoEntidade': EnumSchemas.entityTypeSchema,
    'dataEmissao': CommonSchemas.dateTimeSchema,
    'horaEmissao': CommonSchemas.nonEmptyStringSchema,
    'codEntidade': CommonSchemas.idSchema,
    'nomeEntidade': CommonSchemas.nonEmptyStringSchema,
    'codUsuarioEmissao': CommonSchemas.idSchema,
    'nomeUsuarioEmissao': CommonSchemas.nonEmptyStringSchema,
    'codPrioridade': CommonSchemas.idSchema,
    'nomePrioridade': CommonSchemas.nonEmptyStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === SEPARATE ITEM CONSULTATION ===

  /// Schema para SeparateItemConsultationModel
  static final separateItemConsultationSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codSepararEstoqueItem': CommonSchemas.idSchema,
    'codSepararEstoque': CommonSchemas.idSchema,
    'codProduto': CommonSchemas.idSchema,
    'nomeProduto': CommonSchemas.nonEmptyStringSchema,
    'codigoBarras': CommonSchemas.optionalStringSchema,
    'unidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'quantidadeSolicitada': CommonSchemas.quantitySchema,
    'quantidadeSeparada': CommonSchemas.quantitySchema,
    'quantidadePendente': CommonSchemas.quantitySchema,
    'situacao': EnumSchemas.expeditionItemSituationSchema,
    'tipoEntidade': EnumSchemas.entityTypeSchema,
    'codLocal': CommonSchemas.optionalIdSchema,
    'nomeLocal': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === SEPARATE ITEM MODEL ===

  /// Schema para SeparateItemModel
  static final separateItemSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codSepararEstoqueItem': CommonSchemas.idSchema,
    'codSepararEstoque': CommonSchemas.idSchema,
    'codProduto': CommonSchemas.idSchema,
    'nomeProduto': CommonSchemas.nonEmptyStringSchema,
    'codigoBarras': CommonSchemas.optionalStringSchema,
    'unidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'quantidadeSolicitada': CommonSchemas.quantitySchema,
    'quantidadeSeparada': CommonSchemas.quantitySchema,
    'situacao': EnumSchemas.expeditionItemSituationSchema,
    'codLocal': CommonSchemas.optionalIdSchema,
    'nomeLocal': CommonSchemas.optionalStringSchema,
    'codUsuarioSeparacao': CommonSchemas.optionalIdSchema,
    'nomeUsuarioSeparacao': CommonSchemas.optionalStringSchema,
    'dataSeparacao': CommonSchemas.optionalDateTimeSchema,
    'horaSeparacao': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === SEPARATION ITEM CONSULTATION ===

  /// Schema para SeparationItemConsultationModel
  static final separationItemConsultationSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codSeparacaoItem': CommonSchemas.idSchema,
    'codSeparacao': CommonSchemas.idSchema,
    'codProduto': CommonSchemas.idSchema,
    'nomeProduto': CommonSchemas.nonEmptyStringSchema,
    'codigoBarras': CommonSchemas.optionalStringSchema,
    'unidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'quantidadeSolicitada': CommonSchemas.quantitySchema,
    'quantidadeSeparada': CommonSchemas.quantitySchema,
    'quantidadePendente': CommonSchemas.quantitySchema,
    'situacao': EnumSchemas.expeditionItemSituationSchema,
    'codLocal': CommonSchemas.optionalIdSchema,
    'nomeLocal': CommonSchemas.optionalStringSchema,
    'codUsuarioSeparacao': CommonSchemas.optionalIdSchema,
    'nomeUsuarioSeparacao': CommonSchemas.optionalStringSchema,
    'dataSeparacao': CommonSchemas.optionalDateTimeSchema,
    'horaSeparacao': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === SEPARATION ITEM MODEL ===

  /// Schema para SeparationItemModel
  static final separationItemSchema = z.map({
    'codEmpresa': CommonSchemas.idSchema,
    'codSeparacaoItem': CommonSchemas.idSchema,
    'codSeparacao': CommonSchemas.idSchema,
    'codProduto': CommonSchemas.idSchema,
    'nomeProduto': CommonSchemas.nonEmptyStringSchema,
    'codigoBarras': CommonSchemas.optionalStringSchema,
    'unidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'quantidadeSolicitada': CommonSchemas.quantitySchema,
    'quantidadeSeparada': CommonSchemas.quantitySchema,
    'situacao': EnumSchemas.expeditionItemSituationSchema,
    'codLocal': CommonSchemas.optionalIdSchema,
    'nomeLocal': CommonSchemas.optionalStringSchema,
    'codUsuarioSeparacao': CommonSchemas.optionalIdSchema,
    'nomeUsuarioSeparacao': CommonSchemas.optionalStringSchema,
    'dataSeparacao': CommonSchemas.optionalDateTimeSchema,
    'horaSeparacao': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  // === SCHEMAS DE FILTRO ===

  /// Schema para filtros de separação
  static final separationFiltersSchema = z.map({
    'codSepararEstoque': CommonSchemas.optionalCodeSchema,
    'origem': EnumSchemas.optionalExpeditionOrigemSchema,
    'codOrigem': CommonSchemas.optionalCodeSchema,
    'situacao': EnumSchemas.optionalExpeditionSituationSchema,
    'dataEmissao': CommonSchemas.optionalDateTimeSchema,
    'tipoEntidade': EnumSchemas.optionalEntityTypeSchema,
    'codEntidade': CommonSchemas.optionalIdSchema,
    'nomeEntidade': CommonSchemas.optionalStringSchema,
  });

  // === MÉTODOS DE VALIDAÇÃO ===

  /// Valida dados de consulta de separação
  static Map<String, dynamic> validateSeparateConsultation(
    Map<String, dynamic> data,
  ) {
    try {
      return separateConsultationSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta de separação: $e';
    }
  }

  /// Valida dados de separação
  static Map<String, dynamic> validateSeparate(Map<String, dynamic> data) {
    try {
      return separateSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação da separação: $e';
    }
  }

  /// Valida dados do item de separação
  static Map<String, dynamic> validateSeparateItem(Map<String, dynamic> data) {
    try {
      return separateItemSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do item de separação: $e';
    }
  }

  /// Valida filtros de separação
  static Map<String, dynamic> validateSeparationFilters(
    Map<String, dynamic> filters,
  ) {
    try {
      return separationFiltersSchema.parse(filters);
    } catch (e) {
      throw 'Erro na validação dos filtros de separação: $e';
    }
  }

  // === VALIDAÇÃO SEGURA ===

  /// Validação segura para consulta de separação
  static ({bool success, Map<String, dynamic>? data, String? error})
  safeValidateSeparateConsultation(Map<String, dynamic> data) {
    try {
      final result = separateConsultationSchema.parse(data);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

  /// Validação segura para filtros
  static ({bool success, Map<String, dynamic>? data, String? error})
  safeValidateSeparationFilters(Map<String, dynamic> filters) {
    try {
      final result = separationFiltersSchema.parse(filters);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

  // === VALIDAÇÕES DE REGRAS DE NEGÓCIO ===

  /// Valida se a quantidade separada não excede a solicitada
  static bool validateSeparatedQuantity(double solicitada, double separada) {
    return separada <= solicitada;
  }

  /// Valida se a quantidade pendente está correta
  static bool validatePendingQuantity(
    double solicitada,
    double separada,
    double pendente,
  ) {
    return (solicitada - separada) == pendente;
  }

  /// Valida se a situação do item é compatível com as quantidades
  static bool validateItemSituationWithQuantities(
    String situacao,
    double solicitada,
    double separada,
  ) {
    if (separada == 0) {
      return ['P', 'A'].contains(situacao); // Pendente ou Aguardando
    } else if (separada == solicitada) {
      return ['S', 'F'].contains(situacao); // Separado ou Finalizado
    } else if (separada < solicitada) {
      return [
        'PS',
        'P',
      ].contains(situacao); // Parcialmente Separado ou Pendente
    }
    return false;
  }
}
