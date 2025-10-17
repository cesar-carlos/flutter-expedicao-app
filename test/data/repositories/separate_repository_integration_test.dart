import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/data/repositories/separate_repository_impl.dart';

import '../../core/socket_integration_test_base.dart';
import '../../mocks/separate_model_mock.dart';

void main() {
  group('SeparateRepositoryImpl Tests', () {
    late SeparateRepositoryImpl repository;
    late SeparateModel insertedSeparate;

    setUpAll(() async {
      await SocketIntegrationTestBase.setupSocket();
    });

    setUp(() {
      repository = SeparateRepositoryImpl();
    });

    tearDownAll(() async {
      await SocketIntegrationTestBase.tearDownSocket();
    });

    group('INSERT Test', () {
      test('deve inserir uma nova separação e verificar se foi inserida', () async {
        // Cria uma nova separação para teste
        final newSeparate = createDefaultTestSeparate();

        // Tenta inserir a separação
        final insertResult = await repository.insert(newSeparate);

        // Verifica o resultado
        expect(insertResult, isNotEmpty, reason: 'O resultado da inserção não deve estar vazio');
        expect(
          insertResult.first.nomeEntidade,
          newSeparate.nomeEntidade,
          reason: 'O nome da entidade deve corresponder ao enviado',
        );
        expect(insertResult.first.situacaoCode, 'AGUARDANDO', reason: 'A situação inicial deve ser AGUARDANDO');
        expect(
          insertResult.first.observacao,
          'Teste de integração - INSERT',
          reason: 'A observação deve corresponder ao enviado',
        );

        // Guarda a separação inserida para os próximos testes
        insertedSeparate = insertResult.first;

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('UPDATE Test', () {
      test('deve atualizar a separação inserida anteriormente', () async {
        // Cria uma versão atualizada da separação
        final updatedSeparate = createUpdatedTestSeparate(insertedSeparate);

        // Tenta atualizar a separação
        final updateResult = await repository.update(updatedSeparate);

        // Verifica o resultado
        expect(updateResult, isNotEmpty, reason: 'O resultado da atualização não deve estar vazio');
        expect(
          updateResult.first.codSepararEstoque,
          insertedSeparate.codSepararEstoque,
          reason: 'O código da separação deve permanecer o mesmo',
        );
        expect(
          updateResult.first.situacaoCode,
          'SEPARANDO',
          reason: 'A situação deve ter sido alterada para SEPARANDO',
        );
        expect(
          updateResult.first.observacao,
          'Atualizado via teste de integração - UPDATE',
          reason: 'A observação deve ter sido atualizada',
        );
        expect(
          updateResult.first.nomeEntidade,
          insertedSeparate.nomeEntidade,
          reason: 'O nome da entidade deve permanecer o mesmo',
        );

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('DELETE Test', () {
      test('deve deletar a separação inserida anteriormente', () async {
        // Tenta deletar a separação
        final deleteResult = await repository.delete(insertedSeparate);

        // Verifica o resultado
        expect(deleteResult, isNotEmpty, reason: 'O resultado da deleção não deve estar vazio');
        expect(
          deleteResult.first.codSepararEstoque,
          insertedSeparate.codSepararEstoque,
          reason: 'O código da separação deletada deve corresponder',
        );
        expect(
          deleteResult.first.nomeEntidade,
          insertedSeparate.nomeEntidade,
          reason: 'O nome da entidade deve corresponder',
        );
        expect(deleteResult.first.situacaoCode, isA<String>(), reason: 'Deve retornar um código de situação válido');

        // Aguarda para garantir que a operação foi concluída
        await SocketIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });
  });
}
