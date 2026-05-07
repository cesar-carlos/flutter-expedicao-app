import 'package:flutter_test/flutter_test.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_success.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_usecase.dart';
import 'package:data7_expedicao/presentation/viewmodels/add_cart_viewmodel.dart';

class _FakeAddCartUseCase extends Fake implements AddCartUseCase {
  _FakeAddCartUseCase(this.result);

  final Result<AddCartSuccess> result;

  @override
  Future<Result<AddCartSuccess>> call(params) async => result;
}

class _FakeStartSeparationUseCase extends Fake implements StartSeparationUseCase {}

class _SilentAudioService extends Fake implements AudioService {
  @override
  Future<void> playBarcodeScan() async {}

  @override
  Future<void> playCartAddSuccess() async {}

  @override
  Future<void> playError() async {}
}

class _EmptyCartConsultation implements BasicConsultationRepository<ExpeditionCartConsultationModel> {
  @override
  Future<List<ExpeditionCartConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async => [];
}

class _SingleCartConsultation implements BasicConsultationRepository<ExpeditionCartConsultationModel> {
  _SingleCartConsultation(this.cart);

  final ExpeditionCartConsultationModel cart;

  @override
  Future<List<ExpeditionCartConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async => [cart];
}

class _FakeCartRouteRepo implements BasicRepository<ExpeditionCartRouteModel> {
  _FakeCartRouteRepo({this.routes = const <ExpeditionCartRouteModel>[]});

  final List<ExpeditionCartRouteModel> routes;

  @override
  Future<List<ExpeditionCartRouteModel>> delete(ExpeditionCartRouteModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteModel>> insert(ExpeditionCartRouteModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteModel>> select(QueryBuilder queryBuilder) async => routes;

  @override
  Future<List<ExpeditionCartRouteModel>> update(ExpeditionCartRouteModel entity) async => [entity];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AddCartViewModel', () {
    test('should set error when scanBarcode finds no cart', () async {
      final vm = AddCartViewModel(
        codEmpresa: 1,
        codSepararEstoque: 2,
        addCartUseCase: _FakeAddCartUseCase(Failure(Exception('not used'))),
        cartConsultationRepository: _EmptyCartConsultation(),
        cartRouteRepository: _FakeCartRouteRepo(),
        startSeparationUseCase: _FakeStartSeparationUseCase(),
        audioService: _SilentAudioService(),
      );

      await vm.scanBarcode('unknown');

      expect(vm.hasError, isTrue);
      expect(vm.errorMessage, contains('encontrado'));
      expect(vm.hasCartData, isFalse);
    });

    test('should store lastAddSuccess when addCartToSeparation succeeds', () async {
      final scannedCart = ExpeditionCartConsultationModel(
        codEmpresa: 1,
        codCarrinho: 10,
        descricaoCarrinho: 'Carrinho 10',
        ativo: Situation.ativo,
        situacao: ExpeditionCartSituation.liberado,
        codigoBarras: 'ABC123',
      );
      final addCartUseCase = _FakeAddCartUseCase(
        Success(AddCartSuccess(addedCart: scannedCart, message: 'ok', codCarrinhoPercurso: 20)),
      );
      final startSeparationUseCase = _FakeStartSeparationUseCase();
      final existingRoute = ExpeditionCartRouteModel(
        codEmpresa: 1,
        codCarrinhoPercurso: 20,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 2,
        situacao: ExpeditionCartSituation.emSeparacao,
        dataInicio: DateTime(2026, 1, 1),
        horaInicio: '10:00:00',
      );

      final vm = AddCartViewModel(
        codEmpresa: 1,
        codSepararEstoque: 2,
        addCartUseCase: addCartUseCase,
        cartConsultationRepository: _SingleCartConsultation(scannedCart),
        cartRouteRepository: _FakeCartRouteRepo(routes: [existingRoute]),
        startSeparationUseCase: startSeparationUseCase,
        audioService: _SilentAudioService(),
      );

      await vm.scanBarcode('ABC123');
      final added = await vm.addCartToSeparation();

      expect(added, isTrue);
      expect(vm.lastAddSuccess, isNotNull);
      expect(vm.lastAddSuccess!.addedCart.codCarrinho, equals(10));
      expect(vm.lastAddSuccess!.codCarrinhoPercurso, equals(20));
    });
  });
}
