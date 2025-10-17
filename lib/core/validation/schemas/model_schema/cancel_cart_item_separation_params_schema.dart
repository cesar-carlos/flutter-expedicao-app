import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de CancelCartItemSeparationParams
class CancelCartItemSeparationParamsSchema {
  CancelCartItemSeparationParamsSchema._();

  /// Schema para CancelCartItemSeparationParams
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSepararEstoque': CommonSchemas.integerSchema,
    'SessionId': CommonSchemas.sessionIdSchema,
    'ItemCarrinhoPercurso': CommonSchemas.itemIdSchema,
    'Motivo': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados de CancelCartItemSeparationParams
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação dos parâmetros de cancelamento de item: $e';
    }
  }

  /// Validação segura para CancelCartItemSeparationParams
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
