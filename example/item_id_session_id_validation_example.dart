import 'package:exp/core/validation/index.dart';

/// Exemplo de uso dos novos schemas de validação para ItemId e SessionId
void main() {
  print('🧪 Testando schemas ItemId e SessionId');
  print('=' * 50);

  // === TESTANDO ITEM ID ===
  print('\n📝 Testando ItemId Schema:');

  // Casos válidos
  final validItemIds = ['00001', '12345', '99999', '00000', '1'];

  for (final itemId in validItemIds) {
    try {
      final result = CommonSchemas.itemIdSchema.parse(itemId);
      print('✅ ItemId "$itemId" → "$result" (válido)');
    } catch (e) {
      print('❌ ItemId "$itemId" → Erro: $e');
    }
  }

  // Casos inválidos
  final invalidItemIds = ['1234', '123456', 'abc12', '', '00abc'];

  print('\n❌ Casos inválidos:');
  for (final itemId in invalidItemIds) {
    try {
      final result = CommonSchemas.itemIdSchema.parse(itemId);
      print('⚠️ ItemId "$itemId" → "$result" (deveria ser inválido!)');
    } catch (e) {
      print('✅ ItemId "$itemId" → Erro esperado: ${e.toString().split(':').last.trim()}');
    }
  }

  // === TESTANDO SESSION ID ===
  print('\n🔗 Testando SessionId Schema:');

  // Casos válidos
  final validSessionIds = ['abc123', 'socket_id_123', 'user-session-456', 'ABC_123-xyz', '1234567890'];

  for (final sessionId in validSessionIds) {
    try {
      CommonSchemas.sessionIdSchema.parse(sessionId);
      print('✅ SessionId "$sessionId" → válido');
    } catch (e) {
      print('❌ SessionId "$sessionId" → Erro: $e');
    }
  }

  // Casos inválidos
  final invalidSessionIds = ['', 'session@123', 'id with spaces', 'session#id', 'id.with.dots'];

  print('\n❌ Casos inválidos:');
  for (final sessionId in invalidSessionIds) {
    try {
      CommonSchemas.sessionIdSchema.parse(sessionId);
      print('⚠️ SessionId "$sessionId" → válido (deveria ser inválido!)');
    } catch (e) {
      print('✅ SessionId "$sessionId" → Erro esperado: ${e.toString().split(':').last.trim()}');
    }
  }

  // === EXEMPLO PRÁTICO ===
  print('\n🔧 Exemplo prático de uso:');

  try {
    // Simular dados de entrada
    final inputData = {
      'item': '123', // Será padded para '00123'
      'sessionId': 'socket_abc123',
    };

    // Validar e transformar
    final validatedItem = CommonSchemas.itemIdSchema.parse(inputData['item']);
    final validatedSessionId = CommonSchemas.sessionIdSchema.parse(inputData['sessionId']);

    print('✅ Dados validados:');
    print('   Item: "${inputData['item']}" → "$validatedItem"');
    print('   SessionId: "${inputData['sessionId']}" → "$validatedSessionId"');

    // Validar item especial '00000' (usado pela API)
    final apiItem = CommonSchemas.itemIdSchema.parse('00000');
    print('   Item API: "00000" → "$apiItem" (permitido para API)');
  } catch (e) {
    print('❌ Erro na validação: $e');
  }

  print('\n✅ Testes concluídos!');
}
