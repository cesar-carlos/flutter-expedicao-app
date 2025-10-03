import 'package:zard/zard.dart';

import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de SeparateModel
class SeparateSchema {
  SeparateSchema._();

  /// Schema para SeparateModel
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSepararEstoque': CommonSchemas.integerSchema,
    'Origem': EnumSchemas.expeditionOrigemSchema,
    'CodOrigem': CommonSchemas.integerSchema,
    'CodTipoOperacaoExpedicao': CommonSchemas.integerSchema,
    'NomeTipoOperacaoExpedicao': CommonSchemas.nonEmptyStringSchema,
    'Situacao': EnumSchemas.expeditionSituationSchema,
    'TipoEntidade': EnumSchemas.entityTypeSchema,
    'DataEmissao': CommonSchemas.dateTimeSchema,
    'HoraEmissao': CommonSchemas.nonEmptyStringSchema,
    'CodEntidade': CommonSchemas.integerSchema,
    'NomeEntidade': CommonSchemas.nonEmptyStringSchema,
    'CodUsuarioEmissao': CommonSchemas.integerSchema,
    'NomeUsuarioEmissao': CommonSchemas.nonEmptyStringSchema,
    'CodPrioridade': CommonSchemas.integerSchema,
    'NomePrioridade': CommonSchemas.nonEmptyStringSchema,
    'Observacao': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados de separação
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da separação: $e';
    }
  }

  /// Validação segura para separação
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
