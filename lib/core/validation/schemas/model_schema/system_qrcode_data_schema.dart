import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';

class SystemQRCodeDataSchema {
  SystemQRCodeDataSchema._();

  static final schema = z.map({
    'CodUsuario': CommonSchemas.integerSchema,
    'NomeUsuario': CommonSchemas.nonEmptyStringSchema,
    'SenhaUsuario': z
        .string()
        .min(1, message: 'SenhaUsuario e obrigatorio')
        .min(4, message: 'SenhaUsuario deve ter pelo menos 4 caracteres'),
    'Ativo': EnumSchemas.optionalActiveStatusSchema,
    'CodEmpresa': CommonSchemas.integerSchema,
    'NomeEmpresa': z.string(),
    'PermiteSepararForaSequencia': EnumSchemas.optionalSituationSchema,
    'VisualizaTodasSeparacoes': EnumSchemas.optionalSituationSchema,
    'PermiteConferirForaSequencia': EnumSchemas.optionalSituationSchema,
    'VisualizaTodasConferencias': EnumSchemas.optionalSituationSchema,
    'PermiteArmazenarForaSequencia': EnumSchemas.optionalSituationSchema,
    'VisualizaTodasArmazenagem': EnumSchemas.optionalSituationSchema,
    'EditaCarrinhoOutroUsuario': EnumSchemas.optionalSituationSchema,
    'SalvaCarrinhoOutroUsuario': EnumSchemas.optionalSituationSchema,
    'ExcluiCarrinhoOutroUsuario': EnumSchemas.optionalSituationSchema,
    'ExpedicaoEntregaBalcaoPreVenda': EnumSchemas.optionalSituationSchema,
  });

  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validacao do QR Code do sistema: $e';
    }
  }

  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
