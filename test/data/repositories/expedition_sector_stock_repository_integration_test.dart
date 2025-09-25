import 'package:flutter_test/flutter_test.dart';

import 'package:exp/domain/models/api_config.dart';
import 'package:exp/domain/models/expedition_sector_stock_model.dart';
import 'package:exp/data/repositories/expedition_sector_stock_repository_impl.dart';
import '../../mocks/expedition_sector_stock_model_mock.dart';
import 'package:exp/core/network/socket_config.dart';

void main() {
  group('ExpeditionSectorStockRepositoryImpl Integration Tests', () {
    late ExpeditionSectorStockRepositoryImpl repository;
    late ApiConfig testConfig;
    late ExpeditionSectorStockModel insertedSectorStock;

    setUpAll(() async {
      testConfig = ApiConfig(apiUrl: 'localhost', apiPort: 3001, useHttps: false, lastUpdated: DateTime.now());

      SocketConfig.initialize(
        testConfig,
        autoConnect: true,
        onConnect: () {},
        onDisconnect: () {},
        onError: (error) {},
      );

      await Future.delayed(Duration(seconds: 2));
      if (!SocketConfig.isConnected) {}
    });

    setUp(() {
      repository = ExpeditionSectorStockRepositoryImpl();
    });

    tearDownAll(() async {
      if (SocketConfig.isConnected) {
        SocketConfig.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
      }
    });

    group('INSERT Test', () {
      test('deve inserir uma nova setor estoque e verificar se foi inserida', () async {
        final newSeparate = createDefaultTestSectorStock();
        final insertResult = await repository.insert(newSeparate);

        expect(insertResult, isNotEmpty);
        expect(insertResult.first.descricao, newSeparate.descricao);
        expect(insertResult.first.ativoCode, 'S');
        expect(insertResult.first.ativoDescription, 'Sim');

        insertedSectorStock = insertResult.first;

        await Future.delayed(Duration(seconds: 3));
      }, timeout: Timeout(Duration(minutes: 2)));
    });

    group('UPDATE Test', () {
      test('deve atualizar a setor estoque inserida anteriormente', () async {
        final updatedSeparate = createUpdatedTestSectorStock(insertedSectorStock);

        final updateResult = await repository.update(updatedSeparate);

        expect(updateResult, isNotEmpty);
        expect(updateResult.first.codSetorEstoque, insertedSectorStock.codSetorEstoque);
        expect(updateResult.first.ativoCode, 'N');

        await Future.delayed(Duration(seconds: 3));
      }, timeout: Timeout(Duration(minutes: 2)));
    });

    group('DELETE Test', () {
      test('deve deletar a setor estoque inserida anteriormente', () async {
        final separateToDelete = insertedSectorStock;

        final deleteResult = await repository.delete(separateToDelete);

        expect(deleteResult, isNotEmpty);
        expect(deleteResult.first.codSetorEstoque, insertedSectorStock.codSetorEstoque);
        expect(deleteResult.first.descricao, insertedSectorStock.descricao);

        expect(deleteResult.first.ativoCode, isA<String>());

        await Future.delayed(Duration(seconds: 3));
      }, timeout: Timeout(Duration(minutes: 2)));
    });
  });
}
