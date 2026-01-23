import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

class SeparationUserSectorConsultationSchema {
  SeparationUserSectorConsultationSchema._();

  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSepararEstoque': CommonSchemas.integerSchema,
    'SepararEstoqueSituacao': EnumSchemas.expeditionSituationSchema,
    'CodSetorEstoque': CommonSchemas.integerSchema,
    'DescricaoSetorEstoque': CommonSchemas.nonEmptyStringSchema,
    'CodPrioridade': CommonSchemas.integerSchema,
    'DescricaoPrioridade': CommonSchemas.nonEmptyStringSchema,
    'Prioridade': CommonSchemas.integerSchema,
    'QuantidadeItens': CommonSchemas.quantitySchema,
    'QuantidadeItensSeparacao': CommonSchemas.quantitySchema,
    'QuantidadeItensSetor': CommonSchemas.quantitySchema,
    'QuantidadeItensSeparacaoSetor': CommonSchemas.quantitySchema,
    'CarrinhosAbertosUsuario': CommonSchemas.nonEmptyStringSchema,
    'CodUsuario': CommonSchemas.optionalIntegerSchema,
    'NomeUsuario': CommonSchemas.optionalStringSchema,
    'EstacaoSeparacao': CommonSchemas.optionalStringSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta de separação por usuário e setor: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
