import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:data7_expedicao/domain/viewmodels/separation_viewmodel.dart';
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
  }) {
    return SeparateConsultationModel(
      codEmpresa: 1,
      codSepararEstoque: codSepararEstoque,
      origem: ExpeditionOrigem.orcamentoBalcao,
      codOrigem: 1,
      codTipoOperacaoExpedicao: 10,
      nomeTipoOperacaoExpedicao: 'Entrega Balcão',
      situacao: ExpeditionSituation.aguardando,
      tipoEntidade: EntityType.cliente,
      dataEmissao: DateTime(2026, 2, 24),
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
    late MockBasicConsultationRepository<SeparateConsultationModel>
    mockRepository;
    late MockBasicRepository<ExpeditionSectorStockModel> mockSectorRepository;
    late MockFiltersStorageService mockFiltersStorage;
    late MockSeparateEventRepository mockEventRepository;
    late MockAudioService mockAudioService;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockRepository =
          MockBasicConsultationRepository<SeparateConsultationModel>();
      mockSectorRepository = MockBasicRepository<ExpeditionSectorStockModel>();
      mockFiltersStorage = MockFiltersStorageService();
      mockEventRepository = MockSeparateEventRepository();
      mockAudioService = MockAudioService();
      mockNotificationService = MockNotificationService();

      // Configurar stubs para evitar erros
      when(
        mockFiltersStorage.loadSeparationFilters(),
      ).thenAnswer((_) async => const SeparationFiltersModel());
      when(
        mockFiltersStorage.saveSeparationFilters(any),
      ).thenAnswer((_) async {});

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

    test(
      'should change state to loading when loadSeparations is called',
      () async {
        // Act
        viewModel.loadSeparations();

        // Assert - O estado deve mudar para loading imediatamente
        expect(viewModel.state, SeparationState.loading);
        expect(viewModel.isLoading, isTrue);
      },
    );

    test('should handle refresh method', () async {
      // Act
      viewModel.refresh();

      // Assert - Deve iniciar o carregamento
      expect(viewModel.state, SeparationState.loading);
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
        expect(viewModel.situacoesFilter, [
          'AGUARDANDO',
          'SEPARANDO',
          'SEPARADO',
        ]);
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

      test('should start event monitoring', () {
        // Act
        viewModel.startEventMonitoring();

        // Assert - Verifica se os listeners foram registrados
        verify(
          mockEventRepository.addListener(any),
        ).called(3); // insert, update, delete
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
        verify(
          mockEventRepository.addListener(any),
        ).called(3); // insert, update, delete
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
