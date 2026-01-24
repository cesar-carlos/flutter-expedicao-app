import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class CancelCartItemSeparationParamsSchema {
  CancelCartItemSeparationParamsSchema._();

  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSepararEstoque': CommonSchemas.integerSchema,
    'SessionId': CommonSchemas.sessionIdSchema,
    'ItemCarrinhoPercurso': CommonSchemas.itemIdSchema,
    'Motivo': CommonSchemas.optionalStringSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação dos parâmetros de cancelamento de item: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
