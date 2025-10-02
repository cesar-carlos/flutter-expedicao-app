import 'package:zard/zard.dart';
import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de ExpeditionCartConsultationModel
class ExpeditionCartConsultationSchema {
  ExpeditionCartConsultationSchema._();

  /// Schema para ExpeditionCartConsultationModel
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodExpedicaoCarrinho': CommonSchemas.integerSchema,
    'CodRota': CommonSchemas.integerSchema,
    'NomeRota': CommonSchemas.nonEmptyStringSchema,
    'Situacao': EnumSchemas.expeditionCartSituationSchema,
    'DataEmissao': CommonSchemas.dateTimeSchema,
    'HoraEmissao': CommonSchemas.nonEmptyStringSchema,
    'CodMotorista': CommonSchemas.optionalIntegerSchema,
    'NomeMotorista': CommonSchemas.optionalStringSchema,
    'CodVeiculo': CommonSchemas.optionalIntegerSchema,
    'PlacaVeiculo': CommonSchemas.optionalStringSchema,
    'QuantidadeExpedicoes': CommonSchemas.quantitySchema,
    'QuantidadeItens': CommonSchemas.quantitySchema,
    'PesoTotal': CommonSchemas.optionalQuantitySchema,
    'VolumeTotal': CommonSchemas.optionalQuantitySchema,
    'ValorTotal': CommonSchemas.optionalMonetarySchema,
    'Observacao': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados da consulta do carrinho
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta do carrinho: $e';
    }
  }

  /// Validação segura para consulta do carrinho
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
