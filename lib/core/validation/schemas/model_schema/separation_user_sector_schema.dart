import 'package:zard/zard.dart';

import 'package:data7_expedicao/core/validation/schemas/common_schemas.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Schema para validação de SeparationUserSectorModel
class SeparationUserSectorSchema {
  SeparationUserSectorSchema._();

  /// Schema para SeparationUserSectorModel
  static final schema = z.map({
    'CodEmpresa': CommonSchemas.integerSchema,
    'CodSepararEstoque': CommonSchemas.integerSchema,
    'Item': CommonSchemas.nonEmptyStringSchema,
    'CodSetorEstoque': CommonSchemas.integerSchema,
    'DataLancamento': CommonSchemas.dateTimeSchema,
    'HoraLancamento': CommonSchemas.nonEmptyStringSchema,
    'CodUsuario': CommonSchemas.integerSchema,
    'NomeUsuario': CommonSchemas.nonEmptyStringSchema,
    'EstacaoSeparacao': CommonSchemas.optionalStringSchema,
  });

  /// Valida dados de separação por usuário e setor
  static Map<String, dynamic> validate(Map<String, dynamic> data) {
    try {
      return schema.parse(data);
    } catch (e) {
      throw 'Erro na validação da separação por usuário e setor: $e';
    }
  }

  /// Validação segura para separação por usuário e setor
  static Result<Map<String, dynamic>> safeValidate(Map<String, dynamic> data) {
    return safeCallSync(() => validate(data));
  }
}
