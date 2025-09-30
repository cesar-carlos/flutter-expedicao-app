import 'package:flutter_test/flutter_test.dart';

import 'package:exp/domain/models/expedition_sector_stock_model.dart';
import 'package:exp/data/repositories/expedition_sector_stock_repository_impl.dart';
import '../../mocks/expedition_sector_stock_model_mock.dart';
import '../../core/socket_integration_test_base.dart';

void main() {
  group('ExpeditionSectorStockRepositoryImpl Integration Tests', () {
    late ExpeditionSectorStockRepositoryImpl repository;
    late ExpeditionSectorStockModel insertedSectorStock;

    setUpAll(() async {
      await SocketIntegrationTestBase.setupSocket();
    });

    setUp(() {
      repository = ExpeditionSectorStockRepositoryImpl();
    });

    tearDownAll(() async {
      await SocketIntegrationTestBase.tearDownSocket();
    });

    group('INSERT Test', () {
      test('deve inserir um novo setor de estoque e verificar se foi inserido', () async {
        // Cria um novo setor de estoque para teste
        final newSectorStock = createDefaultTestSectorStock();

        // Tenta inserir o setor de estoque
        final insertResult = await repository.insert(newSectorStock);

        // Verifica o resultado
        expect(insertResult, isNotEmpty, reason: 'O resultado da inserção não deve estar vazio');
        expect(
          insertResult.first.descricao,
          newSectorStock.descricao,
          reason: 'A descrição do setor inserido deve corresponder ao enviado',
        );
        expect(insertResult.first.ativoCode, 'S', reason: 'O setor deve ser inserido como ativo (S)');
        expect(insertResult.first.ativoDescription, 'Sim', reason: 'A descrição do status deve ser "Sim"');

        // Guarda o setor inserido para os próximos testes
        insertedSectorStock = insertResult.first;

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('UPDATE Test', () {
      test('deve atualizar o setor de estoque inserido anteriormente', () async {
        // Cria uma versão atualizada do setor de estoque
        final updatedSectorStock = createUpdatedTestSectorStock(insertedSectorStock);

        // Tenta atualizar o setor de estoque
        final updateResult = await repository.update(updatedSectorStock);

        // Verifica o resultado
        expect(updateResult, isNotEmpty, reason: 'O resultado da atualização não deve estar vazio');
        expect(
          updateResult.first.codSetorEstoque,
          insertedSectorStock.codSetorEstoque,
          reason: 'O código do setor deve permanecer o mesmo',
        );
        expect(updateResult.first.ativoCode, 'N', reason: 'O status deve ter sido alterado para inativo (N)');

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('DELETE Test', () {
      test('deve deletar o setor de estoque inserido anteriormente', () async {
        // Tenta deletar o setor de estoque
        final deleteResult = await repository.delete(insertedSectorStock);

        // Verifica o resultado
        expect(deleteResult, isNotEmpty, reason: 'O resultado da deleção não deve estar vazio');
        expect(
          deleteResult.first.codSetorEstoque,
          insertedSectorStock.codSetorEstoque,
          reason: 'O código do setor deletado deve corresponder',
        );
        expect(
          deleteResult.first.descricao,
          insertedSectorStock.descricao,
          reason: 'A descrição do setor deletado deve corresponder',
        );
        expect(deleteResult.first.ativoCode, isA<String>(), reason: 'Deve retornar um código de status válido');

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });
  });
}
