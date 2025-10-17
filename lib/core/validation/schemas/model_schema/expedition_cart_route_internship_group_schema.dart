import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de ExpeditionCartRouteInternshipGroupModel
class ExpeditionCartRouteInternshipGroupSchema {
  ExpeditionCartRouteInternshipGroupSchema._();

  /// Schema para ExpeditionCartRouteInternshipGroupModel
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodExpedicaoCarrinhoRotaEstagioGrupo': CommonSchemas.integerSchema,
    'CodExpedicaoCarrinhoRotaEstagio': CommonSchemas.integerSchema,
    'CodGrupo': CommonSchemas.integerSchema,
    'NomeGrupo': CommonSchemas.nonEmptyStringSchema,
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

  /// Valida dados do grupo do estágio
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do grupo do estágio: $e';
    }
  }

  /// Validação segura para grupo do estágio
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
