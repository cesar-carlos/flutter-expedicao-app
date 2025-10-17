import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de ExpeditionCartRouteInternshipModel
class ExpeditionCartRouteInternshipSchema {
  ExpeditionCartRouteInternshipSchema._();

  /// Schema para ExpeditionCartRouteInternshipModel
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodExpedicaoCarrinhoRotaEstagio': CommonSchemas.integerSchema,
    'CodExpedicaoCarrinhoRota': CommonSchemas.integerSchema,
    'CodEstagio': CommonSchemas.integerSchema,
    'NomeEstagio': CommonSchemas.nonEmptyStringSchema,
    'Sequencia': CommonSchemas.integerSchema,
    'Situacao': EnumSchemas.expeditionSituationSchema,
    'DataInicio': CommonSchemas.optionalDateTimeSchema,
    'HoraInicio': CommonSchemas.optionalStringSchema,
    'DataFim': CommonSchemas.optionalDateTimeSchema,
    'HoraFim': CommonSchemas.optionalStringSchema,
    'CodUsuarioInicio': CommonSchemas.optionalIntegerSchema,
    'NomeUsuarioInicio': CommonSchemas.optionalStringSchema,
    'CodUsuarioFim': CommonSchemas.optionalIntegerSchema,
    'NomeUsuarioFim': CommonSchemas.optionalStringSchema,
    'Observacao': CommonSchemas.optionalStringSchema,
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
