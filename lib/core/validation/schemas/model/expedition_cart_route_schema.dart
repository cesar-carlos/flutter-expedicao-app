import 'package:zard/zard.dart';
import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de ExpeditionCartRouteModel
class ExpeditionCartRouteSchema {
  ExpeditionCartRouteSchema._();

  /// Schema para ExpeditionCartRouteModel
  static final schema = z.map({
    'codEmpresa': CommonSchemas.integerSchema,
    'codExpedicaoCarrinhoRota': CommonSchemas.integerSchema,
    'codExpedicaoCarrinho': CommonSchemas.integerSchema,
    'codRota': CommonSchemas.integerSchema,
    'nomeRota': CommonSchemas.nonEmptyStringSchema,
    'sequencia': CommonSchemas.integerSchema,
    'codEntidade': CommonSchemas.integerSchema,
    'nomeEntidade': CommonSchemas.nonEmptyStringSchema,
    'endereco': CommonSchemas.optionalStringSchema,
    'bairro': CommonSchemas.optionalStringSchema,
    'cidade': CommonSchemas.optionalStringSchema,
    'uf': CommonSchemas.optionalStringSchema,
    'cep': CommonSchemas.optionalStringSchema,
    'telefone': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados da rota do carrinho
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da rota do carrinho: $e';
    }
  }

  /// Validação segura para rota do carrinho
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
