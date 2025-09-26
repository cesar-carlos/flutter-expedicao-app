import 'package:zard/zard.dart';
import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de ExpeditionCartConsultationModel
class ExpeditionCartConsultationSchema {
  ExpeditionCartConsultationSchema._();

  /// Schema para ExpeditionCartConsultationModel
  static final schema = z.map({
    'codEmpresa': CommonSchemas.integerSchema,
    'codExpedicaoCarrinho': CommonSchemas.integerSchema,
    'codRota': CommonSchemas.integerSchema,
    'nomeRota': CommonSchemas.nonEmptyStringSchema,
    'situacao': EnumSchemas.expeditionCartSituationSchema,
    'dataEmissao': CommonSchemas.dateTimeSchema,
    'horaEmissao': CommonSchemas.nonEmptyStringSchema,
    'codMotorista': CommonSchemas.optionalIntegerSchema,
    'nomeMotorista': CommonSchemas.optionalStringSchema,
    'codVeiculo': CommonSchemas.optionalIntegerSchema,
    'placaVeiculo': CommonSchemas.optionalStringSchema,
    'quantidadeExpedicoes': CommonSchemas.quantitySchema,
    'quantidadeItens': CommonSchemas.quantitySchema,
    'pesoTotal': CommonSchemas.optionalQuantitySchema,
    'volumeTotal': CommonSchemas.optionalQuantitySchema,
    'valorTotal': CommonSchemas.optionalMonetarySchema,
    'observacao': CommonSchemas.optionalStringSchema,
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
