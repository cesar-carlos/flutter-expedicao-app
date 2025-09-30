import 'package:flutter_test/flutter_test.dart';

import 'package:exp/domain/models/expedition_item_situation_model.dart';
import 'package:exp/data/repositories/separation_item_repository_impl.dart';
import 'package:exp/domain/models/separation_item_model.dart';

import '../../mocks/separation_item_model_mock.dart';
import '../../core/socket_integration_test_base.dart';

void main() {
  group('SeparationItemRepositoryImpl Integration Tests', () {
    late SeparationItemRepositoryImpl repository;
    late SeparationItemModel insertedSeparationItem;

    setUpAll(() async {
      await SocketIntegrationTestBase.setupSocket();
    });

    setUp(() {
      repository = SeparationItemRepositoryImpl();
    });

    tearDownAll(() async {
      await SocketIntegrationTestBase.tearDownSocket();
    });

    group('INSERT Integration Tests', () {
      test('deve inserir um novo item de separação e verificar se foi inserido', () async {
        // Cria um novo item de separação para teste
        final newItem = createDefaultTestSeparationItem();

        // Tenta inserir o item de separação
        final insertResult = await repository.insert(newItem);

        // Verifica o resultado
        expect(insertResult, isNotEmpty, reason: 'O resultado da inserção não deve estar vazio');
        expect(insertResult.first.item, newItem.item, reason: 'O número do item deve corresponder ao enviado');
        expect(insertResult.first.sessionId, newItem.sessionId, reason: 'O sessionId deve corresponder ao enviado');
        expect(
          insertResult.first.situacaoCode,
          ExpeditionItemSituation.pendente.code,
          reason: 'A situação inicial deve ser PENDENTE',
        );
        expect(insertResult.first.codProduto, 1, reason: 'O código do produto deve ser 1');
        expect(insertResult.first.quantidade, 1.0, reason: 'A quantidade deve ser 1.0');
        expect(
          insertResult.first.nomeSeparador,
          'TESTE SEPARADOR',
          reason: 'O nome do separador deve corresponder ao enviado',
        );

        // Guarda o item inserido para os próximos testes
        insertedSeparationItem = insertResult.first;

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('UPDATE Integration Tests', () {
      test('deve atualizar o item de separação inserido anteriormente', () async {
        // Cria uma versão atualizada do item de separação
        final updatedItem = createUpdatedTestSeparationItem(insertedSeparationItem);

        // Tenta atualizar o item de separação
        final updateResult = await repository.update(updatedItem);

        // Verifica o resultado
        expect(updateResult, isNotEmpty, reason: 'O resultado da atualização não deve estar vazio');
        expect(
          updateResult.first.codSepararEstoque,
          insertedSeparationItem.codSepararEstoque,
          reason: 'O código da separação deve permanecer o mesmo',
        );
        expect(
          updateResult.first.item,
          insertedSeparationItem.item,
          reason: 'O número do item deve permanecer o mesmo',
        );
        expect(
          updateResult.first.situacaoCode,
          ExpeditionItemSituation.separado.code,
          reason: 'A situação deve ter sido alterada para SEPARADO',
        );
        expect(
          updateResult.first.nomeSeparador,
          'SEPARADOR ATUALIZADO',
          reason: 'O nome do separador deve ter sido atualizado',
        );
        expect(
          updateResult.first.codProduto,
          insertedSeparationItem.codProduto,
          reason: 'O código do produto deve permanecer o mesmo',
        );

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('DELETE Integration Tests', () {
      test('deve deletar o item de separação inserido anteriormente', () async {
        // Tenta deletar o item de separação
        final deleteResult = await repository.delete(insertedSeparationItem);

        // Verifica o resultado
        expect(deleteResult, isNotEmpty, reason: 'O resultado da deleção não deve estar vazio');
        expect(
          deleteResult.first.codSepararEstoque,
          insertedSeparationItem.codSepararEstoque,
          reason: 'O código da separação deletada deve corresponder',
        );
        expect(deleteResult.first.item, insertedSeparationItem.item, reason: 'O número do item deve corresponder');
        expect(
          deleteResult.first.codProduto,
          insertedSeparationItem.codProduto,
          reason: 'O código do produto deve corresponder',
        );
        expect(deleteResult.first.quantidade, 1.0, reason: 'A quantidade deve permanecer a mesma');

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });
  });
}
