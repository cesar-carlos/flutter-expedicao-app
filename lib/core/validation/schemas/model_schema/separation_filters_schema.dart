import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de filtros de separação
class SeparationFiltersSchema {
  SeparationFiltersSchema._();

  /// Schema para filtros de separação
  static final schema = z.map({
    'CodSepararEstoque': CommonSchemas.optionalCodeSchema,
    'Origem': EnumSchemas.optionalExpeditionOrigemSchema,
    'CodOrigem': CommonSchemas.optionalCodeSchema,
    'Situacao': EnumSchemas.optionalExpeditionSituationSchema,
    'DataEmissao': CommonSchemas.optionalDateTimeSchema,
    'TipoEntidade': EnumSchemas.optionalEntityTypeSchema,
    'CodEntidade': CommonSchemas.optionalIntegerSchema,
    'NomeEntidade': CommonSchemas.optionalStringSchema,
  });

  /// Valida filtros de separação
  static Map<String, dynamic> validate(Map<String, dynamic> filters) {
    try {
      return schema.parse(filters);
    } catch (e) {
      throw 'Erro na validação dos filtros de separação: $e';
    }
  }

  /// Validação segura para filtros
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> filters) {
    return safeCallSync(() => validate(filters));
  }
}
