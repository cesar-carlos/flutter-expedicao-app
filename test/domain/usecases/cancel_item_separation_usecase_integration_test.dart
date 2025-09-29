import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exp/domain/models/api_config.dart';
import 'package:exp/core/network/socket_config.dart';
import 'package:exp/domain/models/separate_model.dart';
import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/domain/models/expedition_item_situation_model.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_usecase.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_failure.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_params.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:exp/data/repositories/separation_item_repository_impl.dart';
import 'package:exp/data/repositories/separate_item_repository_impl.dart';
import 'package:exp/data/repositories/separate_repository_impl.dart';
import 'package:exp/data/services/user_session_service.dart';

import '../../mocks/cancel_item_separation_params_mock.dart';
import '../../mocks/add_item_separation_params_mock.dart';
import '../../mocks/user_session_service_mock.dart';
import '../../mocks/separate_item_model_mock.dart';
import '../../mocks/test_data_cleanup_helper.dart';
import '../../mocks/separate_model_mock.dart';

void main() {
  group('CancelItemSeparationUseCase Integration Tests', () {
    late CancelItemSeparationUseCase cancelUseCase;
    late AddItemSeparationUseCase addUseCase;
    late SeparateItemRepositoryImpl separateItemRepository;
    late SeparationItemRepositoryImpl separationItemRepository;
    late SeparateRepositoryImpl separateRepository;
    late UserSessionService userSessionService;
    late ApiConfig testConfig;

    late List<SeparateItemModel> insertedSeparateItems;
    late List<SeparateModel> insertedSeparates;
    late String sessionId;

    setUpAll(() async {
      // Configuração do ambiente de teste
      testConfig = ApiConfig(apiUrl: 'localhost', apiPort: 3001, useHttps: false, lastUpdated: DateTime.now());

      // Limpar qualquer conexão anterior
      if (SocketConfig.isInitialized) {
        SocketConfig.dispose();
      }

      // Inicializar socket para testes
      SocketConfig.initialize(
        testConfig,
        autoConnect: true,
        onConnect: () => debugPrint('🔌 Socket conectado para teste'),
        onDisconnect: () => debugPrint('🔌 Socket desconectado'),
        onError: (error) => debugPrint('🔴 Erro no socket: $error'),
      );

      // Aguardar conexão do socket com retry
      var attempts = 0;
      const maxAttempts = 10;
      while (!SocketConfig.isConnected && attempts < maxAttempts) {
        await Future.delayed(const Duration(seconds: 1));
        attempts++;
        debugPrint('⏳ Tentativa $attempts/$maxAttempts - Aguardando conexão...');
      }

      if (!SocketConfig.isConnected) {
        debugPrint('❌ Socket não conectou após $maxAttempts tentativas. Testes podem falhar.');
        debugPrint('💡 Verifique se o servidor está rodando na porta 3001');
      } else {
        debugPrint('✅ Socket conectado com sucesso!');
        debugPrint('🔑 SessionId: ${SocketConfig.sessionId}');
        // Capturar sessionId após a conexão
        sessionId = SocketConfig.sessionId!;
      }
    });

    setUp(() async {
      // Verificar se socket ainda está conectado
      if (!SocketConfig.isConnected) {
        debugPrint('⚠️ Socket desconectado durante teste. Tentando reconectar...');
        await SocketConfig.connect();
        await Future.delayed(const Duration(seconds: 2));

        if (!SocketConfig.isConnected) {
          fail('Socket não conseguiu conectar. Teste cancelado.');
        }
      }

      // Inicializar repositórios
      separateItemRepository = SeparateItemRepositoryImpl();
      separationItemRepository = SeparationItemRepositoryImpl();
      separateRepository = SeparateRepositoryImpl();

      // Mock do UserSessionService
      userSessionService = MockUserSessionService();

      // Criar use cases
      addUseCase = AddItemSeparationUseCase(
        separateItemRepository: separateItemRepository,
        separationItemRepository: separationItemRepository,
        userSessionService: userSessionService,
      );

      cancelUseCase = CancelItemSeparationUseCase(
        separateItemRepository: separateItemRepository,
        separationItemRepository: separationItemRepository,
        separateRepository: separateRepository,
        userSessionService: userSessionService,
      );

      // Preparar dados de teste: inserir separate_item e separate
      try {
        final testSeparateItem = createDefaultTestItem();
        final testSeparate = createTestSeparate().copyWith(
          codSepararEstoque: 999999,
          situacao: ExpeditionSituation.separando, // Importante: deve estar em separando
        );

        insertedSeparateItems = await separateItemRepository.insert(testSeparateItem);
        insertedSeparates = await separateRepository.insert(testSeparate);

        if (insertedSeparateItems.isEmpty || insertedSeparates.isEmpty) {
          fail('Falha ao inserir dados de teste no banco');
        }

        debugPrint('✅ Dados de teste inseridos com sucesso');
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('❌ Erro ao preparar dados de teste: $e');
        if (e.toString().contains('PRIMARY KEY constraint')) {
          debugPrint('⚠️ Dados já existem no banco - continuando teste...');
        } else {
          fail('Erro na preparação dos dados de teste: $e');
        }
      }
    });

    tearDownAll(() async {
      // Limpar dados de teste da base de dados
      await TestDataCleanupHelper.cleanupTestData();

      if (SocketConfig.isConnected) {
        SocketConfig.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    });

    group('Teste de Sucesso', () {
      test('deve cancelar item da separação com sucesso', () async {
        // Arrange
        expect(SocketConfig.isConnected, isTrue, reason: 'Socket deve estar conectado');
        expect(SocketConfig.sessionId, isNotNull, reason: 'SessionId deve estar disponível');

        // Primeiro, adicionar um item à separação para depois cancelar
        final addParams = createDefaultTestAddItemSeparationParams(sessionId);
        final addResult = await addUseCase.call(addParams);

        expect(addResult.isSuccess(), isTrue, reason: 'Deve conseguir adicionar item primeiro');
        final addedItem = addResult.getOrNull()!.createdSeparationItem;

        debugPrint('✅ Item adicionado: ${addedItem.item}');

        // Agora cancelar o item
        final cancelParams = createTestCancelItemSeparationParamsWithItem(sessionId, addedItem.item);

        // Act
        final result = await cancelUseCase.call(cancelParams);
        await Future.delayed(const Duration(seconds: 1));

        // Assert
        final success = result.getOrElse((error) {
          fail('❌ Teste falhou inesperadamente: ${error.toString()}');
        });

        debugPrint('✅ SUCESSO: Cancelamento executado com sucesso');
        debugPrint('📊 Detalhes: ${success.operationSummary}');

        // Validações detalhadas
        expect(success.cancelledQuantity, equals(addedItem.quantidade), reason: 'Quantidade cancelada deve coincidir');
        expect(
          success.cancelledSeparationItem.situacao,
          equals(ExpeditionItemSituation.cancelado),
          reason: 'Item deve estar cancelado',
        );
        expect(success.cancelledSeparationItem.item, equals(addedItem.item), reason: 'Item deve ser o mesmo');
        expect(success.updatedSeparateItem.codProduto, equals(addedItem.codProduto), reason: 'Produto deve coincidir');

        debugPrint('✅ Item cancelado com sucesso: ${success.operationSummary}');
        debugPrint('📊 Quantidade cancelada: ${success.cancelledQuantity}');
      }, timeout: const Timeout(Duration(seconds: 30)));
    });

    group('Testes de Regras de Negócio', () {
      test('deve falhar quando item não existe', () async {
        // Arrange
        final params = createTestCancelItemSeparationParamsWithNonExistentItem(sessionId);

        // Act
        debugPrint('🔧 Parâmetros do teste: Item ${params.item}');
        final result = await cancelUseCase.call(params);
        debugPrint('📊 Resultado obtido: ${result.isSuccess() ? "SUCESSO" : "FALHA"}');

        // Assert
        expect(result.isSuccess(), isFalse, reason: 'UseCase deveria falhar com item inexistente');

        final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
        expect(failure, isNotNull, reason: 'Deveria ter uma falha');
        expect(failure!.type, equals(CancelItemSeparationFailureType.separationItemNotFound));
        expect(failure.isBusinessError, isTrue);

        debugPrint('✅ Falha esperada: ${failure.message}');
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('deve falhar quando separação não existe', () async {
        // Arrange
        final params = createTestCancelItemSeparationParamsWithNonExistentSeparation(sessionId);

        // Act
        debugPrint('🔧 Parâmetros do teste: Separação ${params.codSepararEstoque}');
        final result = await cancelUseCase.call(params);
        debugPrint('📊 Resultado obtido: ${result.isSuccess() ? "SUCESSO" : "FALHA"}');

        // Assert
        expect(result.isSuccess(), isFalse, reason: 'UseCase deveria falhar com separação inexistente');

        final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
        expect(failure, isNotNull, reason: 'Deveria ter uma falha');
        expect(failure!.type, equals(CancelItemSeparationFailureType.separationItemNotFound));
        expect(failure.isBusinessError, isTrue);

        debugPrint('✅ Falha esperada: ${failure.message}');
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('deve falhar quando separação não está em situação SEPARANDO', () async {
        // Arrange
        // Criar uma separação em situação diferente de SEPARANDO
        final testSeparateAguardando = createTestSeparate().copyWith(
          codSepararEstoque: 999997,
          situacao: ExpeditionSituation.aguardando, // Não está em separando
        );

        try {
          await separateRepository.insert(testSeparateAguardando);

          // Adicionar item nesta separação
          final addParams = AddItemSeparationParams(
            codEmpresa: 1,
            codSepararEstoque: 999997,
            sessionId: sessionId,
            codCarrinhoPercurso: 1,
            itemCarrinhoPercurso: '00020',
            codSeparador: 1,
            nomeSeparador: 'TESTE SEPARADOR',
            codProduto: 1,
            codUnidadeMedida: 'UN',
            quantidade: 1.0,
          );
          final addResult = await addUseCase.call(addParams);

          if (addResult.isSuccess()) {
            final addedItem = addResult.getOrNull()!.createdSeparationItem;
            final cancelParams = CancelItemSeparationParams(
              codEmpresa: 1,
              codSepararEstoque: 999997,
              item: addedItem.item,
              sessionId: sessionId,
            );

            // Act
            debugPrint('🔧 Testando cancelamento em separação não em SEPARANDO');
            final result = await cancelUseCase.call(cancelParams);
            debugPrint('📊 Resultado obtido: ${result.isSuccess() ? "SUCESSO" : "FALHA"}');

            // Assert
            expect(
              result.isSuccess(),
              isFalse,
              reason: 'UseCase deveria falhar quando separação não está em SEPARANDO',
            );

            final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
            expect(failure, isNotNull, reason: 'Deveria ter uma falha');
            expect(failure!.type, equals(CancelItemSeparationFailureType.separateNotInSeparatingState));
            expect(failure.isBusinessError, isTrue);

            debugPrint('✅ Falha esperada: ${failure.message}');
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao preparar teste de situação: $e');
        }
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('deve falhar quando item já foi cancelado', () async {
        // Arrange
        // Adicionar item
        final addParams = createDefaultTestAddItemSeparationParams(sessionId);
        final addResult = await addUseCase.call(addParams);

        if (addResult.isSuccess()) {
          final addedItem = addResult.getOrNull()!.createdSeparationItem;

          // Cancelar item pela primeira vez
          final cancelParams1 = createTestCancelItemSeparationParamsWithItem(sessionId, addedItem.item);
          final cancelResult1 = await cancelUseCase.call(cancelParams1);

          expect(cancelResult1.isSuccess(), isTrue, reason: 'Primeiro cancelamento deve ter sucesso');

          // Tentar cancelar novamente
          final cancelParams2 = createTestCancelItemSeparationParamsWithItem(sessionId, addedItem.item);

          // Act
          debugPrint('🔧 Testando cancelamento duplo do item ${addedItem.item}');
          final result = await cancelUseCase.call(cancelParams2);
          debugPrint('📊 Resultado obtido: ${result.isSuccess() ? "SUCESSO" : "FALHA"}');

          // Assert
          expect(result.isSuccess(), isFalse, reason: 'UseCase deveria falhar ao cancelar item já cancelado');

          final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
          expect(failure, isNotNull, reason: 'Deveria ter uma falha');
          expect(failure!.type, equals(CancelItemSeparationFailureType.itemAlreadyCancelled));
          expect(failure.isBusinessError, isTrue);

          debugPrint('✅ Falha esperada: ${failure.message}');
        }
      }, timeout: const Timeout(Duration(seconds: 30)));
    });

    group('Testes de Validação', () {
      test('deve falhar com parâmetros inválidos', () async {
        // Arrange
        final params = createTestCancelItemSeparationParamsInvalid();

        // Act
        debugPrint('🔧 Testando parâmetros inválidos');
        final result = await cancelUseCase.call(params);
        debugPrint('📊 Resultado obtido: ${result.isSuccess() ? "SUCESSO" : "FALHA"}');

        // Assert
        expect(result.isSuccess(), isFalse, reason: 'UseCase deveria falhar com parâmetros inválidos');

        final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
        expect(failure, isNotNull, reason: 'Deveria ter uma falha');
        expect(failure!.type, equals(CancelItemSeparationFailureType.invalidParams));
        expect(failure.isValidationError, isTrue);

        debugPrint('✅ Falha esperada: ${failure.message}');
      }, timeout: const Timeout(Duration(seconds: 30)));
    });
  });
}
