import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class SeparateItemUnidadeMedidaConsultationSchema {
  SeparateItemUnidadeMedidaConsultationSchema._();

  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSepararEstoque': CommonSchemas.integerSchema,
    'Item': CommonSchemas.itemIdSchema,
    'CodProduto': CommonSchemas.integerSchema,
    'ItemUnidadeMedida': CommonSchemas.itemIdSchema,
    'CodUnidadeMedida': CommonSchemas.codeSchema,
    'UnidadeMedidaDescricao': CommonSchemas.descriptionSchema,
    'UnidadeMedidaPadrao': EnumSchemas.situationSchema,
    'TipoFatorConversao': EnumSchemas.tipoFatorConversaoSchema,
    'FatorConversao': CommonSchemas.quantitySchema,
    'CodigoBarras': CommonSchemas.optionalStringSchema,
    'Observacao': CommonSchemas.optionalStringSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta de unidade de medida do item de separação: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
