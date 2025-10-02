import 'package:exp/domain/models/expedition_cart_model.dart';
import 'package:exp/core/validation/schemas/model_schema/expedition_cart_schema.dart';

/// Exemplo demonstrando a validação de schema no ExpeditionCartModel
void main() {
  print('🧪 Testando validação de schema no ExpeditionCartModel');
  print('=' * 60);

  // === TESTE COM DADOS VÁLIDOS ===
  print('\n✅ Teste 1: Dados válidos');

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
    print('  📋 Schema validado: ${validatedData['Descricao']}');

    // Testar criação do modelo com validação
    final model = ExpeditionCartModel.fromJson(validData);
    print('  🏗️ Modelo criado: ${model.descricao}');
    print('  📊 Status: ${model.ativoDescription}');
    print('  📦 Situação: ${model.situacaoDescription}');
  } catch (e) {
    print('  ❌ Erro inesperado: $e');
  }

  // === TESTE COM DADOS INVÁLIDOS ===
  print('\n❌ Teste 2: Dados inválidos (CodEmpresa negativo)');

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
    print('  ⚠️ Modelo criado quando deveria ter falhado: ${model.descricao}');
  } catch (e) {
    print('  ✅ Erro esperado capturado: ${e.toString().split(':').last.trim()}');
  }

  // === TESTE COM CAMPOS FALTANDO ===
  print('\n❌ Teste 3: Campos obrigatórios faltando');

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
    print('  ⚠️ Modelo criado quando deveria ter falhado: ${model.descricao}');
  } catch (e) {
    print('  ✅ Erro esperado capturado: ${e.toString().split(':').last.trim()}');
  }

  // === TESTE COM MÉTODO SEGURO ===
  print('\n🛡️ Teste 4: Usando método fromJsonSafe com Result');

  final result1 = ExpeditionCartModel.fromJsonSafe(validData);
  result1.fold(
    (model) => print('  ✅ Dados válidos: ${model.descricao}'),
    (failure) => print('  ❌ Erro inesperado: $failure'),
  );

  final result2 = ExpeditionCartModel.fromJsonSafe(invalidData1);
  result2.fold(
    (model) => print('  ⚠️ Deveria ter falhado: ${model.descricao}'),
    (failure) => print('  ✅ Erro capturado com Result: ${failure.toString().split(':').last.trim()}'),
  );

  // === TESTE COM DESCRIÇÃO VAZIA ===
  print('\n❌ Teste 5: Descrição vazia');

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
    (model) => print('  ⚠️ Deveria ter falhado com descrição vazia'),
    (failure) => print('  ✅ Erro de descrição vazia capturado: ${failure.toString().split(':').last.trim()}'),
  );

  // === TESTE COM STATUS INVÁLIDO ===
  print('\n❌ Teste 6: Status ativo inválido');

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
    (model) => print('  ⚠️ Deveria ter falhado com status inválido'),
    (failure) => print('  ✅ Erro de status inválido capturado: ${failure.toString().split(':').last.trim()}'),
  );

  print('\n🎉 Testes de validação concluídos!');
  print('\n📋 Benefícios da validação com schema + Result:');
  print('  ✅ Dados validados antes da criação do modelo');
  print('  ✅ Erros claros e específicos');
  print('  ✅ Método seguro (fromJsonSafe) usando Result do result_dart');
  print('  ✅ Padrão consistente com o resto do projeto');
  print('  ✅ Fold para tratamento elegante de sucesso/falha');
  print('  ✅ Consistência garantida dos dados');
  print('  ✅ Falha rápida em caso de dados inválidos');

  // === TESTE ADICIONAL COM SCHEMA DIRETO ===
  print('\n🔧 Teste adicional: Validação direta do schema');

  final schemaResult = ExpeditionCartSchema.safeValidate(validData);
  schemaResult.fold(
    (data) => print('  ✅ Schema validado: ${data['Descricao']}'),
    (failure) => print('  ❌ Erro no schema: $failure'),
  );
}
