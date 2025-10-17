import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de AddItemSeparationParams
class AddItemSeparationParamsSchema {
  AddItemSeparationParamsSchema._();

  /// Schema para AddItemSeparationParams
  static final schema = z
      .map({
        'CodEmpresa': CommonSchemas.integerSchema,
        'CodSepararEstoque': CommonSchemas.integerSchema,
        'SessionId': CommonSchemas.sessionIdSchema,
        'CodCarrinhoPercurso': CommonSchemas.integerSchema,
        'ItemCarrinhoPercurso': CommonSchemas.itemIdSchema,
        'CodSeparador': CommonSchemas.integerSchema,
        'NomeSeparador': CommonSchemas.nonEmptyStringSchema,
        'CodProduto': CommonSchemas.integerSchema,
        'CodUnidadeMedida': CommonSchemas.nonEmptyStringSchema,
        'Quantidade': z.double()
            .min(0.0001, message: 'Quantidade deve ser maior que zero')
            .max(9999.9999, message: 'Quantidade não pode exceder 9999.9999'),
        'Observacao': CommonSchemas.optionalStringSchema,
      })
      .refine((value) {
        // Validação de precisão decimal (máximo 4 casas)
        final quantidade = value['Quantidade'] as double;
        final quantidadeStr = quantidade.toStringAsFixed(4);
        final quantidadeParsed = double.parse(quantidadeStr);
        return (quantidade - quantidadeParsed).abs() <= 0.0001;
      }, message: 'Quantidade deve ter no máximo 4 casas decimais');

  /// Valida dados de AddItemSeparationParams
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação dos parâmetros de adição de item: $e';
    }
  }

  /// Validação segura para AddItemSeparationParams
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
