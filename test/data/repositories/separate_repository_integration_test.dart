import 'package:flutter_test/flutter_test.dart';

import 'package:exp/data/repositories/separate_repository_impl.dart';
import 'package:exp/domain/models/separate_model.dart';
import 'package:exp/domain/models/api_config.dart';
import 'package:exp/core/network/socket_config.dart';

void main() {
  group('SeparateRepositoryImpl Integration Tests', () {
    late SeparateRepositoryImpl repository;
    late ApiConfig testConfig;
    late SeparateModel insertedSeparate;

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
      if (!SocketConfig.isConnected) {}
    });

    setUp(() {
      repository = SeparateRepositoryImpl();
    });

    tearDownAll(() async {
      if (SocketConfig.isConnected) {
        SocketConfig.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
      }
    });

    group('INSERT Integration Tests', () {
      test(
        'deve inserir uma nova separação e verificar se foi inserida',
        () async {
          final newSeparate = SeparateModel(
            codEmpresa: 1,
            codSepararEstoque: 0,
            codOrigem: 1,
            origem: 'OB',
            codTipoOperacaoExpedicao: 1,
            tipoEntidade: 'C',
            codEntidade: 999999,
            nomeEntidade: 'TESTE ${DateTime.now().millisecondsSinceEpoch}',
            situacao: 'PENDENTE',
            data: DateTime.now(),
            hora: '10:00:00',
            codPrioridade: 1,
            observacao: 'Teste de integração - INSERT',
            historico: 'Criado via teste de integração',
          );

          final insertResult = await repository.insert(newSeparate);

          expect(insertResult, isNotEmpty);
          expect(insertResult.first.nomeEntidade, newSeparate.nomeEntidade);
          expect(insertResult.first.situacao, 'PENDENTE');
          expect(insertResult.first.observacao, 'Teste de integração - INSERT');

          insertedSeparate = insertResult.first;

          await Future.delayed(Duration(seconds: 3));
        },

        timeout: Timeout(Duration(minutes: 2)),
      );
    });

    group('UPDATE Integration Tests', () {
      test(
        'deve atualizar a separação inserida anteriormente',
        () async {
          final updatedSeparate = insertedSeparate.copyWith(
            situacao: 'SEPARANDO',
            observacao: 'Atualizado via teste de integração - UPDATE',
            historico: 'Atualizado em ${DateTime.now().toIso8601String()}',
          );

          final updateResult = await repository.update(updatedSeparate);

          expect(updateResult, isNotEmpty);
          expect(
            updateResult.first.codSepararEstoque,
            insertedSeparate.codSepararEstoque,
          );
          expect(updateResult.first.situacao, 'SEPARANDO');
          expect(
            updateResult.first.observacao,
            'Atualizado via teste de integração - UPDATE',
          );
          expect(
            updateResult.first.nomeEntidade,
            insertedSeparate.nomeEntidade,
          );

          await Future.delayed(Duration(seconds: 3));
        },
        timeout: Timeout(Duration(minutes: 2)),
      );
    });

    group('DELETE Integration Tests', () {
      test(
        'deve deletar a separação inserida anteriormente',
        () async {
          final separateToDelete = insertedSeparate;

          final deleteResult = await repository.delete(separateToDelete);

          expect(deleteResult, isNotEmpty);
          expect(
            deleteResult.first.codSepararEstoque,
            insertedSeparate.codSepararEstoque,
          );
          expect(
            deleteResult.first.nomeEntidade,
            insertedSeparate.nomeEntidade,
          );

          expect(deleteResult.first.situacao, isA<String>());

          await Future.delayed(Duration(seconds: 3));
        },
        timeout: Timeout(Duration(minutes: 2)),
      );
    });
  });
}
