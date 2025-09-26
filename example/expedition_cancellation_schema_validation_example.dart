import 'package:exp/domain/models/expedition_cancellation_model.dart';
import 'package:exp/core/validation/schemas/model/expedition_cancellation_schema.dart';

/// Exemplo demonstrando a validação de schema no ExpeditionCancellationModel
void main() {
  print('🧪 Testando validação de schema no ExpeditionCancellationModel');
  print('=' * 60);

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
  print('\n✅ Teste 1: Dados válidos');
  try {
    final model = ExpeditionCancellationModel.fromJson(validData);
    print('  ✅ Modelo criado com sucesso: ${model.origemDescription}');
    print('  📋 Detalhes: ${model.codCancelamento} - ${model.nomeUsuarioCancelamento}');
  } catch (e) {
    print('  ❌ Erro inesperado: $e');
  }

  // === TESTE COM DADOS INVÁLIDOS ===
  print('\n❌ Teste 2: Dados inválidos (origem inválida)');

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
    print('  ⚠️ Modelo criado quando deveria ter falhado: ${model.origemDescription}');
  } catch (e) {
    print('  ✅ Erro esperado capturado: ${e.toString().split(':').last.trim()}');
  }

  // === TESTE COM DADOS INVÁLIDOS (DATA INVÁLIDA) ===
  print('\n❌ Teste 3: Data inválida');

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
    print('  ⚠️ Modelo criado quando deveria ter falhado: ${model.origemDescription}');
  } catch (e) {
    print('  ✅ Erro esperado capturado: ${e.toString().split(':').last.trim()}');
  }

  // === TESTE COM MÉTODO SEGURO ===
  print('\n🛡️ Teste 4: Usando método fromJsonSafe com Result');

  final result1 = ExpeditionCancellationModel.fromJsonSafe(validData);
  result1.fold(
    (model) => print('  ✅ Dados válidos: ${model.origemDescription} - ${model.nomeUsuarioCancelamento}'),
    (failure) => print('  ❌ Erro inesperado: $failure'),
  );

  final result2 = ExpeditionCancellationModel.fromJsonSafe(invalidData1);
  result2.fold(
    (model) => print('  ⚠️ Deveria ter falhado: ${model.origemDescription}'),
    (failure) => print('  ✅ Erro capturado com Result: ${failure.toString().split(':').last.trim()}'),
  );

  // === TESTE COM NOME VAZIO ===
  print('\n❌ Teste 5: Nome do usuário vazio');

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
    (model) => print('  ⚠️ Deveria ter falhado com nome vazio'),
    (failure) => print('  ✅ Erro de nome vazio capturado: ${failure.toString().split(':').last.trim()}'),
  );

  // === TESTE COM CAMPOS OPCIONAIS ===
  print('\n✅ Teste 6: Campos opcionais (sem motivo e observação)');

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
    (model) => print('  ✅ Modelo com campos opcionais: ${model.origemDescription} - ${model.nomeUsuarioCancelamento}'),
    (failure) => print('  ❌ Erro inesperado: $failure'),
  );

  print('\n🎉 Testes de validação concluídos!');
  print('\n📋 Benefícios da validação com schema + Result:');
  print('  ✅ Dados validados antes da criação do modelo');
  print('  ✅ Erros claros e específicos');
  print('  ✅ Método seguro (fromJsonSafe) usando Result do result_dart');
  print('  ✅ Padrão consistente com o resto do projeto');
  print('  ✅ Fold para tratamento elegante de sucesso/falha');
  print('  ✅ Validação de enums (ExpeditionOrigem)');
  print('  ✅ Validação de campos opcionais');
  print('  ✅ Consistência garantida dos dados');
  print('  ✅ Falha rápida em caso de dados inválidos');

  // === TESTE ADICIONAL COM SCHEMA DIRETO ===
  print('\n🔧 Teste adicional: Validação direta do schema');

  final schemaResult = ExpeditionCancellationSchema.safeValidate(validData);
  schemaResult.fold(
    (data) => print('  ✅ Schema validado: ${data['Origem']} - ${data['NomeUsuarioCancelamento']}'),
    (failure) => print('  ❌ Erro no schema: $failure'),
  );

  // === TESTE DE CONVERSÃO JSON ===
  print('\n🔄 Teste 7: Conversão para JSON');

  final result5 = ExpeditionCancellationModel.fromJsonSafe(validData);
  result5.fold((model) {
    final json = model.toJson();
    print('  ✅ Conversão para JSON: ${json['Origem']} - ${json['NomeUsuarioCancelamento']}');

    // Testar se o JSON é válido
    final result6 = ExpeditionCancellationModel.fromJsonSafe(json);
    result6.fold(
      (model2) => print('  ✅ JSON válido - modelo recriado: ${model2.origemDescription}'),
      (failure) => print('  ❌ JSON inválido: $failure'),
    );
  }, (failure) => print('  ❌ Erro na conversão: $failure'));
}
