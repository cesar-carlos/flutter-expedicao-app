import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class SeparationItemConsultationSchema {
  SeparationItemConsultationSchema._();

  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSeparacaoItem': CommonSchemas.integerSchema,
    'CodSeparacao': CommonSchemas.integerSchema,
    'CodProduto': CommonSchemas.integerSchema,
    'NomeProduto': CommonSchemas.nonEmptyStringSchema,
    'CodigoBarras': CommonSchemas.optionalStringSchema,
    'UnidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'QuantidadeSolicitada': CommonSchemas.quantitySchema,
    'QuantidadeSeparada': CommonSchemas.quantitySchema,
    'QuantidadePendente': CommonSchemas.quantitySchema,
    'Situacao': EnumSchemas.expeditionItemSituationSchema,
    'CodLocal': CommonSchemas.optionalIntegerSchema,
    'NomeLocal': CommonSchemas.optionalStringSchema,
    'CodUsuarioSeparacao': CommonSchemas.optionalIntegerSchema,
    'NomeUsuarioSeparacao': CommonSchemas.optionalStringSchema,
    'DataSeparacao': CommonSchemas.optionalDateTimeSchema,
    'HoraSeparacao': CommonSchemas.optionalStringSchema,
    'Observacao': CommonSchemas.optionalStringSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta do item de separação: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
