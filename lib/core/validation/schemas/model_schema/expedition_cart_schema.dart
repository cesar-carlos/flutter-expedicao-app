import 'package:zard/zard.dart';

import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de ExpeditionCartModel
class ExpeditionCartSchema {
  ExpeditionCartSchema._();

  /// Schema para ExpeditionCartModel
  /// Baseado nos campos reais do modelo: CodEmpresa, CodCarrinho, Descricao, Ativo, CodigoBarras, Situacao
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodCarrinho': CommonSchemas.integerSchema,
    'Descricao': CommonSchemas.nonEmptyStringSchema,
    'Ativo': EnumSchemas.activeStatusSchema,
    'CodigoBarras': CommonSchemas.nonEmptyStringSchema,
    'Situacao': EnumSchemas.expeditionCartSituationSchema,
  });

  /// Valida dados do carrinho de expedição
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do carrinho: $e';
    }
  }

  /// Validação segura para carrinho
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
