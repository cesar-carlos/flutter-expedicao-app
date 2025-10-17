import 'package:zard/zard.dart';
import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/validation/schemas/enum_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de ExpeditionCheckCartConsultationModel
class ExpeditionCheckCartConsultationSchema {
  ExpeditionCheckCartConsultationSchema._();

  /// Schema para ExpeditionCheckCartConsultationModel
  /// Baseado nos campos reais do modelo
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodConferir': CommonSchemas.integerSchema,
    'Origem': EnumSchemas.expeditionOrigemSchema,
    'CodOrigem': CommonSchemas.integerSchema,
    'Situacao': EnumSchemas.expeditionCartRouterSituationSchema,
    'CodCarrinhoPercurso': CommonSchemas.integerSchema,
    'ItemCarrinhoPercurso': CommonSchemas.nonEmptyStringSchema,
    'CodPrioridade': CommonSchemas.integerSchema,
    'NomePrioridade': CommonSchemas.nonEmptyStringSchema,
    'CodCarrinho': CommonSchemas.integerSchema,
    'NomeCarrinho': CommonSchemas.nonEmptyStringSchema,
    'CodigoBarrasCarrinho': CommonSchemas.nonEmptyStringSchema,
    'SituacaoCarrinhoConferencia': EnumSchemas.expeditionCartSituationSchema,
    'DataInicioPercurso': CommonSchemas.dateTimeSchema,
    'HoraInicioPercurso': CommonSchemas.nonEmptyStringSchema,
    'CodPercursoEstagio': CommonSchemas.integerSchema,
    'NomePercursoEstagio': CommonSchemas.nonEmptyStringSchema,
    'CodUsuarioInicioEstagio': CommonSchemas.integerSchema,
    'NomeUsuarioInicioEstagio': CommonSchemas.nonEmptyStringSchema,
    'DataInicioEstagio': CommonSchemas.dateTimeSchema,
    'HoraInicioEstagio': CommonSchemas.nonEmptyStringSchema,
    'CodUsuarioFinalizacaoEstagio': CommonSchemas.integerSchema,
    'NomeUsuarioFinalizacaoEstagio': CommonSchemas.nonEmptyStringSchema,
    'DataFinalizacaoEstagio': CommonSchemas.dateTimeSchema,
    'HoraFinalizacaoEstagio': CommonSchemas.nonEmptyStringSchema,
    'TotalItemConferir': CommonSchemas.quantitySchema,
    'TotalItemConferido': CommonSchemas.quantitySchema,
  });

  /// Valida dados de consulta de carrinho de conferência de expedição
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da consulta de carrinho de conferência de expedição: $e';
    }
  }

  /// Validação segura para consulta de carrinho de conferência de expedição
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
