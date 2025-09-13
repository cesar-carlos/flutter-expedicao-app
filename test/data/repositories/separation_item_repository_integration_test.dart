import 'package:flutter_test/flutter_test.dart';

import 'package:exp/data/repositories/separation_item_repository_impl.dart';
import 'package:exp/domain/models/separation_item_model.dart';
import 'package:exp/domain/models/api_config.dart';
import 'package:exp/core/network/socket_config.dart';
import '../../mocks/separation_item_model_mock.dart';

void main() {
  group('SeparationItemRepositoryImpl Integration Tests', () {
    late SeparationItemRepositoryImpl repository;
    late ApiConfig testConfig;
    late SeparationItemModel insertedSeparationItem;

    setUpAll(() async {
      testConfig = ApiConfig(
        apiUrl: 'localhost',
        apiPort: 3001,
        useHttps: false,
        lastUpdated: DateTime.now(),
      );

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
      repository = SeparationItemRepositoryImpl();
    });

    tearDownAll(() async {
      if (SocketConfig.isConnected) {
        SocketConfig.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
      }
    });

    group('INSERT Integration Tests', () {
      test(
        'deve inserir um novo item de separação e verificar se foi inserido',
        () async {
          final newItem = createDefaultTestSeparationItem();
          final insertResult = await repository.insert(newItem);

          expect(insertResult, isNotEmpty);
          expect(insertResult.first.item, newItem.item);
          expect(insertResult.first.sessionId, newItem.sessionId);
          expect(insertResult.first.situacaoCode, 'PE');
          expect(insertResult.first.codProduto, 1);
          expect(insertResult.first.quantidade, 1.0);
          expect(insertResult.first.nomeSeparador, 'TESTE SEPARADOR');

          insertedSeparationItem = insertResult.first;

          await Future.delayed(Duration(seconds: 3));
        },
        timeout: Timeout(Duration(minutes: 2)),
      );
    });

    group('UPDATE Integration Tests', () {
      test(
        'deve atualizar o item de separação inserido anteriormente',
        () async {
          final updatedItem = createUpdatedTestSeparationItem(
            insertedSeparationItem,
          );

          final updateResult = await repository.update(updatedItem);

          expect(updateResult, isNotEmpty);
          expect(
            updateResult.first.codSepararEstoque,
            insertedSeparationItem.codSepararEstoque,
          );
          expect(updateResult.first.item, insertedSeparationItem.item);
          expect(updateResult.first.situacaoCode, 'SP');
          expect(updateResult.first.nomeSeparador, 'SEPARADOR ATUALIZADO');
          expect(
            updateResult.first.codProduto,
            insertedSeparationItem.codProduto,
          );

          await Future.delayed(Duration(seconds: 3));
        },
        timeout: Timeout(Duration(minutes: 2)),
      );
    });

    group('DELETE Integration Tests', () {
      test(
        'deve deletar o item de separação inserido anteriormente',
        () async {
          final itemToDelete = insertedSeparationItem;

          final deleteResult = await repository.delete(itemToDelete);

          expect(deleteResult, isNotEmpty);
          expect(
            deleteResult.first.codSepararEstoque,
            insertedSeparationItem.codSepararEstoque,
          );
          expect(deleteResult.first.item, insertedSeparationItem.item);
          expect(
            deleteResult.first.codProduto,
            insertedSeparationItem.codProduto,
          );

          expect(deleteResult.first.quantidade, isA<double>());

          await Future.delayed(Duration(seconds: 3));
        },
        timeout: Timeout(Duration(minutes: 2)),
      );
    });
  });
}
