import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de SeparateItemUnidadeMedidaConsultationModel
class SeparateItemUnidadeMedidaConsultationSchema {
  SeparateItemUnidadeMedidaConsultationSchema._();

  /// Schema para SeparateItemUnidadeMedidaConsultationModel
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

  /// Valida dados de consulta de unidade de medida do item de separação
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta de unidade de medida do item de separação: $e';
    }
  }

  /// Validação segura para consulta de unidade de medida do item de separação
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
