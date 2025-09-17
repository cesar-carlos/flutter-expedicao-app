import 'package:flutter_test/flutter_test.dart';

import 'package:exp/data/repositories/separate_item_repository_impl.dart';
import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/api_config.dart';
import 'package:exp/core/network/socket_config.dart';
import '../../mocks/separate_item_model_mock.dart';

void main() {
  group('SeparateItemRepositoryImpl Integration Tests', () {
    late SeparateItemRepositoryImpl repository;
    late ApiConfig testConfig;
    late SeparateItemModel insertedSeparateItem;

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
      if (!SocketConfig.isConnected) {
        return;
      }
    });

    setUp(() {
      repository = SeparateItemRepositoryImpl();
    });

    tearDownAll(() async {
      if (SocketConfig.isConnected) {
        SocketConfig.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
      }
    });

    group('INSERT Integration Tests', () {
      test('deve inserir um novo item de separação e verificar se foi inserido', () async {
        final newItem = createDefaultTestItem();
        final insertResult = await repository.insert(newItem);

        expect(insertResult, isNotEmpty);
        expect(insertResult.first.item, newItem.item);
        expect(insertResult.first.codProduto, 1);
        expect(insertResult.first.quantidade, 1.0);
        expect(insertResult.first.quantidadeInterna, 1.0);
        expect(insertResult.first.quantidadeExterna, 0.0);
        expect(insertResult.first.quantidadeSeparacao, 0.0);

        insertedSeparateItem = insertResult.first;

        await Future.delayed(Duration(seconds: 3));
      }, timeout: Timeout(Duration(minutes: 2)));
    });

    group('UPDATE Integration Tests', () {
      test('deve atualizar o item de separação inserido anteriormente', () async {
        final updatedItem = createUpdatedTestItem(insertedSeparateItem);

        final updateResult = await repository.update(updatedItem);

        expect(updateResult, isNotEmpty);
        expect(updateResult.first.codSepararEstoque, insertedSeparateItem.codSepararEstoque);
        expect(updateResult.first.item, insertedSeparateItem.item);
        expect(updateResult.first.quantidadeSeparacao, 0.5);
        expect(updateResult.first.quantidadeInterna, 0.5);
        expect(updateResult.first.quantidadeExterna, 0.5);
        expect(updateResult.first.codProduto, insertedSeparateItem.codProduto);

        await Future.delayed(Duration(seconds: 3));
      }, timeout: Timeout(Duration(minutes: 2)));
    });

    group('DELETE Integration Tests', () {
      test('deve deletar o item de separação inserido anteriormente', () async {
        final itemToDelete = insertedSeparateItem;

        final deleteResult = await repository.delete(itemToDelete);

        expect(deleteResult, isNotEmpty);
        expect(deleteResult.first.codSepararEstoque, insertedSeparateItem.codSepararEstoque);
        expect(deleteResult.first.item, insertedSeparateItem.item);
        expect(deleteResult.first.codProduto, insertedSeparateItem.codProduto);

        expect(deleteResult.first.quantidade, isA<double>());

        await Future.delayed(Duration(seconds: 3));
      }, timeout: Timeout(Duration(minutes: 2)));
    });
  });
}
