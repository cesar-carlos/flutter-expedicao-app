import 'package:zard/zard.dart';

import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de SeparateItemConsultationModel
class SeparateItemConsultationSchema {
  SeparateItemConsultationSchema._();

  /// Schema para SeparateItemConsultationModel
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSepararEstoqueItem': CommonSchemas.integerSchema,
    'CodSepararEstoque': CommonSchemas.integerSchema,
    'CodProduto': CommonSchemas.integerSchema,
    'NomeProduto': CommonSchemas.nonEmptyStringSchema,
    'CodigoBarras': CommonSchemas.optionalStringSchema,
    'UnidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'QuantidadeSolicitada': CommonSchemas.quantitySchema,
    'QuantidadeSeparada': CommonSchemas.quantitySchema,
    'QuantidadePendente': CommonSchemas.quantitySchema,
    'Situacao': EnumSchemas.expeditionItemSituationSchema,
    'TipoEntidade': EnumSchemas.entityTypeSchema,
    'CodLocal': CommonSchemas.optionalIntegerSchema,
    'NomeLocal': CommonSchemas.optionalStringSchema,
    'Observacao': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados de consulta do item de separação
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta do item de separação: $e';
    }
  }

  /// Validação segura para consulta do item de separação
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
