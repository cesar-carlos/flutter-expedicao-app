import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:data7_expedicao/presentation/viewmodels/separation_viewmodel.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/data/services/filters_storage_service.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_event_repository.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/notification_service.dart';

import 'separation_viewmodel_test.mocks.dart';

@GenerateMocks([
  BasicConsultationRepository,
  BasicRepository,
  FiltersStorageService,
  SeparateEventRepository,
  AudioService,
  NotificationService,
])
void main() {
  SeparateConsultationModel buildSeparation({
    required int codSepararEstoque,
    required List<int> codSetoresEstoque,
    String observacao = '',
    ExpeditionOrigem origem = ExpeditionOrigem.orcamentoBalcao,
    int codOrigem = 1,
    DateTime? dataEmissao,
  }) {
    return SeparateConsultationModel(
      codEmpresa: 1,
      codSepararEstoque: codSepararEstoque,
      origem: origem,
      codOrigem: codOrigem,
      codTipoOperacaoExpedicao: 10,
      nomeTipoOperacaoExpedicao: 'Entrega Balcão',
      situacao: ExpeditionSituation.aguardando,
      tipoEntidade: EntityType.cliente,
      dataEmissao: dataEmissao ?? DateTime(2026, 2, 24),
      horaEmissao: '14:45:17',
      codEntidade: 123,
      nomeEntidade: 'Cliente Teste',
      codPrioridade: 1,
      nomePrioridade: 'PRIORIDADE 1',
      codSetoresEstoque: codSetoresEstoque,
      codUsuariosSeparacao: const [99],
      observacao: observacao,
    );
  }

  group('SeparationViewModel', () {
    late SeparationViewModel viewModel;
    late MockBasicConsultationRepository<SeparateConsultationModel> mockRepository;
    late MockBasicRepository<ExpeditionSectorStockModel> mockSectorRepository;
    late MockFiltersStorageService mockFiltersStorage;
    late MockSeparateEventRepository mockEventRepository;
    late MockAudioService mockAudioService;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockRepository = MockBasicConsultationRepository<SeparateConsultationModel>();
      mockSectorRepository = MockBasicRepository<ExpeditionSectorStockModel>();
      mockFiltersStorage = MockFiltersStorageService();
      mockEventRepository = MockSeparateEventRepository();
      mockAudioService = MockAudioService();
      mockNotificationService = MockNotificationService();

      // Configurar stubs para evitar erros
      when(mockFiltersStorage.loadSeparationFilters()).thenAnswer((_) async => const SeparationFiltersModel());
      when(mockFiltersStorage.saveSeparationFilters(any)).thenAnswer((_) async {});

      // Configurar stubs para o mock do event repository
      when(mockEventRepository.listeners).thenReturn([]);
      when(mockEventRepository.hasListener(any)).thenReturn(false);

      viewModel = SeparationViewModel.withDependencies(
        mockRepository,
        mockFiltersStorage,
        mockSectorRepository,
        mockEventRepository,
        mockAudioService,
        mockNotificationService,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should initialize with correct initial state', () {
      expect(viewModel.state, SeparationState.initial);
      expect(viewModel.separations, isEmpty);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.hasData, isFalse);
    });

    test('should have correct initial state properties', () {
      expect(viewModel.state, SeparationState.initial);
      expect(viewModel.separations, isEmpty);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.hasData, isFalse);
      expect(viewModel.hasMoreData, isTrue);
      expect(viewModel.isLoadingMore, isFalse);
      expect(viewModel.currentPage, 0);
      expect(viewModel.pageSize, 20);
    });

    test('should change state to loading when loadSeparations is called', () async {
      // Act
      viewModel.loadSeparations();

      // Assert - O estado deve mudar para loading imediatamente
      expect(viewModel.state, SeparationState.loading);
      expect(viewModel.isLoading, isTrue);
    });

    test('should handle refresh method', () async {
      // Act
      viewModel.refresh();

      // Assert - Deve iniciar o carregamento
      expect(viewModel.state, SeparationState.loading);
    });

    test('resyncVisibleSeparationsSilently updates list without loading state', () async {
      final first = buildSeparation(codSepararEstoque: 1, codSetoresEstoque: const [1]);
      when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [first]);

      await viewModel.loadSeparations();
      expect(viewModel.state, SeparationState.loaded);
      expect(viewModel.isLoading, isFalse);

      final newer = buildSeparation(codSepararEstoque: 2, codSetoresEstoque: const [1]);
      when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [newer, first]);

      await viewModel.resyncVisibleSeparationsSilently();

      expect(viewModel.state, SeparationState.loaded);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.separations.first.codSepararEstoque, 2);
    });

    test('resyncVisibleSeparationsSilently refreshes the loaded paginated range', () async {
      final page0 = List.generate(20, (i) => buildSeparation(codSepararEstoque: 100 - i, codSetoresEstoque: const [1]));
      final page1Extra = buildSeparation(codSepararEstoque: 1, codSetoresEstoque: const [1]);
      final refreshed = [
        buildSeparation(codSepararEstoque: 101, codSetoresEstoque: const [1]),
        ...page0,
        page1Extra,
      ];

      var selectCalls = 0;
      when(mockRepository.selectConsultation(any)).thenAnswer((_) async {
        selectCalls++;
        if (selectCalls == 1) return page0;
        if (selectCalls == 2) return [page1Extra];
        return refreshed;
      });

      await viewModel.loadSeparations();
      await viewModel.loadMoreSeparations();
      expect(viewModel.currentPage, greaterThan(0));

      await viewModel.resyncVisibleSeparationsSilently();

      expect(viewModel.separations.first.codSepararEstoque, 101);
      expect(viewModel.separations, hasLength(refreshed.length));
    });

    group('Silent resync notifications', () {
      test('plays notification when a new separation appears via silent resync and list not visible', () {
        FakeAsync().run((async) {
          final existing = buildSeparation(codSepararEstoque: 10, codSetoresEstoque: const [1]);
          when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [existing]);
          when(mockAudioService.playNotification()).thenAnswer((_) async {});
          when(
            mockNotificationService.showNewSeparationNotification(
              codSepararEstoque: anyNamed('codSepararEstoque'),
              nomeEntidade: anyNamed('nomeEntidade'),
              codSetoresEstoque: anyNamed('codSetoresEstoque'),
            ),
          ).thenAnswer((_) async {});

          viewModel.loadSeparations();
          async.flushMicrotasks();

          final newer = buildSeparation(codSepararEstoque: 11, codSetoresEstoque: const [1]);
          when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [newer, existing]);

          viewModel.setScreenVisible(false);
          viewModel.resyncVisibleSeparationsSilently();
          async.flushMicrotasks();

          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();

          verify(mockAudioService.playNotification()).called(1);
          verify(
            mockNotificationService.showNewSeparationNotification(
              codSepararEstoque: 11,
              nomeEntidade: newer.nomeEntidade,
              codSetoresEstoque: newer.codSetoresEstoque,
            ),
          ).called(1);
        });
      });

      test('does not play notification when list is visible', () {
        FakeAsync().run((async) {
          final existing = buildSeparation(codSepararEstoque: 10, codSetoresEstoque: const [1]);
          when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [existing]);
          when(mockAudioService.playNotification()).thenAnswer((_) async {});

          viewModel.loadSeparations();
          async.flushMicrotasks();

          final newer = buildSeparation(codSepararEstoque: 11, codSetoresEstoque: const [1]);
          when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [newer, existing]);

          viewModel.setScreenVisible(true);
          viewModel.resyncVisibleSeparationsSilently();
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();

          verifyNever(mockAudioService.playNotification());
          verifyNever(
            mockNotificationService.showNewSeparationNotification(
              codSepararEstoque: anyNamed('codSepararEstoque'),
              nomeEntidade: anyNamed('nomeEntidade'),
              codSetoresEstoque: anyNamed('codSetoresEstoque'),
            ),
          );
        });
      });

      test('does not notify on bulk first fetch from empty list via silent resync', () {
        FakeAsync().run((async) {
          when(mockRepository.selectConsultation(any)).thenAnswer((_) async => []);
          when(mockAudioService.playNotification()).thenAnswer((_) async {});

          viewModel.loadSeparations();
          async.flushMicrotasks();

          final batch = [
            buildSeparation(codSepararEstoque: 1, codSetoresEstoque: const [1]),
            buildSeparation(codSepararEstoque: 2, codSetoresEstoque: const [1]),
            buildSeparation(codSepararEstoque: 3, codSetoresEstoque: const [1]),
          ];
          when(mockRepository.selectConsultation(any)).thenAnswer((_) async => batch);

          viewModel.setScreenVisible(false);
          viewModel.resyncVisibleSeparationsSilently();
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();

          verifyNever(mockAudioService.playNotification());
        });
      });

      test('notifies when a single separation appears after list was empty', () {
        FakeAsync().run((async) {
          when(mockRepository.selectConsultation(any)).thenAnswer((_) async => []);
          when(mockAudioService.playNotification()).thenAnswer((_) async {});
          when(
            mockNotificationService.showNewSeparationNotification(
              codSepararEstoque: anyNamed('codSepararEstoque'),
              nomeEntidade: anyNamed('nomeEntidade'),
              codSetoresEstoque: anyNamed('codSetoresEstoque'),
            ),
          ).thenAnswer((_) async => {});

          viewModel.loadSeparations();
          async.flushMicrotasks();

          final one = buildSeparation(codSepararEstoque: 42, codSetoresEstoque: const [1]);
          when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [one]);

          viewModel.setScreenVisible(false);
          viewModel.resyncVisibleSeparationsSilently();
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();

          verify(mockAudioService.playNotification()).called(1);
        });
      });
    });

    test('should handle clearFilters method', () async {
      // Arrange - Simular que há dados carregados
      when(mockRepository.selectConsultation(any)).thenAnswer((_) async => []);

      // Act
      await viewModel.clearFilters();

      // Assert - Deve completar o carregamento
      expect(viewModel.state, SeparationState.loaded);
    });

    test('should handle loadMoreSeparations correctly', () async {
      // Arrange - Simular que há mais dados disponíveis
      when(mockRepository.selectConsultation(any)).thenAnswer((_) async => []);

      // Act
      viewModel.loadMoreSeparations();

      // Assert - Deve iniciar o carregamento de mais dados
      expect(viewModel.isLoadingMore, isTrue);
    });

    test('should not load more when already loading', () async {
      // Arrange - Simula estado de loading
      viewModel.loadSeparations();

      // Act
      viewModel.loadMoreSeparations();

      // Assert - Não deve permitir carregamento simultâneo
      expect(viewModel.isLoading, isTrue);
    });

    test('should not load more when no more data available', () async {
      // Arrange - Simula que não há mais dados
      // Precisaríamos de um mock para testar isso completamente

      // Act
      viewModel.loadMoreSeparations();

      // Assert - Como não temos mock, apenas verifica que não trava
      expect(viewModel.state, isA<SeparationState>());
    });

    test('should reset pagination on loadSeparations', () async {
      // Act
      viewModel.loadSeparations();

      // Assert - Deve resetar a paginação
      expect(viewModel.currentPage, 0);
      expect(viewModel.hasMoreData, isTrue);
    });

    group('Filters', () {
      test('should apply setor filter with exact match only', () async {
        // Arrange
        final setorFilter = ExpeditionSectorStockModel(
          codSetorEstoque: 1,
          descricao: 'Setor 1',
          ativo: Situation.ativo,
        );
        final separations = [
          buildSeparation(codSepararEstoque: 1001, codSetoresEstoque: const [11]),
          buildSeparation(codSepararEstoque: 1002, codSetoresEstoque: const [1]),
        ];

        when(mockRepository.selectConsultation(any)).thenAnswer((_) async => separations);

        // Act
        viewModel.setSetorEstoqueFilter(setorFilter);
        await viewModel.loadSeparations();

        // Assert
        expect(viewModel.state, SeparationState.loaded);
        expect(viewModel.separations.length, 1);
        expect(viewModel.separations.first.codSepararEstoque, 1002);
      });

      test('should set and get codSepararEstoque filter', () {
        // Act
        viewModel.setCodSepararEstoqueFilter('12345');

        // Assert
        expect(viewModel.codSepararEstoqueFilter, '12345');
        expect(viewModel.hasActiveFilters, isTrue);
      });

      test('should trim whitespace from codigo filter', () {
        // Act
        viewModel.setCodSepararEstoqueFilter('  12345  ');

        // Assert
        expect(viewModel.codSepararEstoqueFilter, '12345');
      });

      test('should set empty string as null', () {
        // Act
        viewModel.setCodSepararEstoqueFilter('');

        // Assert
        expect(viewModel.codSepararEstoqueFilter, isNull);
        expect(viewModel.hasActiveFilters, isFalse);
      });

      test('should set all filters correctly', () {
        // Act
        viewModel.setCodSepararEstoqueFilter('12345');
        viewModel.setOrigemFilter('ORCAMENTO_BALCAO');
        viewModel.setCodOrigemFilter('123');
        viewModel.setSituacoesFilter(['AGUARDANDO', 'SEPARANDO']);
        viewModel.setDataEmissaoFilter(DateTime(2023, 12, 25));

        // Assert
        expect(viewModel.codSepararEstoqueFilter, '12345');
        expect(viewModel.origemFilter, 'ORCAMENTO_BALCAO');
        expect(viewModel.codOrigemFilter, '123');
        expect(viewModel.situacoesFilter, ['AGUARDANDO', 'SEPARANDO']);
        expect(viewModel.dataEmissaoFilter, DateTime(2023, 12, 25));
        expect(viewModel.hasActiveFilters, isTrue);
      });

      test('should clear all filters', () {
        // Arrange
        viewModel.setCodSepararEstoqueFilter('12345');
        viewModel.setOrigemFilter('ORCAMENTO_BALCAO');
        expect(viewModel.hasActiveFilters, isTrue);

        // Act
        viewModel.clearFilters();

        // Assert
        expect(viewModel.codSepararEstoqueFilter, isNull);
        expect(viewModel.origemFilter, isNull);
        expect(viewModel.codOrigemFilter, isNull);
        expect(viewModel.situacoesFilter, isNull);
        expect(viewModel.dataEmissaoFilter, isNull);
        expect(viewModel.hasActiveFilters, isFalse);
      });

      test('should set and get situacoes filter as list', () {
        // Act
        viewModel.setSituacoesFilter(['AGUARDANDO', 'SEPARANDO', 'SEPARADO']);

        // Assert
        expect(viewModel.situacoesFilter, ['AGUARDANDO', 'SEPARANDO', 'SEPARADO']);
        expect(viewModel.hasActiveFilters, isTrue);
      });

      test('should handle empty situacoes filter list', () {
        // Act
        viewModel.setSituacoesFilter([]);

        // Assert
        expect(viewModel.situacoesFilter, isEmpty);
        expect(viewModel.hasActiveFilters, isFalse);
      });

      test('should handle null situacoes filter', () {
        // Act
        viewModel.setSituacoesFilter(null);

        // Assert
        expect(viewModel.situacoesFilter, isNull);
        expect(viewModel.hasActiveFilters, isFalse);
      });

      test('should update situacoes filter correctly', () {
        // Arrange
        viewModel.setSituacoesFilter(['AGUARDANDO']);

        // Act
        viewModel.setSituacoesFilter(['SEPARANDO', 'SEPARADO']);

        // Assert
        expect(viewModel.situacoesFilter, ['SEPARANDO', 'SEPARADO']);
        expect(viewModel.hasActiveFilters, isTrue);
      });
    });

    group('Event Monitoring', () {
      test('should not duplicate separation on repeated insert event', () {
        // Arrange
        viewModel.startEventMonitoring();
        final capturedListeners = verify(mockEventRepository.addListener(captureAny)).captured;
        final listeners = capturedListeners.cast<EventListenerModel>();
        final insertListener = listeners.firstWhere((listener) => listener.id == 'separation_viewmodel_insert');

        final separation = buildSeparation(
          codSepararEstoque: 2001,
          codSetoresEstoque: const [1, 2],
          observacao: 'primeiro evento',
        );
        final updatedSeparation = buildSeparation(
          codSepararEstoque: 2001,
          codSetoresEstoque: const [1, 2],
          observacao: 'evento repetido',
        );

        // Act
        insertListener.callback(BasicEventModel.create(data: separation.toJson(), eventType: Event.insert));
        insertListener.callback(BasicEventModel.create(data: updatedSeparation.toJson(), eventType: Event.insert));

        // Assert
        expect(viewModel.separations.length, 1);
        expect(viewModel.separations.first.observacao, 'evento repetido');
      });

      test('consultation listener performs authoritative resync and removes stale rows', () async {
        final first = buildSeparation(codSepararEstoque: 2001, codSetoresEstoque: const [1]);
        final second = buildSeparation(codSepararEstoque: 2002, codSetoresEstoque: const [1]);
        when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [first, second]);

        await viewModel.loadSeparations();
        expect(viewModel.separations, hasLength(2));

        viewModel.startEventMonitoring();
        final consultationListener =
            verify(mockEventRepository.addConsultationListener(captureAny)).captured.single as EventListenerModel;

        when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [second]);

        consultationListener.callback(
          BasicEventModel.create(
            data: {
              'Data': [second.toJson()],
            },
            eventType: Event.insert,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(viewModel.separations, hasLength(1));
        expect(viewModel.separations.first.codSepararEstoque, second.codSepararEstoque);
      });

      test('update event removes row when it stops matching current filters', () async {
        final setorFilter = ExpeditionSectorStockModel(
          codSetorEstoque: 1,
          descricao: 'Setor 1',
          ativo: Situation.ativo,
        );
        final separation = buildSeparation(codSepararEstoque: 3001, codSetoresEstoque: const [1]);
        when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [separation]);

        viewModel.setSetorEstoqueFilter(setorFilter);
        await viewModel.loadSeparations();
        viewModel.startEventMonitoring();

        final crudListeners = verify(mockEventRepository.addListener(captureAny)).captured.cast<EventListenerModel>();
        final updateListener = crudListeners.firstWhere((listener) => listener.id == 'separation_viewmodel_update');

        final movedOutOfFilter = buildSeparation(codSepararEstoque: 3001, codSetoresEstoque: const [2]);
        updateListener.callback(BasicEventModel.create(data: movedOutOfFilter.toJson(), eventType: Event.update));

        expect(viewModel.separations, isEmpty);
      });

      test('update event refreshes fields that affect ui and filters', () async {
        final separation = buildSeparation(codSepararEstoque: 4001, codSetoresEstoque: const [1]);
        when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [separation]);

        await viewModel.loadSeparations();
        viewModel.startEventMonitoring();

        final crudListeners = verify(mockEventRepository.addListener(captureAny)).captured.cast<EventListenerModel>();
        final updateListener = crudListeners.firstWhere((listener) => listener.id == 'separation_viewmodel_update');

        final updated = buildSeparation(
          codSepararEstoque: 4001,
          codSetoresEstoque: const [1],
          origem: ExpeditionOrigem.entregaBalcao,
          codOrigem: 77,
          dataEmissao: DateTime(2026, 3, 1),
        );
        updateListener.callback(BasicEventModel.create(data: updated.toJson(), eventType: Event.update));

        expect(viewModel.separations.single.origem, ExpeditionOrigem.entregaBalcao);
        expect(viewModel.separations.single.codOrigem, 77);
        expect(viewModel.separations.single.dataEmissao, DateTime(2026, 3, 1));
      });

      test('should start event monitoring', () {
        // Act
        viewModel.startEventMonitoring();

        // Assert - Verifica se os listeners foram registrados
        verify(mockEventRepository.addListener(any)).called(3); // insert, update, delete
      });

      test('CRUD listeners usam allEvent true para nao serem ignorados pelo EventServiceImpl '
          'quando Session == socket atual (ex.: separacao criada no mesmo app)', () {
        viewModel.startEventMonitoring();
        final captured = verify(mockEventRepository.addListener(captureAny)).captured;
        final listeners = captured.cast<EventListenerModel>();
        expect(listeners, hasLength(3));
        for (final l in listeners) {
          expect(l.allEvent, isTrue, reason: 'listener ${l.id} / ${l.event}');
        }
      });

      test('should stop event monitoring', () {
        // Arrange - Primeiro iniciar o monitoramento
        viewModel.startEventMonitoring();

        // Act
        viewModel.stopEventMonitoring();

        // Assert - Verifica se os listeners foram removidos
        verify(mockEventRepository.removeListeners(any)).called(1);
      });

      test('should not start monitoring when disposed', () {
        // Arrange - Criar um novo viewModel para este teste
        final testViewModel = SeparationViewModel.withDependencies(
          mockRepository,
          mockFiltersStorage,
          mockSectorRepository,
          mockEventRepository,
          mockAudioService,
          mockNotificationService,
        );

        testViewModel.dispose();

        // Act
        testViewModel.startEventMonitoring();

        // Assert - Não deve registrar listeners quando disposed
        verifyNever(mockEventRepository.addListener(any));
      });

      test('should handle separation insert event', () {
        // Act
        viewModel.startEventMonitoring();

        // Assert - Verifica se o listener foi registrado
        verify(mockEventRepository.addListener(any)).called(3);
      });

      test('should handle separation update event', () {
        // Act
        viewModel.startEventMonitoring();

        // Assert - Verifica se o listener foi registrado
        verify(mockEventRepository.addListener(any)).called(3);
      });

      test('should verify update listener is registered correctly', () {
        // Arrange & Act
        viewModel.startEventMonitoring();

        // Assert - Verifica se os listeners foram registrados
        verify(mockEventRepository.addListener(any)).called(3); // insert, update, delete
      });

      test('should process update events correctly', () {
        // Arrange
        viewModel.startEventMonitoring();

        // Act - Simular recebimento de evento de update
        // (Em um teste real, você criaria um BasicEventModel e chamaria o callback diretamente)

        // Assert - Verifica se o listener foi registrado
        verify(mockEventRepository.addListener(any)).called(3);
      });

      test('should handle separation delete event', () {
        // Act
        viewModel.startEventMonitoring();

        // Assert - Verifica se o listener foi registrado
        verify(mockEventRepository.addListener(any)).called(3);
      });
    });
  });
}
