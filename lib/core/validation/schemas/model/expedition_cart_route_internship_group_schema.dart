import 'package:zard/zard.dart';
import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de ExpeditionCartRouteInternshipGroupModel
class ExpeditionCartRouteInternshipGroupSchema {
  ExpeditionCartRouteInternshipGroupSchema._();

  /// Schema para ExpeditionCartRouteInternshipGroupModel
  static final schema = z.map({
    'codEmpresa': CommonSchemas.integerSchema,
    'codExpedicaoCarrinhoRotaEstagioGrupo': CommonSchemas.integerSchema,
    'codExpedicaoCarrinhoRotaEstagio': CommonSchemas.integerSchema,
    'codGrupo': CommonSchemas.integerSchema,
    'nomeGrupo': CommonSchemas.nonEmptyStringSchema,
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
