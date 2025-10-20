import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/model_schema/separate_item_unidade_medida_consultation_schema.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de SeparateItemConsultationModel
class SeparateItemConsultationSchema {
  SeparateItemConsultationSchema._();

  /// Schema para SeparateItemConsultationModel
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSepararEstoque': CommonSchemas.integerSchema,
    'Item': CommonSchemas.itemIdSchema,
    'Origem': CommonSchemas.nonEmptyStringSchema,
    'CodOrigem': CommonSchemas.integerSchema,
    'ItemOrigem': CommonSchemas.optionalStringSchema,
    'CodProduto': CommonSchemas.integerSchema,
    'NomeProduto': CommonSchemas.nonEmptyStringSchema,
    'Ativo': CommonSchemas.nonEmptyStringSchema,
    'CodTipoProduto': CommonSchemas.nonEmptyStringSchema,
    'CodUnidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'NomeUnidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'CodGrupoProduto': CommonSchemas.integerSchema,
    'NomeGrupoProduto': CommonSchemas.nonEmptyStringSchema,
    'CodMarca': CommonSchemas.optionalIntegerSchema,
    'NomeMarca': CommonSchemas.optionalStringSchema,
    'CodSetorEstoque': CommonSchemas.optionalIntegerSchema,
    'NomeSetorEstoque': CommonSchemas.optionalStringSchema,
    'NCM': CommonSchemas.optionalStringSchema,
    'CodigoBarras': CommonSchemas.optionalStringSchema,
    'CodigoBarras2': CommonSchemas.optionalStringSchema,
    'CodigoReferencia': CommonSchemas.optionalStringSchema,
    'CodigoFornecedor': CommonSchemas.optionalStringSchema,
    'CodigoFabricante': CommonSchemas.optionalStringSchema,
    'CodigoOriginal': CommonSchemas.optionalStringSchema,
    'Endereco': CommonSchemas.optionalStringSchema,
    'EnderecoDescricao': CommonSchemas.optionalStringSchema,
    'CodLocalArmazenagem': CommonSchemas.integerSchema,
    'NomeLocaArmazenagem': CommonSchemas.nonEmptyStringSchema,
    'Quantidade': CommonSchemas.quantitySchema,
    'QuantidadeInterna': CommonSchemas.quantitySchema,
    'QuantidadeExterna': CommonSchemas.quantitySchema,
    'QuantidadeSeparacao': CommonSchemas.quantitySchema,
    'UnidadeMedidas': z.list(SeparateItemUnidadeMedidaConsultationSchema.schema),
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
