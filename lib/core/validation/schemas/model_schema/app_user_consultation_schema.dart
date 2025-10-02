import 'package:zard/zard.dart';

import 'package:exp/core/validation/schemas/common_schemas.dart';
import 'package:exp/core/validation/schemas/enum_schemas.dart';
import 'package:exp/core/results/index.dart';

/// Schema para validação de AppUserConsultation
class AppUserConsultationSchema {
  AppUserConsultationSchema._();

  /// Schema para AppUserConsultation
  static final schema = z.map({
    'CodLoginApp': CommonSchemas.integerSchema,
    'Ativo': EnumSchemas.activeStatusSchema,
    'Nome': CommonSchemas.nonEmptyStringSchema,
    'CodUsuario': CommonSchemas.optionalIntegerSchema,
    'NomeUsuario': CommonSchemas.optionalStringSchema,
    'FotoUsuario': CommonSchemas.optionalStringSchema,
    'Email': CommonSchemas.optionalStringSchema,
    'Telefone': CommonSchemas.optionalStringSchema,
    'DataCriacao': CommonSchemas.optionalDateTimeSchema,
    'DataUltimoAcesso': CommonSchemas.optionalDateTimeSchema,
    'Observacao': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados de consulta do usuário
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta do usuário: $e';
    }
  }

  /// Validação segura para consulta do usuário
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
