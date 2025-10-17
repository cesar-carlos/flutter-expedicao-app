import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/data/repositories/user_system_repository_impl.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import '../../core/api_integration_test_base.dart';

void main() {
  group('UserSystemRepositoryImpl Integration Tests', () {
    late UserSystemRepositoryImpl repository;

    setUpAll(() async {
      await ApiIntegrationTestBase.setupApi();
    });

    setUp(() {
      repository = UserSystemRepositoryImpl();
    });

    tearDownAll(() async {
      await ApiIntegrationTestBase.tearDownApi();
    });

    group('GetUserById Test', () {
      test('deve buscar um usuário existente', () async {
        // Arrange - usando um usuário que sabemos que existe no sistema
        const codUsuarioExistente = 1; // Ajuste para um código válido no seu ambiente

        // Act
        final result = await repository.getUserById(codUsuarioExistente);

        // Assert
        expect(result, isNotNull, reason: 'Deve encontrar um usuário existente');
        expect(result?.codUsuario, equals(codUsuarioExistente), reason: 'O código do usuário deve corresponder');
        expect(result?.nomeUsuario, isNotEmpty, reason: 'O nome do usuário não deve estar vazio');

        // Verifica se o cache está funcionando
        final cachedResult = await repository.getUserById(codUsuarioExistente);
        expect(identical(result, cachedResult), isTrue, reason: 'O segundo resultado deve vir do cache');

        // Aguarda para garantir que a operação foi concluída
        await ApiIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('deve retornar null para usuário inexistente', () async {
        // Arrange - usando um código que sabemos que não existe
        const codUsuarioInexistente = 999999;

        // Act
        final result = await repository.getUserById(codUsuarioInexistente);

        // Assert
        expect(result, isNull, reason: 'Deve retornar null para usuário inexistente');

        // Aguarda para garantir que a operação foi concluída
        await ApiIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('GetUsers Test', () {
      test('deve listar usuários com paginação', () async {
        // Arrange
        final pagination = Pagination(page: 1, limit: 10, offset: 0);

        // Act
        final result = await repository.getUsers(
          codEmpresa: 1, // Ajuste para uma empresa válida no seu ambiente
          apenasAtivos: Situation.ativo,
          pagination: pagination,
        );

        // Assert
        expect(result.users, isNotEmpty, reason: 'Deve retornar uma lista não vazia de usuários');
        expect(result.total, greaterThan(0), reason: 'Deve ter pelo menos um usuário no total');
        expect(result.success, isTrue, reason: 'A operação deve ser bem-sucedida');

        // Verifica o primeiro usuário da lista
        final firstUser = result.users.first;
        expect(firstUser.codUsuario, isNotNull, reason: 'O primeiro usuário deve ter um código válido');
        expect(firstUser.nomeUsuario, isNotEmpty, reason: 'O primeiro usuário deve ter um nome');

        // Aguarda para garantir que a operação foi concluída
        await ApiIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('SearchUsersByName Test', () {
      test('deve buscar usuários por nome', () async {
        // Arrange
        const searchName = 'ADMIN'; // Ajuste para um nome que existe no seu ambiente

        // Act
        final result = await repository.searchUsersByName(
          searchName,
          codEmpresa: 1, // Ajuste para uma empresa válida no seu ambiente
        );

        // Assert
        expect(result.users, isNotEmpty, reason: 'Deve encontrar usuários com o nome pesquisado');
        expect(
          result.users.any((user) => user.nomeUsuario.toUpperCase().contains(searchName.toUpperCase())),
          isTrue,
          reason: 'Pelo menos um usuário deve conter o termo pesquisado',
        );
        expect(result.success, isTrue, reason: 'A operação deve ser bem-sucedida');

        // Aguarda para garantir que a operação foi concluída
        await ApiIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('deve retornar lista filtrada para nome inexistente', () async {
        // Arrange
        final searchName = 'USUARIO_INEXISTENTE_${DateTime.now().millisecondsSinceEpoch}';

        // Act
        final result = await repository.searchUsersByName(searchName);

        // Assert
        expect(result.users, isNotEmpty, reason: 'A API retorna todos os usuários mesmo sem encontrar o termo');
        expect(result.success, isTrue, reason: 'A operação deve ser bem-sucedida mesmo sem resultados');

        // Aguarda para garantir que a operação foi concluída
        await ApiIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('GetUserSystemInfo Test', () {
      test('deve retornar informações do usuário em formato Map', () async {
        // Arrange
        const codUsuarioExistente = 1; // Ajuste para um código válido no seu ambiente

        // Act
        final result = await repository.getUserSystemInfo(codUsuarioExistente);

        // Assert
        expect(result, isA<Map<String, dynamic>>(), reason: 'Deve retornar um Map');
        expect(result['CodUsuario'], equals(codUsuarioExistente), reason: 'O código do usuário deve corresponder');
        expect(result['NomeUsuario'], isNotEmpty, reason: 'O nome do usuário não deve estar vazio');

        // Aguarda para garantir que a operação foi concluída
        await ApiIntegrationTestBase.waitForOperation();
      }, timeout: const Timeout(Duration(minutes: 2)));
    });
  });
}
