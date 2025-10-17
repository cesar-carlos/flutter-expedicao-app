import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_failure.dart';
import 'package:data7_expedicao/data/repositories/separation_item_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_item_repository_impl.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';

import '../../mocks/separate_item_model_mock.dart';
import '../../mocks/user_session_service_mock.dart';
import '../../mocks/test_data_cleanup_helper.dart';
import '../../mocks/add_item_separation_params_mock.dart';
import '../../core/usecase_integration_test_base.dart';

void main() {
  group('AddItemSeparationUseCase Integration Tests', () {
    late AddItemSeparationUseCase useCase;
    late SeparateItemRepositoryImpl separateItemRepository;
    late SeparationItemRepositoryImpl separationItemRepository;
    late UserSessionService userSessionService;
    late String sessionId;

    setUpAll(() async {
      await UseCaseIntegrationTestBase.setupUseCaseTest();
      sessionId = SocketConfig.sessionId!;
    });

    setUp(() async {
      await UseCaseIntegrationTestBase.ensureSocketConnection();

      // Inicializar repositórios e serviços
      separateItemRepository = SeparateItemRepositoryImpl();
      separationItemRepository = SeparationItemRepositoryImpl();
      userSessionService = MockUserSessionService();

      // Criar use case
      useCase = AddItemSeparationUseCase(
        separateItemRepository: separateItemRepository,
        separationItemRepository: separationItemRepository,
        userSessionService: userSessionService,
      );

      // Preparar dados de teste
      try {
        final testSeparateItem = createDefaultTestItem();
        final insertResult = await separateItemRepository.insert(testSeparateItem);

        if (insertResult.isEmpty) {
          throw Exception('Falha ao inserir item de teste');
        }

        await UseCaseIntegrationTestBase.waitForOperation('Preparação dos dados');
      } catch (e) {
        if (e.toString().contains('PRIMARY KEY constraint')) {
          debugPrint('⚠️ Item já existe no banco - continuando teste...');
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
      test('deve adicionar item à separação com sucesso', () async {
        UseCaseIntegrationTestBase.logTestStart('Adição de item à separação');
        UseCaseIntegrationTestBase.validateSocketState();

        // Arrange
        final params = createDefaultTestAddItemSeparationParams();

        // Act
        final result = await useCase.call(params);

        // Assert
        final success = result.getOrElse((error) {
          fail('❌ Teste falhou inesperadamente: ${error.toString()}');
        });

        // Validações detalhadas
        expect(success.codProduto, equals(params.codProduto), reason: 'Código do produto deve coincidir');
        expect(success.addedQuantity, equals(params.quantidade), reason: 'Quantidade adicionada deve coincidir');
        expect(success.createdSeparationItem.sessionId, equals(params.sessionId), reason: 'SessionId deve coincidir');
        expect(
          success.createdSeparationItem.situacaoCode,
          equals(ExpeditionItemSituation.separado.code),
          reason: 'Item deve estar separado',
        );
        expect(
          success.newTotalSeparationQuantity,
          equals(params.quantidade),
          reason: 'Quantidade total deve ser a adicionada',
        );
        expect(success.separatorName, equals(params.nomeSeparador), reason: 'Nome do separador deve coincidir');
        expect(success.hasRemainingQuantity, isTrue, reason: 'Deve haver quantidade restante');

        UseCaseIntegrationTestBase.logTestSuccess('Adição de item', details: success.operationSummary);
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('Testes de Regras de Negócio', () {
      test('deve falhar quando quantidade solicitada excede disponível', () async {
        UseCaseIntegrationTestBase.logTestStart('Validação de quantidade excessiva');

        // Arrange
        final params = createTestAddItemSeparationParamsWithExcessiveQuantity(sessionId);

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isSuccess(), isFalse, reason: 'UseCase deveria falhar com quantidade excessiva');

        final failure = result.exceptionOrNull() as AddItemSeparationFailure?;
        expect(failure, isNotNull, reason: 'Deveria ter uma falha');
        expect(failure!.type, equals(AddItemSeparationFailureType.insufficientQuantity));
        expect(failure.isBusinessError, isTrue);

        UseCaseIntegrationTestBase.logExpectedFailure('Quantidade excessiva', failure.type.toString(), failure.message);
      }, timeout: const Timeout(Duration(minutes: 1)));
    });

    group('Testes de Múltiplas Separações', () {
      test('deve adicionar múltiplos itens e atualizar quantidade corretamente', () async {
        UseCaseIntegrationTestBase.logTestStart('Múltiplas separações');

        // Verificar estado inicial
        final initialSeparateItems = await separateItemRepository.select(
          QueryBuilder().equals('CodEmpresa', 1).equals('CodSepararEstoque', 999999).equals('CodProduto', 1),
        );

        final initialQuantitySeparated = initialSeparateItems.isNotEmpty
            ? initialSeparateItems.first.quantidadeSeparacao
            : 0.0;

        // Criar parâmetros para duas separações
        final params1 = createTestAddItemSeparationParamsForMultiple1(sessionId);
        final params2 = createTestAddItemSeparationParamsForMultiple2(sessionId);

        // Executar separações
        final result1 = await useCase.call(params1);
        await UseCaseIntegrationTestBase.waitForOperation('Primeira separação');

        final result2 = await useCase.call(params2);
        await UseCaseIntegrationTestBase.waitForOperation('Segunda separação');

        // Verificar resultados
        expect(result1.isSuccess(), isTrue, reason: 'Primeira separação deveria ter sucesso');
        expect(result2.isSuccess(), isTrue, reason: 'Segunda separação deveria ter sucesso');

        final success1 = result1.getOrNull()!;
        final success2 = result2.getOrNull()!;

        // Verificar quantidade total
        final expectedTotal = initialQuantitySeparated + success1.addedQuantity + success2.addedQuantity;
        expect(
          success2.newTotalSeparationQuantity,
          equals(expectedTotal),
          reason:
              'Quantidade total deve ser: inicial ($initialQuantitySeparated) + '
              'primeira (${success1.addedQuantity}) + segunda (${success2.addedQuantity}) = $expectedTotal',
        );

        // Verificar incrementos individuais
        expect(
          success1.newTotalSeparationQuantity,
          equals(initialQuantitySeparated + success1.addedQuantity),
          reason: 'Primeira separação deve incrementar corretamente',
        );

        UseCaseIntegrationTestBase.logTestSuccess(
          'Múltiplas separações',
          details: 'Total acumulado: ${success2.newTotalSeparationQuantity}',
        );
      }, timeout: const Timeout(Duration(minutes: 2)));
    });
  });
}
