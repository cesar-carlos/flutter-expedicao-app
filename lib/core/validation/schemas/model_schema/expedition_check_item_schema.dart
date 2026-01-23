import 'package:zard/zard.dart';
import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ExpeditionCheckItemSchema {
  ExpeditionCheckItemSchema._();

  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodConferir': CommonSchemas.integerSchema,
    'Item': CommonSchemas.nonEmptyStringSchema,
    'CodCarrinhoPercurso': CommonSchemas.integerSchema,
    'ItemCarrinhoPercurso': CommonSchemas.nonEmptyStringSchema,
    'CodProduto': CommonSchemas.integerSchema,
    'CodUnidadeMedida': CommonSchemas.nonEmptyStringSchema,
    'Quantidade': CommonSchemas.quantitySchema,
    'QuantidadeConferida': CommonSchemas.quantitySchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do item de conferência de expedição: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
