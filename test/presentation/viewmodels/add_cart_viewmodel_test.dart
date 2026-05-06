import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_usecase.dart';
import 'package:data7_expedicao/presentation/viewmodels/add_cart_viewmodel.dart';

class MockAddCartUseCase extends Mock implements AddCartUseCase {}

class MockStartSeparationUseCase extends Mock implements StartSeparationUseCase {}

class _EmptyCartConsultation implements BasicConsultationRepository<ExpeditionCartConsultationModel> {
  @override
  Future<List<ExpeditionCartConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async => [];
}

class _FakeCartRouteRepo implements BasicRepository<ExpeditionCartRouteModel> {
  @override
  Future<List<ExpeditionCartRouteModel>> delete(ExpeditionCartRouteModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteModel>> insert(ExpeditionCartRouteModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteModel>> select(QueryBuilder queryBuilder) async => [];

  @override
  Future<List<ExpeditionCartRouteModel>> update(ExpeditionCartRouteModel entity) async => [entity];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AddCartViewModel', () {
    test('scanBarcode define erro quando nenhum carrinho corresponde', () async {
      AudioService().setEnabled(false);
      final vm = AddCartViewModel(
        codEmpresa: 1,
        codSepararEstoque: 2,
        addCartUseCase: MockAddCartUseCase(),
        cartConsultationRepository: _EmptyCartConsultation(),
        cartRouteRepository: _FakeCartRouteRepo(),
        startSeparationUseCase: MockStartSeparationUseCase(),
        audioService: AudioService(),
      );

      await vm.scanBarcode('unknown');

      expect(vm.hasError, isTrue);
      expect(vm.errorMessage, contains('não encontrado'));
      expect(vm.hasCartData, isFalse);
    });
  });
}
