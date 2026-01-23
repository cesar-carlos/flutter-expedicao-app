import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ExpeditionCartSchema {
  ExpeditionCartSchema._();

  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodCarrinho': CommonSchemas.integerSchema,
    'Descricao': CommonSchemas.nonEmptyStringSchema,
    'Ativo': EnumSchemas.activeStatusSchema,
    'CodigoBarras': CommonSchemas.nonEmptyStringSchema,
    'Situacao': EnumSchemas.expeditionCartSituationSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do carrinho: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
