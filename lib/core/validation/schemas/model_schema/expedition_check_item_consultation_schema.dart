import 'package:zard/zard.dart';
import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ExpeditionCheckItemConsultationSchema {
  ExpeditionCheckItemConsultationSchema._();

  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodConferir': CommonSchemas.integerSchema,
    'Item': CommonSchemas.nonEmptyStringSchema,
    'Origem': EnumSchemas.expeditionOrigemSchema,
    'CodOrigem': CommonSchemas.integerSchema,
    'CodCarrinhoPercurso': CommonSchemas.integerSchema,
    'ItemCarrinhoPercurso': CommonSchemas.nonEmptyStringSchema,
    'SituacaoCarrinhoPercurso': EnumSchemas.expeditionCartSituationSchema,
    'CodCarrinho': CommonSchemas.integerSchema,
    'CodProduto': CommonSchemas.integerSchema,
    'NomeProduto': CommonSchemas.nonEmptyStringSchema,
    'CodUnidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'NomeUnidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'CodGrupoProduto': CommonSchemas.integerSchema,
    'NomeGrupoProduto': CommonSchemas.nonEmptyStringSchema,
    'CodMarca': CommonSchemas.optionalIntegerSchema,
    'NomeMarca': CommonSchemas.optionalStringSchema,
    'CodSetorEstoque': CommonSchemas.optionalIntegerSchema,
    'NomeSetorEstoque': CommonSchemas.optionalStringSchema,
    'CodigoBarras': CommonSchemas.optionalStringSchema,
    'CodigoBarras2': CommonSchemas.optionalStringSchema,
    'CodigoReferencia': CommonSchemas.optionalStringSchema,
    'CodigoFornecedor': CommonSchemas.optionalStringSchema,
    'CodigoFabricante': CommonSchemas.optionalStringSchema,
    'CodigoOriginal': CommonSchemas.optionalStringSchema,
    'Endereco': CommonSchemas.optionalStringSchema,
    'EnderecoDescricao': CommonSchemas.optionalStringSchema,
    'Quantidade': CommonSchemas.quantitySchema,
    'QuantidadeConferida': CommonSchemas.quantitySchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta de item de conferência de expedição: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
