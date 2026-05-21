import 'dart:async';

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

class _SequencedCartConsultation implements BasicConsultationRepository<ExpeditionCartConsultationModel> {
  _SequencedCartConsultation(this.responses);

  final List<Future<List<ExpeditionCartConsultationModel>>> responses;
  int _callCount = 0;

  @override
  Future<List<ExpeditionCartConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    final response = responses[_callCount];
    _callCount += 1;
    return response;
  }
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

  ExpeditionCartConsultationModel buildCart({
    required int codCarrinho,
    required String codigoBarras,
    ExpeditionCartSituation situacao = ExpeditionCartSituation.liberado,
  }) {
    return ExpeditionCartConsultationModel(
      codEmpresa: 1,
      codCarrinho: codCarrinho,
      descricaoCarrinho: 'Carrinho $codCarrinho',
      ativo: Situation.ativo,
      situacao: situacao,
      codigoBarras: codigoBarras,
    );
  }

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
      final scannedCart = buildCart(codCarrinho: 10, codigoBarras: 'ABC123');
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

    test('should clear stale cart data and stop countdown while a new scan is in progress', () async {
      final firstCart = buildCart(codCarrinho: 10, codigoBarras: 'ABC123');
      final secondCart = buildCart(codCarrinho: 11, codigoBarras: 'XYZ999');
      final secondScanCompleter = Completer<List<ExpeditionCartConsultationModel>>();
      final vm = AddCartViewModel(
        codEmpresa: 1,
        codSepararEstoque: 2,
        addCartUseCase: _FakeAddCartUseCase(Failure(Exception('not used'))),
        cartConsultationRepository: _SequencedCartConsultation([
          Future<List<ExpeditionCartConsultationModel>>.value([firstCart]),
          secondScanCompleter.future,
        ]),
        cartRouteRepository: _FakeCartRouteRepo(),
        startSeparationUseCase: _FakeStartSeparationUseCase(),
        audioService: _SilentAudioService(),
      );

      await vm.scanBarcode('ABC123');
      expect(vm.scannedCart?.codCarrinho, equals(10));
      expect(vm.isCountdownActive, isTrue);

      final pendingScan = vm.scanBarcode('XYZ999');
      await Future<void>.delayed(Duration.zero);

      expect(vm.isScanning, isTrue);
      expect(vm.hasCartData, isFalse);
      expect(vm.scannedCart, isNull);
      expect(vm.isCountdownActive, isFalse);

      secondScanCompleter.complete([secondCart]);
      await pendingScan;

      expect(vm.isScanning, isFalse);
      expect(vm.scannedCart?.codCarrinho, equals(11));
      expect(vm.isCountdownActive, isTrue);
    });

    test('should complete a pending scan safely after dispose', () async {
      final scanCompleter = Completer<List<ExpeditionCartConsultationModel>>();
      final vm = AddCartViewModel(
        codEmpresa: 1,
        codSepararEstoque: 2,
        addCartUseCase: _FakeAddCartUseCase(Failure(Exception('not used'))),
        cartConsultationRepository: _SequencedCartConsultation([scanCompleter.future]),
        cartRouteRepository: _FakeCartRouteRepo(),
        startSeparationUseCase: _FakeStartSeparationUseCase(),
        audioService: _SilentAudioService(),
      );

      final pendingScan = vm.scanBarcode('ABC123');
      await Future<void>.delayed(Duration.zero);

      vm.dispose();
      scanCompleter.complete([buildCart(codCarrinho: 10, codigoBarras: 'ABC123')]);

      await expectLater(pendingScan, completes);
    });
  });
}
