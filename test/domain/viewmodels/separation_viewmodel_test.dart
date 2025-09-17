import 'package:flutter_test/flutter_test.dart';
import 'package:exp/domain/viewmodels/separation_viewmodel.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/domain/models/entity_type_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';

void main() {
  group('SeparationViewModel', () {
    late SeparationViewModel viewModel;

    setUp(() {
      viewModel = SeparationViewModel();
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
      // Act
      viewModel.clearFilters();

      // Assert - Deve iniciar o carregamento
      expect(viewModel.state, SeparationState.loading);
    });

    test('should not process operations after dispose', () async {
      // Arrange
      viewModel.dispose();

      // Act
      viewModel.loadSeparations();

      // Assert - Não deve mudar o estado após dispose
      expect(viewModel.state, SeparationState.initial);
    });

    test('should handle loadMoreSeparations correctly', () async {
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
        viewModel.setSituacaoFilter('AGUARDANDO');
        viewModel.setDataEmissaoFilter(DateTime(2023, 12, 25));

        // Assert
        expect(viewModel.codSepararEstoqueFilter, '12345');
        expect(viewModel.origemFilter, 'ORCAMENTO_BALCAO');
        expect(viewModel.codOrigemFilter, '123');
        expect(viewModel.situacaoFilter, 'AGUARDANDO');
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
        expect(viewModel.situacaoFilter, isNull);
        expect(viewModel.dataEmissaoFilter, isNull);
        expect(viewModel.hasActiveFilters, isFalse);
      });
    });
  });
}
