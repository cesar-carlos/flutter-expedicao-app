import 'package:flutter_test/flutter_test.dart';

import '../../mocks/separate_item_model_mock.dart';
import 'package:exp/data/repositories/separate_item_repository_impl.dart';
import 'package:exp/domain/models/separate_item_model.dart';
import '../../core/socket_integration_test_base.dart';

void main() {
  group('SeparateItemRepositoryImpl Integration Tests', () {
    late SeparateItemRepositoryImpl repository;
    late SeparateItemModel insertedSeparateItem;

    setUpAll(() async {
      await SocketIntegrationTestBase.setupSocket();
    });

    setUp(() {
      repository = SeparateItemRepositoryImpl();
    });

    tearDownAll(() async {
      await SocketIntegrationTestBase.tearDownSocket();
    });

    group('INSERT Integration Tests', () {
      test('deve inserir um novo item de separação e verificar se foi inserido', () async {
        // Cria um novo item para teste
        final newItem = createDefaultTestItem();

        // Tenta inserir o item
        final insertResult = await repository.insert(newItem);

        // Verifica o resultado
        expect(insertResult, isNotEmpty, reason: 'O resultado da inserção não deve estar vazio');
        expect(insertResult.first.item, newItem.item, reason: 'O número do item deve corresponder ao enviado');
        expect(insertResult.first.codProduto, 1, reason: 'O código do produto deve ser 1');
        expect(insertResult.first.quantidade, 40.0, reason: 'A quantidade total deve ser 40.0');
        expect(insertResult.first.quantidadeInterna, 40.0, reason: 'A quantidade interna inicial deve ser 40.0');
        expect(insertResult.first.quantidadeExterna, 0.0, reason: 'A quantidade externa inicial deve ser 0.0');
        expect(insertResult.first.quantidadeSeparacao, 0.0, reason: 'A quantidade de separação inicial deve ser 0.0');

        // Guarda o item inserido para os próximos testes
        insertedSeparateItem = insertResult.first;

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('UPDATE Integration Tests', () {
      test('deve atualizar o item de separação inserido anteriormente', () async {
        // Cria uma versão atualizada do item
        final updatedItem = createUpdatedTestItem(insertedSeparateItem);

        // Tenta atualizar o item
        final updateResult = await repository.update(updatedItem);

        // Verifica o resultado
        expect(updateResult, isNotEmpty, reason: 'O resultado da atualização não deve estar vazio');
        expect(
          updateResult.first.codSepararEstoque,
          insertedSeparateItem.codSepararEstoque,
          reason: 'O código da separação deve permanecer o mesmo',
        );
        expect(updateResult.first.item, insertedSeparateItem.item, reason: 'O número do item deve permanecer o mesmo');
        expect(
          updateResult.first.quantidadeSeparacao,
          40.0,
          reason: 'A quantidade de separação deve ser atualizada para 40.0',
        );
        expect(updateResult.first.quantidadeInterna, 0.0, reason: 'A quantidade interna deve ser zerada');
        expect(
          updateResult.first.quantidadeExterna,
          35.0,
          reason: 'A quantidade externa deve ser atualizada para 35.0',
        );
        expect(
          updateResult.first.codProduto,
          insertedSeparateItem.codProduto,
          reason: 'O código do produto deve permanecer o mesmo',
        );

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('DELETE Integration Tests', () {
      test('deve deletar o item de separação inserido anteriormente', () async {
        // Tenta deletar o item
        final deleteResult = await repository.delete(insertedSeparateItem);

        // Verifica o resultado
        expect(deleteResult, isNotEmpty, reason: 'O resultado da deleção não deve estar vazio');
        expect(
          deleteResult.first.codSepararEstoque,
          insertedSeparateItem.codSepararEstoque,
          reason: 'O código da separação deletada deve corresponder',
        );
        expect(deleteResult.first.item, insertedSeparateItem.item, reason: 'O número do item deve corresponder');
        expect(
          deleteResult.first.codProduto,
          insertedSeparateItem.codProduto,
          reason: 'O código do produto deve corresponder',
        );

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });
  });
}
