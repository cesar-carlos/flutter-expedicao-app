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
  });
}
