import 'package:exp/core/utils/app_logger.dart';
import 'package:exp/core/validation/schemas/model_schema/expedition_cancellation_schema.dart';
import 'package:exp/domain/models/expedition_cancellation_model.dart';

/// Exemplo demonstrando a validação de schema no ExpeditionCancellationModel
void main() {
  AppLogger.debug('🧪 Testando validação de schema no ExpeditionCancellationModel');
  AppLogger.debug('=' * 60);

  // === DADOS VÁLIDOS ===
  final validData = {
    'CodEmpresa': 1,
    'CodCancelamento': 123,
    'Origem': 'C', // Carrinho
    'CodOrigem': 456,
    'ItemOrigem': '00001',
    'CodMotivoCancelamento': 789,
    'DataCancelamento': '2024-01-15T10:30:00.000Z',
    'HoraCancelamento': '10:30:00',
    'CodUsuarioCancelamento': 101,
    'NomeUsuarioCancelamento': 'João Silva',
    'ObservacaoCancelamento': 'Cancelamento por solicitação do cliente',
  };

  // === TESTE COM DADOS VÁLIDOS ===
  AppLogger.debug('\n✅ Teste 1: Dados válidos');
  try {
    final model = ExpeditionCancellationModel.fromJson(validData);
    AppLogger.debug('  ✅ Modelo criado com sucesso: ${model.origemDescription}');
    AppLogger.debug('  📋 Detalhes: ${model.codCancelamento} - ${model.nomeUsuarioCancelamento}');
  } catch (e) {
    AppLogger.debug('  ❌ Erro inesperado: $e');
  }

  // === TESTE COM DADOS INVÁLIDOS ===
  AppLogger.debug('\n❌ Teste 2: Dados inválidos (origem inválida)');

  final invalidData1 = {
    'CodEmpresa': 1,
    'CodCancelamento': 123,
    'Origem': 'X', // Inválido: deve ser C, S, P, etc.
    'CodOrigem': 456,
    'ItemOrigem': '00001',
    'CodMotivoCancelamento': 789,
    'DataCancelamento': '2024-01-15T10:30:00.000Z',
    'HoraCancelamento': '10:30:00',
    'CodUsuarioCancelamento': 101,
    'NomeUsuarioCancelamento': 'João Silva',
    'ObservacaoCancelamento': 'Cancelamento por solicitação do cliente',
  };

  try {
    final model = ExpeditionCancellationModel.fromJson(invalidData1);
    AppLogger.debug('  ⚠️ Modelo criado quando deveria ter falhado: ${model.origemDescription}');
  } catch (e) {
    AppLogger.debug('  ✅ Erro esperado capturado: ${e.toString().split(':').last.trim()}');
  }

  // === TESTE COM DADOS INVÁLIDOS (DATA INVÁLIDA) ===
  AppLogger.debug('\n❌ Teste 3: Data inválida');

  final invalidData2 = {
    'CodEmpresa': 1,
    'CodCancelamento': 123,
    'Origem': 'C',
    'CodOrigem': 456,
    'ItemOrigem': '00001',
    'CodMotivoCancelamento': 789,
    'DataCancelamento': 'data-invalida', // Inválido
    'HoraCancelamento': '10:30:00',
    'CodUsuarioCancelamento': 101,
    'NomeUsuarioCancelamento': 'João Silva',
    'ObservacaoCancelamento': 'Cancelamento por solicitação do cliente',
  };

  try {
    final model = ExpeditionCancellationModel.fromJson(invalidData2);
    AppLogger.debug('  ⚠️ Modelo criado quando deveria ter falhado: ${model.origemDescription}');
  } catch (e) {
    AppLogger.debug('  ✅ Erro esperado capturado: ${e.toString().split(':').last.trim()}');
  }

  // === TESTE COM MÉTODO SEGURO ===
  AppLogger.debug('\n🛡️ Teste 4: Usando método fromJsonSafe com Result');

  final result1 = ExpeditionCancellationModel.fromJsonSafe(validData);
  result1.fold(
    (model) => AppLogger.debug('  ✅ Dados válidos: ${model.origemDescription} - ${model.nomeUsuarioCancelamento}'),
    (failure) => AppLogger.debug('  ❌ Erro inesperado: $failure'),
  );

  final result2 = ExpeditionCancellationModel.fromJsonSafe(invalidData1);
  result2.fold(
    (model) => AppLogger.debug('  ⚠️ Deveria ter falhado: ${model.origemDescription}'),
    (failure) => AppLogger.debug('  ✅ Erro capturado com Result: ${failure.toString().split(':').last.trim()}'),
  );

  // === TESTE COM NOME VAZIO ===
  AppLogger.debug('\n❌ Teste 5: Nome do usuário vazio');

  final invalidData3 = {
    'CodEmpresa': 1,
    'CodCancelamento': 123,
    'Origem': 'C',
    'CodOrigem': 456,
    'ItemOrigem': '00001',
    'CodMotivoCancelamento': 789,
    'DataCancelamento': '2024-01-15T10:30:00.000Z',
    'HoraCancelamento': '10:30:00',
    'CodUsuarioCancelamento': 101,
    'NomeUsuarioCancelamento': '', // Vazio
    'ObservacaoCancelamento': 'Cancelamento por solicitação do cliente',
  };

  final result3 = ExpeditionCancellationModel.fromJsonSafe(invalidData3);
  result3.fold(
    (model) => AppLogger.debug('  ⚠️ Deveria ter falhado com nome vazio'),
    (failure) => AppLogger.debug('  ✅ Erro de nome vazio capturado: ${failure.toString().split(':').last.trim()}'),
  );

  // === TESTE COM CAMPOS OPCIONAIS ===
  AppLogger.debug('\n✅ Teste 6: Campos opcionais (sem motivo e observação)');

  final dataWithOptionals = {
    'CodEmpresa': 1,
    'CodCancelamento': 124,
    'Origem': 'S', // Separação
    'CodOrigem': 457,
    'ItemOrigem': '00002',
    // 'CodMotivoCancelamento': null, // Opcional
    'DataCancelamento': '2024-01-15T11:00:00.000Z',
    'HoraCancelamento': '11:00:00',
    'CodUsuarioCancelamento': 102,
    'NomeUsuarioCancelamento': 'Maria Santos',
    // 'ObservacaoCancelamento': null, // Opcional
  };

  final result4 = ExpeditionCancellationModel.fromJsonSafe(dataWithOptionals);
  result4.fold(
    (model) => AppLogger.debug(
      '  ✅ Modelo com campos opcionais: ${model.origemDescription} - ${model.nomeUsuarioCancelamento}',
    ),
    (failure) => AppLogger.debug('  ❌ Erro inesperado: $failure'),
  );

  AppLogger.debug('\n🎉 Testes de validação concluídos!');
  AppLogger.debug('\n📋 Benefícios da validação com schema + Result:');
  AppLogger.debug('  ✅ Dados validados antes da criação do modelo');
  AppLogger.debug('  ✅ Erros claros e específicos');
  AppLogger.debug('  ✅ Método seguro (fromJsonSafe) usando Result do result_dart');
  AppLogger.debug('  ✅ Padrão consistente com o resto do projeto');
  AppLogger.debug('  ✅ Fold para tratamento elegante de sucesso/falha');
  AppLogger.debug('  ✅ Validação de enums (ExpeditionOrigem)');
  AppLogger.debug('  ✅ Validação de campos opcionais');
  AppLogger.debug('  ✅ Consistência garantida dos dados');
  AppLogger.debug('  ✅ Falha rápida em caso de dados inválidos');

  // === TESTE ADICIONAL COM SCHEMA DIRETO ===
  AppLogger.debug('\n🔧 Teste adicional: Validação direta do schema');

  final schemaResult = ExpeditionCancellationSchema.safeValidate(validData);
  schemaResult.fold(
    (data) => AppLogger.debug('  ✅ Schema validado: ${data['Origem']} - ${data['NomeUsuarioCancelamento']}'),
    (failure) => AppLogger.debug('  ❌ Erro no schema: $failure'),
  );

  // === TESTE DE CONVERSÃO JSON ===
  AppLogger.debug('\n🔄 Teste 7: Conversão para JSON');

  final result5 = ExpeditionCancellationModel.fromJsonSafe(validData);
  result5.fold((model) {
    final json = model.toJson();
    AppLogger.debug('  ✅ Conversão para JSON: ${json['Origem']} - ${json['NomeUsuarioCancelamento']}');

    // Testar se o JSON é válido
    final result6 = ExpeditionCancellationModel.fromJsonSafe(json);
    result6.fold(
      (model2) => AppLogger.debug('  ✅ JSON válido - modelo recriado: ${model2.origemDescription}'),
      (failure) => AppLogger.debug('  ❌ JSON inválido: $failure'),
    );
  }, (failure) => AppLogger.debug('  ❌ Erro na conversão: $failure'));
}
