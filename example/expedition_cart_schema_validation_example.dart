import 'package:exp/core/utils/app_logger.dart';
import 'package:exp/core/validation/schemas/model_schema/expedition_cart_schema.dart';
import 'package:exp/domain/models/expedition_cart_model.dart';

/// Exemplo demonstrando a validação de schema no ExpeditionCartModel
void main() {
  AppLogger.debug('🧪 Testando validação de schema no ExpeditionCartModel');
  AppLogger.debug('=' * 60);

  // === TESTE COM DADOS VÁLIDOS ===
  AppLogger.debug('\n✅ Teste 1: Dados válidos');

  final validData = {
    'CodEmpresa': 1,
    'CodCarrinho': 123,
    'Descricao': 'Carrinho de Teste',
    'Ativo': 'S',
    'CodigoBarras': '123456789',
    'Situacao': 'V',
  };

  try {
    // Testar validação do schema diretamente
    final validatedData = ExpeditionCartSchema.validate(validData);
    AppLogger.debug('  📋 Schema validado: ${validatedData['Descricao']}');

    // Testar criação do modelo com validação
    final model = ExpeditionCartModel.fromJson(validData);
    AppLogger.debug('  🏗️ Modelo criado: ${model.descricao}');
    AppLogger.debug('  📊 Status: ${model.ativoDescription}');
    AppLogger.debug('  📦 Situação: ${model.situacaoDescription}');
  } catch (e) {
    AppLogger.debug('  ❌ Erro inesperado: $e');
  }

  // === TESTE COM DADOS INVÁLIDOS ===
  AppLogger.debug('\n❌ Teste 2: Dados inválidos (CodEmpresa negativo)');

  final invalidData1 = {
    'CodEmpresa': -1, // Inválido: deve ser > 0
    'CodCarrinho': 123,
    'Descricao': 'Carrinho Inválido',
    'Ativo': 'S',
    'CodigoBarras': '123456789',
    'Situacao': 'V',
  };

  try {
    final model = ExpeditionCartModel.fromJson(invalidData1);
    AppLogger.debug('  ⚠️ Modelo criado quando deveria ter falhado: ${model.descricao}');
  } catch (e) {
    AppLogger.debug('  ✅ Erro esperado capturado: ${e.toString().split(':').last.trim()}');
  }

  // === TESTE COM CAMPOS FALTANDO ===
  AppLogger.debug('\n❌ Teste 3: Campos obrigatórios faltando');

  final invalidData2 = {
    'CodEmpresa': 1,
    // 'CodCarrinho': 123, // Faltando campo obrigatório
    'Descricao': 'Carrinho Sem Código',
    'Ativo': 'S',
    'CodigoBarras': '123456789',
    'Situacao': 'V',
  };

  try {
    final model = ExpeditionCartModel.fromJson(invalidData2);
    AppLogger.debug('  ⚠️ Modelo criado quando deveria ter falhado: ${model.descricao}');
  } catch (e) {
    AppLogger.debug('  ✅ Erro esperado capturado: ${e.toString().split(':').last.trim()}');
  }

  // === TESTE COM MÉTODO SEGURO ===
  AppLogger.debug('\n🛡️ Teste 4: Usando método fromJsonSafe com Result');

  final result1 = ExpeditionCartModel.fromJsonSafe(validData);
  result1.fold(
    (model) => AppLogger.debug('  ✅ Dados válidos: ${model.descricao}'),
    (failure) => AppLogger.debug('  ❌ Erro inesperado: $failure'),
  );

  final result2 = ExpeditionCartModel.fromJsonSafe(invalidData1);
  result2.fold(
    (model) => AppLogger.debug('  ⚠️ Deveria ter falhado: ${model.descricao}'),
    (failure) => AppLogger.debug('  ✅ Erro capturado com Result: ${failure.toString().split(':').last.trim()}'),
  );

  // === TESTE COM DESCRIÇÃO VAZIA ===
  AppLogger.debug('\n❌ Teste 5: Descrição vazia');

  final invalidData3 = {
    'CodEmpresa': 1,
    'CodCarrinho': 123,
    'Descricao': '', // Inválido: não pode estar vazia
    'Ativo': 'S',
    'CodigoBarras': '123456789',
    'Situacao': 'V',
  };

  final result3 = ExpeditionCartModel.fromJsonSafe(invalidData3);
  result3.fold(
    (model) => AppLogger.debug('  ⚠️ Deveria ter falhado com descrição vazia'),
    (failure) => AppLogger.debug('  ✅ Erro de descrição vazia capturado: ${failure.toString().split(':').last.trim()}'),
  );

  // === TESTE COM STATUS INVÁLIDO ===
  AppLogger.debug('\n❌ Teste 6: Status ativo inválido');

  final invalidData4 = {
    'CodEmpresa': 1,
    'CodCarrinho': 123,
    'Descricao': 'Carrinho Teste',
    'Ativo': 'X', // Inválido: deve ser S ou N
    'CodigoBarras': '123456789',
    'Situacao': 'V',
  };

  final result4 = ExpeditionCartModel.fromJsonSafe(invalidData4);
  result4.fold(
    (model) => AppLogger.debug('  ⚠️ Deveria ter falhado com status inválido'),
    (failure) => AppLogger.debug('  ✅ Erro de status inválido capturado: ${failure.toString().split(':').last.trim()}'),
  );

  AppLogger.debug('\n🎉 Testes de validação concluídos!');
  AppLogger.debug('\n📋 Benefícios da validação com schema + Result:');
  AppLogger.debug('  ✅ Dados validados antes da criação do modelo');
  AppLogger.debug('  ✅ Erros claros e específicos');
  AppLogger.debug('  ✅ Método seguro (fromJsonSafe) usando Result do result_dart');
  AppLogger.debug('  ✅ Padrão consistente com o resto do projeto');
  AppLogger.debug('  ✅ Fold para tratamento elegante de sucesso/falha');
  AppLogger.debug('  ✅ Consistência garantida dos dados');
  AppLogger.debug('  ✅ Falha rápida em caso de dados inválidos');

  // === TESTE ADICIONAL COM SCHEMA DIRETO ===
  AppLogger.debug('\n🔧 Teste adicional: Validação direta do schema');

  final schemaResult = ExpeditionCartSchema.safeValidate(validData);
  schemaResult.fold(
    (data) => AppLogger.debug('  ✅ Schema validado: ${data['Descricao']}'),
    (failure) => AppLogger.debug('  ❌ Erro no schema: $failure'),
  );
}
