import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_failure.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:data7_expedicao/data/repositories/separation_item_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_item_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_repository_impl.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';

import '../../mocks/cancel_item_separation_params_mock.dart';
import '../../mocks/add_item_separation_params_mock.dart';
import '../../mocks/user_session_service_mock.dart';
import '../../mocks/separate_item_model_mock.dart';
import '../../mocks/test_data_cleanup_helper.dart';
import '../../mocks/separate_model_mock.dart';
import '../../core/usecase_integration_test_base.dart';

void main() {
  group('CancelItemSeparationUseCase Integration Tests', () {
    late CancelItemSeparationUseCase cancelUseCase;
    late AddItemSeparationUseCase addUseCase;
    late SeparateItemRepositoryImpl separateItemRepository;
    late SeparationItemRepositoryImpl separationItemRepository;
    late SeparateRepositoryImpl separateRepository;
    late UserSessionService userSessionService;
    setUpAll(() async {
      await UseCaseIntegrationTestBase.setupUseCaseTest();
    });

    setUp(() async {
      await UseCaseIntegrationTestBase.ensureSocketConnection();

      // Inicializar repositórios e serviços
      separateItemRepository = SeparateItemRepositoryImpl();
      separationItemRepository = SeparationItemRepositoryImpl();
      separateRepository = SeparateRepositoryImpl();
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

      // Preparar dados de teste
      try {
        final testSeparateItem = createDefaultTestItem();
        final testSeparate = createTestSeparate().copyWith(
          codSepararEstoque: 999999,
          situacao: ExpeditionSituation.separando,
        );

        await separateItemRepository.insert(testSeparateItem);
        await separateRepository.insert(testSeparate);
        await UseCaseIntegrationTestBase.waitForOperation('Preparação dos dados');
      } catch (e) {
        if (e.toString().contains('PRIMARY KEY constraint')) {
          debugPrint('⚠️ Dados já existem no banco - continuando teste...');
        } else {
          UseCaseIntegrationTestBase.logUnexpectedError('Preparação dos dados', e);
          rethrow;
        }
      }
    });

    tearDownAll(() async {
      await TestDataCleanupHelper.cleanupTestData();
      await UseCaseIntegrationTestBase.tearDownSocket();
    });

    group('Teste de Sucesso', () {
      test('deve cancelar item da separação com sucesso', () async {
        UseCaseIntegrationTestBase.logTestStart('Cancelamento de item');
        UseCaseIntegrationTestBase.validateSocketState();

        // Primeiro adicionar um item
        final addParams = createDefaultTestAddItemSeparationParams();
        final addResult = await addUseCase.call(addParams);

        expect(addResult.isSuccess(), isTrue, reason: 'Deve conseguir adicionar item primeiro');
        final addedItem = addResult.getOrNull()!.createdSeparationItem;

        await UseCaseIntegrationTestBase.waitForOperation('Adição do item');

        // Cancelar o item
        final cancelParams = createTestCancelItemSeparationParamsWithItem(addedItem.item);
        final result = await cancelUseCase.call(cancelParams);

        // Verificar resultado
        final success = result.getOrElse((error) {
          fail('❌ Teste falhou inesperadamente: ${error.toString()}');
        });

        // Validações detalhadas
        expect(success.cancelledQuantity, equals(addedItem.quantidade), reason: 'Quantidade cancelada deve coincidir');
        expect(
          success.cancelledSeparationItem.situacao,
          equals(ExpeditionItemSituation.cancelado),
          reason: 'Item deve estar cancelado',
        );
        expect(success.cancelledSeparationItem.item, equals(addedItem.item), reason: 'Item deve ser o mesmo');
        expect(success.updatedSeparateItem.codProduto, equals(addedItem.codProduto), reason: 'Produto deve coincidir');

        UseCaseIntegrationTestBase.logTestSuccess('Cancelamento de item', details: success.operationSummary);
      }, timeout: const Timeout(Duration(seconds: 30)));
    });

    group('Testes de Regras de Negócio', () {
      test('deve falhar quando item não existe', () async {
        UseCaseIntegrationTestBase.logTestStart('Validação de item inexistente');

        final params = createTestCancelItemSeparationParamsWithNonExistentItem();
        final result = await cancelUseCase.call(params);

        expect(result.isSuccess(), isFalse, reason: 'UseCase deveria falhar com item inexistente');

        final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
        expect(failure, isNotNull, reason: 'Deveria ter uma falha');
        expect(failure!.type, equals(CancelItemSeparationFailureType.separationItemNotFound));
        expect(failure.isBusinessError, isTrue);

        UseCaseIntegrationTestBase.logExpectedFailure('Item inexistente', failure.type.toString(), failure.message);
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('deve falhar quando separação não está em situação SEPARANDO', () async {
        UseCaseIntegrationTestBase.logTestStart('Validação de situação inválida');

        // Criar separação em situação AGUARDANDO
        final testSeparateAguardando = createTestSeparate().copyWith(
          codSepararEstoque: 999997,
          situacao: ExpeditionSituation.aguardando,
        );

        try {
          await separateRepository.insert(testSeparateAguardando);

          // Adicionar e tentar cancelar item
          final addParams = AddItemSeparationParams(
            codEmpresa: 1,
            codSepararEstoque: 999997,
            sessionId: 'test-session-id',
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
            );

            final result = await cancelUseCase.call(cancelParams);

            expect(
              result.isSuccess(),
              isFalse,
              reason: 'UseCase deveria falhar quando separação não está em SEPARANDO',
            );

            final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
            expect(failure, isNotNull, reason: 'Deveria ter uma falha');
            expect(failure!.type, equals(CancelItemSeparationFailureType.separateNotInSeparatingState));
            expect(failure.isBusinessError, isTrue);

            UseCaseIntegrationTestBase.logExpectedFailure(
              'Situação inválida',
              failure.type.toString(),
              failure.message,
            );
          }
        } catch (e) {
          UseCaseIntegrationTestBase.logUnexpectedError('Teste de situação', e);
          rethrow;
        }
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('deve falhar quando item já foi cancelado', () async {
        UseCaseIntegrationTestBase.logTestStart('Validação de item já cancelado');

        // Adicionar e cancelar item
        final addParams = createDefaultTestAddItemSeparationParams();
        final addResult = await addUseCase.call(addParams);

        if (addResult.isSuccess()) {
          final addedItem = addResult.getOrNull()!.createdSeparationItem;

          // Primeiro cancelamento
          final cancelParams1 = createTestCancelItemSeparationParamsWithItem(addedItem.item);
          final cancelResult1 = await cancelUseCase.call(cancelParams1);
          expect(cancelResult1.isSuccess(), isTrue, reason: 'Primeiro cancelamento deve ter sucesso');

          // Tentar cancelar novamente
          final cancelParams2 = createTestCancelItemSeparationParamsWithItem(addedItem.item);
          final result = await cancelUseCase.call(cancelParams2);

          expect(result.isSuccess(), isFalse, reason: 'UseCase deveria falhar ao cancelar item já cancelado');

          final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
          expect(failure, isNotNull, reason: 'Deveria ter uma falha');
          expect(failure!.type, equals(CancelItemSeparationFailureType.itemAlreadyCancelled));
          expect(failure.isBusinessError, isTrue);

          UseCaseIntegrationTestBase.logExpectedFailure('Item já cancelado', failure.type.toString(), failure.message);
        }
      }, timeout: const Timeout(Duration(seconds: 30)));
    });

    group('Testes de Validação', () {
      test('deve falhar com parâmetros inválidos', () async {
        UseCaseIntegrationTestBase.logTestStart('Validação de parâmetros');

        final params = createTestCancelItemSeparationParamsInvalid();
        final result = await cancelUseCase.call(params);

        expect(result.isSuccess(), isFalse, reason: 'UseCase deveria falhar com parâmetros inválidos');

        final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
        expect(failure, isNotNull, reason: 'Deveria ter uma falha');
        expect(failure!.type, equals(CancelItemSeparationFailureType.invalidParams));
        expect(failure.isValidationError, isTrue);

        UseCaseIntegrationTestBase.logExpectedFailure('Parâmetros inválidos', failure.type.toString(), failure.message);
      }, timeout: const Timeout(Duration(seconds: 30)));
    });
  });
}
