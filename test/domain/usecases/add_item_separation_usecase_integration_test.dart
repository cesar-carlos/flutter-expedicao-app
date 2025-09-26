import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:result_dart/result_dart.dart';

import 'package:exp/domain/models/api_config.dart';
import 'package:exp/core/network/socket_config.dart';
import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/expedition_item_situation_model.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_failure.dart';
import 'package:exp/data/repositories/separation_item_repository_impl.dart';
import 'package:exp/data/repositories/separate_item_repository_impl.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/data/services/user_session_service.dart';

import '../../mocks/add_item_separation_params_mock.dart';
import '../../mocks/separate_item_model_mock.dart';
import '../../mocks/user_session_service_mock.dart';
import '../../mocks/test_data_cleanup_helper.dart';

void main() {
  group('AddItemSeparationUseCase Integration Tests', () {
    late AddItemSeparationUseCase useCase;
    late SeparateItemRepositoryImpl separateItemRepository;
    late SeparationItemRepositoryImpl separationItemRepository;
    late UserSessionService userSessionService;
    late ApiConfig testConfig;

    late List<SeparateItemModel> insertedSeparateItems;
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

      // Mock do UserSessionService
      userSessionService = MockUserSessionService();

      // Criar use case
      useCase = AddItemSeparationUseCase(
        separateItemRepository: separateItemRepository,
        separationItemRepository: separationItemRepository,
        userSessionService: userSessionService,
      );

      // Preparar dados de teste: inserir separate_item
      try {
        final testSeparateItem = createDefaultTestItem();

        insertedSeparateItems = await separateItemRepository.insert(testSeparateItem);
        if (insertedSeparateItems.isEmpty) {
          fail('Falha ao inserir item de teste no banco');
        }

        debugPrint('✅ Item de teste inserido com sucesso');
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('❌ Erro ao preparar dados de teste: $e');
        if (e.toString().contains('PRIMARY KEY constraint')) {
          debugPrint('⚠️ Item já existe no banco - continuando teste...');
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
      test('deve adicionar item à separação com sucesso', () async {
        // Arrange
        expect(SocketConfig.isConnected, isTrue, reason: 'Socket deve estar conectado');
        expect(SocketConfig.sessionId, isNotNull, reason: 'SessionId deve estar disponível');

        final params = createDefaultTestAddItemSeparationParams(sessionId);

        // Act
        final result = await useCase.call(params);

        // Verificar se o resultado é sucesso ou falha
        final success = result.getOrElse((error) {
          fail('❌ Teste falhou inesperadamente: ${error.toString()}');
        });

        debugPrint('✅ SUCESSO: Use case executado com sucesso');
        debugPrint('📊 Detalhes: ${success.operationSummary}');

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

        debugPrint('✅ Item adicionado com sucesso: ${success.operationSummary}');
        debugPrint('📊 Estatísticas: ${success.separationPercentage.toStringAsFixed(1)}% separado');
      }, timeout: const Timeout(Duration(seconds: 2)));
    });

    group('Testes de Regras de Negócio', () {
      test('deve falhar quando quantidade solicitada excede disponível', () async {
        // Arrange
        final params = createTestAddItemSeparationParamsWithExcessiveQuantity(sessionId);

        // Act
        debugPrint('🔧 Parâmetros do teste: Produto ${params.codProduto}, Quantidade ${params.quantidade}');
        final result = await useCase.call(params);
        debugPrint('📊 Resultado obtido: ${result.isSuccess() ? "SUCESSO" : "FALHA"}');
        debugPrint('📊 Tipo do resultado: ${result.runtimeType}');

        // Assert
        // Verificar se falhou conforme esperado
        expect(result.isSuccess(), isFalse, reason: 'UseCase deveria falhar com quantidade excessiva');

        // Se chegou aqui, resultado é uma falha - extrair usando exceptionOrNull
        final failure = result.exceptionOrNull() as AddItemSeparationFailure?;
        expect(failure, isNotNull, reason: 'Deveria ter uma falha');

        debugPrint('✅ Falha esperada: ${failure!.message}');
        expect(failure.type, equals(AddItemSeparationFailureType.insufficientQuantity));
        expect(failure.isBusinessError, isTrue);

        debugPrint('✅ Validação de quantidade insuficiente funcionou: ${failure.message}');
      }, timeout: const Timeout(Duration(minutes: 1)));
    });

    group('Testes de Múltiplas Separações', () {
      test('deve adicionar múltiplos itens e atualizar quantidade corretamente', () async {
        // Arrange
        debugPrint('🔧 Testando múltiplas separações...');

        // Primeiro, verificar estado inicial do item
        final initialSeparateItems = await separateItemRepository.select(
          QueryBuilder().equals('CodEmpresa', 1).equals('CodSepararEstoque', 999999).equals('CodProduto', 1),
        );

        final initialQuantitySeparated = initialSeparateItems.isNotEmpty
            ? initialSeparateItems.first.quantidadeSeparacao
            : 0.0;

        debugPrint('📊 Quantidade já separada no início: $initialQuantitySeparated');

        // Criar parâmetros para duas separações diferentes do mesmo produto
        final params1 = createTestAddItemSeparationParamsForMultiple1(sessionId);
        final params2 = createTestAddItemSeparationParamsForMultiple2(sessionId);

        // Act
        debugPrint('🚀 Executando primeira separação...');
        final result1 = await useCase.call(params1);
        await Future.delayed(const Duration(milliseconds: 500));

        debugPrint('🚀 Executando segunda separação...');
        final result2 = await useCase.call(params2);

        // Assert
        // Verificar se ambas tiveram sucesso
        expect(result1.isSuccess(), isTrue, reason: 'Primeira separação deveria ter sucesso');
        expect(result2.isSuccess(), isTrue, reason: 'Segunda separação deveria ter sucesso');

        debugPrint('✅ Primeira separação com sucesso');
        debugPrint('✅ Segunda separação com sucesso');

        final success1 = result1.getOrNull()!;
        final success2 = result2.getOrNull()!;

        // A quantidade total separada deve ser: inicial + primeira + segunda
        final expectedTotal = initialQuantitySeparated + success1.addedQuantity + success2.addedQuantity;
        expect(
          success2.newTotalSeparationQuantity,
          equals(expectedTotal),
          reason:
              'Quantidade total deve ser: inicial ($initialQuantitySeparated) + primeira (${success1.addedQuantity}) + segunda (${success2.addedQuantity}) = $expectedTotal',
        );

        // Validar incrementos individuais
        expect(
          success1.newTotalSeparationQuantity,
          equals(initialQuantitySeparated + success1.addedQuantity),
          reason: 'Primeira separação deve incrementar corretamente',
        );

        debugPrint('✅ Múltiplas separações funcionaram:');
        debugPrint('   Primeira: ${success1.operationSummary}');
        debugPrint('   Segunda: ${success2.operationSummary}');
        debugPrint('   Total acumulado: ${success2.newTotalSeparationQuantity}');
      }, timeout: const Timeout(Duration(minutes: 2)));
    });
  });
}
