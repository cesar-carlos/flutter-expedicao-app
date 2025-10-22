import 'package:zard/zard.dart';
import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema de validação para UserSystemModel
class UserSystemModelSchema {
  UserSystemModelSchema._();

  /// Schema para UserSystemModel
  static final schema = z.map({
    'CodUsuario': CommonSchemas.integerSchema,
    'NomeUsuario': CommonSchemas.nonEmptyStringSchema,
    'Ativo': EnumSchemas.situationSchema,
    'CodEmpresa': CommonSchemas.optionalIntegerSchema,
    'NomeEmpresa': CommonSchemas.optionalStringSchema,
    'CodVendedor': CommonSchemas.optionalIntegerSchema,
    'NomeVendedor': CommonSchemas.optionalStringSchema,
    'CodLocalArmazenagem': CommonSchemas.optionalIntegerSchema,
    'NomeLocalArmazenagem': CommonSchemas.optionalStringSchema,
    'CodContaFinanceira': CommonSchemas.optionalStringSchema,
    'NomeContaFinanceira': CommonSchemas.optionalStringSchema,
    'NomeCaixaOperador': CommonSchemas.optionalStringSchema,
    'CodSetorEstoque': CommonSchemas.optionalIntegerSchema,
    'NomeSetorEstoque': CommonSchemas.optionalStringSchema,
    'PermiteSepararForaSequencia': EnumSchemas.situationSchema,
    'VisualizaTodasSeparacoes': EnumSchemas.situationSchema,
    'ExpedicaoObrigaEscanearPrateleira': EnumSchemas.situationSchema,
    'CodSetorConferencia': CommonSchemas.optionalIntegerSchema,
    'NomeSetorConferencia': CommonSchemas.optionalStringSchema,
    'PermiteConferirForaSequencia': EnumSchemas.situationSchema,
    'VisualizaTodasConferencias': EnumSchemas.situationSchema,
    'CodSetorArmazenagem': CommonSchemas.optionalIntegerSchema,
    'NomeSetorArmazenagem': CommonSchemas.optionalStringSchema,
    'PermiteArmazenarForaSequencia': EnumSchemas.situationSchema,
    'VisualizaTodasArmazenagem': EnumSchemas.situationSchema,
    'EditaCarrinhoOutroUsuario': EnumSchemas.situationSchema,
    'SalvaCarrinhoOutroUsuario': EnumSchemas.situationSchema,
    'ExcluiCarrinhoOutroUsuario': EnumSchemas.situationSchema,
    'ExpedicaoEntregaBalcaoPreVenda': EnumSchemas.situationSchema,
    'CodLoginApp': CommonSchemas.optionalIntegerSchema,
  });

  /// Valida dados do modelo de usuário do sistema
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação do modelo de usuário do sistema: $e';
    }
  }

  /// Validação segura para modelo de usuário do sistema
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
