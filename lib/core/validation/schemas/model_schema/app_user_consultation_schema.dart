import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class AppUserConsultationSchema {
  AppUserConsultationSchema._();

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

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta do usuário: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
