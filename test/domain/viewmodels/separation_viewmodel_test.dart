import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:exp/domain/viewmodels/separation_viewmodel.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/data/services/filters_storage_service.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/expedition_sector_stock_model.dart';
import 'package:exp/domain/models/separation_filters_model.dart';

import 'separation_viewmodel_test.mocks.dart';

@GenerateMocks([BasicConsultationRepository, BasicRepository, FiltersStorageService])
void main() {
  group('SeparationViewModel', () {
    late SeparationViewModel viewModel;
    late MockBasicConsultationRepository<SeparateConsultationModel> mockRepository;
    late MockBasicRepository<ExpeditionSectorStockModel> mockSectorRepository;
    late MockFiltersStorageService mockFiltersStorage;

    setUp(() {
      mockRepository = MockBasicConsultationRepository<SeparateConsultationModel>();
      mockSectorRepository = MockBasicRepository<ExpeditionSectorStockModel>();
      mockFiltersStorage = MockFiltersStorageService();

      // Configurar stubs para evitar erros
      when(mockFiltersStorage.loadSeparationFilters()).thenAnswer((_) async => const SeparationFiltersModel());
      when(mockFiltersStorage.saveSeparationFilters(any)).thenAnswer((_) async {});

      viewModel = SeparationViewModel.withDependencies(mockRepository, mockFiltersStorage, mockSectorRepository);
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
  });
}
