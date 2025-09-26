import 'package:zard/zard.dart';
import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de ExpeditionCartRouteInternshipModel
class ExpeditionCartRouteInternshipSchema {
  ExpeditionCartRouteInternshipSchema._();

  /// Schema para ExpeditionCartRouteInternshipModel
  static final schema = z.map({
    'codEmpresa': CommonSchemas.integerSchema,
    'codExpedicaoCarrinhoRotaEstagio': CommonSchemas.integerSchema,
    'codExpedicaoCarrinhoRota': CommonSchemas.integerSchema,
    'codEstagio': CommonSchemas.integerSchema,
    'nomeEstagio': CommonSchemas.nonEmptyStringSchema,
    'sequencia': CommonSchemas.integerSchema,
    'situacao': EnumSchemas.expeditionSituationSchema,
    'dataInicio': CommonSchemas.optionalDateTimeSchema,
    'horaInicio': CommonSchemas.optionalStringSchema,
    'dataFim': CommonSchemas.optionalDateTimeSchema,
    'horaFim': CommonSchemas.optionalStringSchema,
    'codUsuarioInicio': CommonSchemas.optionalIntegerSchema,
    'nomeUsuarioInicio': CommonSchemas.optionalStringSchema,
    'codUsuarioFim': CommonSchemas.optionalIntegerSchema,
    'nomeUsuarioFim': CommonSchemas.optionalStringSchema,
    'observacao': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados do estágio da rota
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do estágio da rota: $e';
    }
  }

  /// Validação segura para estágio da rota
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
