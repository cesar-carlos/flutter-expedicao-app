import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/expedition_cancellation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_failure.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_usecase.dart';

import '../../../support/fake_user_session_service.dart';

void main() {
  const params = CancelCartParams(codEmpresa: 1, codCarrinhoPercurso: 200, item: '0001');

  group('CancelCartParams', () {
    test('should report empty item as percurso item error', () {
      const invalid = CancelCartParams(codEmpresa: 1, codCarrinhoPercurso: 200, item: '');

      expect(invalid.isValid, isFalse);
      expect(invalid.validationErrors.single, contains('Item do percurso'));
    });
  });

  group('CancelCartUseCase', () {
    test('DataError no insert de cancelamento vira NetworkFailure', () async {
      final cartRouteRepository = _MemoryCartRouteRepository(_cartRoute());
      final cancellationRepository = _ThrowingCancellationRepository();
      final cartRepository = _MemoryCartRepository(_cart());
      final userSessionService = FakeUserSessionService();

      final useCase = CancelCartUseCase(
        cartRepository: cartRepository,
        cancellationRepository: cancellationRepository,
        cartInternshipRouteRepository: cartRouteRepository,
        userSessionService: userSessionService,
      );

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<NetworkFailure>());
      expect(cartRouteRepository.item.situacao, ExpeditionSituation.separando);
      expect(cartRepository.item?.situacao, ExpeditionCartSituation.emSeparacao);
    });

    test('should reject when internship is not SEPARANDO without writing', () async {
      final cartRouteRepository = _MemoryCartRouteRepository(
        _cartRoute().copyWith(situacao: ExpeditionSituation.separado),
      );
      final cancellationRepository = _MemoryCancellationRepository();
      final cartRepository = _MemoryCartRepository(_cart());

      final useCase = CancelCartUseCase(
        cartRepository: cartRepository,
        cancellationRepository: cancellationRepository,
        cartInternshipRouteRepository: cartRouteRepository,
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      expect((result.exceptionOrNull() as CancelCartFailure).type, CancelCartFailureType.cartNotInSeparatingStatus);
      expect(cancellationRepository.items, isEmpty);
      expect(cartRouteRepository.item.situacao, ExpeditionSituation.separado);
      expect(cartRepository.item?.situacao, ExpeditionCartSituation.emSeparacao);
    });

    test('should not create cancellation when physical cart is missing', () async {
      final cancellationRepository = _MemoryCancellationRepository();
      final useCase = CancelCartUseCase(
        cartRepository: _MemoryCartRepository(null),
        cancellationRepository: cancellationRepository,
        cartInternshipRouteRepository: _MemoryCartRouteRepository(_cartRoute()),
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      expect((result.exceptionOrNull() as CancelCartFailure).type, CancelCartFailureType.cartNotFound);
      expect(cancellationRepository.items, isEmpty);
    });

    test('should rollback route and cancellation when cart update fails', () async {
      final cartRouteRepository = _MemoryCartRouteRepository(_cartRoute());
      final cancellationRepository = _MemoryCancellationRepository();
      final cartRepository = _MemoryCartRepository(_cart(), failFirstUpdate: true);

      final useCase = CancelCartUseCase(
        cartRepository: cartRepository,
        cancellationRepository: cancellationRepository,
        cartInternshipRouteRepository: cartRouteRepository,
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      expect(cartRouteRepository.item.situacao, ExpeditionSituation.separando);
      expect(cartRepository.item?.situacao, ExpeditionCartSituation.emSeparacao);
      expect(cancellationRepository.items, isEmpty);
    });

    test('should rollback cancellation when route update returns empty', () async {
      final cartRouteRepository = _MemoryCartRouteRepository(_cartRoute(), emptyUpdate: true);
      final cancellationRepository = _MemoryCancellationRepository();
      final cartRepository = _MemoryCartRepository(_cart());

      final useCase = CancelCartUseCase(
        cartRepository: cartRepository,
        cancellationRepository: cancellationRepository,
        cartInternshipRouteRepository: cartRouteRepository,
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      expect((result.exceptionOrNull() as CancelCartFailure).type, CancelCartFailureType.updateFailed);
      expect(cartRepository.item?.situacao, ExpeditionCartSituation.emSeparacao);
      expect(cancellationRepository.items, isEmpty);
    });

    test('should cancel internship and release physical cart', () async {
      final cartRouteRepository = _MemoryCartRouteRepository(_cartRoute());
      final cancellationRepository = _MemoryCancellationRepository();
      final cartRepository = _MemoryCartRepository(_cart());

      final useCase = CancelCartUseCase(
        cartRepository: cartRepository,
        cancellationRepository: cancellationRepository,
        cartInternshipRouteRepository: cartRouteRepository,
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(params);

      expect(result.isSuccess(), isTrue);
      expect(cartRouteRepository.item.situacao, ExpeditionSituation.cancelada);
      expect(cartRepository.item?.situacao, ExpeditionCartSituation.liberado);
      expect(cancellationRepository.items, isNotEmpty);
    });
  });
}

class _MemoryCartRouteRepository implements BasicRepository<ExpeditionCartRouteInternshipModel> {
  _MemoryCartRouteRepository(this.item, {this.emptyUpdate = false});

  ExpeditionCartRouteInternshipModel item;
  final bool emptyUpdate;

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> delete(ExpeditionCartRouteInternshipModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> insert(ExpeditionCartRouteInternshipModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> select(QueryBuilder queryBuilder) async => [item];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> update(ExpeditionCartRouteInternshipModel entity) async {
    if (emptyUpdate) return [];
    item = entity;
    return [entity];
  }
}

class _ThrowingCancellationRepository implements BasicRepository<ExpeditionCancellationModel> {
  @override
  Future<List<ExpeditionCancellationModel>> delete(ExpeditionCancellationModel entity) async => [entity];

  @override
  Future<List<ExpeditionCancellationModel>> insert(ExpeditionCancellationModel entity) async {
    throw DataError(message: 'timeout');
  }

  @override
  Future<List<ExpeditionCancellationModel>> select(QueryBuilder queryBuilder) async => [];

  @override
  Future<List<ExpeditionCancellationModel>> update(ExpeditionCancellationModel entity) async => [entity];
}

class _MemoryCancellationRepository implements BasicRepository<ExpeditionCancellationModel> {
  final List<ExpeditionCancellationModel> items = [];

  @override
  Future<List<ExpeditionCancellationModel>> delete(ExpeditionCancellationModel entity) async {
    items.removeWhere((e) => e.codEmpresa == entity.codEmpresa && e.codCancelamento == entity.codCancelamento);
    return [entity];
  }

  @override
  Future<List<ExpeditionCancellationModel>> insert(ExpeditionCancellationModel entity) async {
    final stored = entity.copyWith(codCancelamento: items.length + 1);
    items.add(stored);
    return [stored];
  }

  @override
  Future<List<ExpeditionCancellationModel>> select(QueryBuilder queryBuilder) async {
    return List<ExpeditionCancellationModel>.from(items);
  }

  @override
  Future<List<ExpeditionCancellationModel>> update(ExpeditionCancellationModel entity) async => [entity];
}

class _MemoryCartRepository implements BasicRepository<ExpeditionCartModel> {
  _MemoryCartRepository(ExpeditionCartModel? item, {this.failFirstUpdate = false}) : item = item;

  ExpeditionCartModel? item;
  final bool failFirstUpdate;
  int _updates = 0;

  @override
  Future<List<ExpeditionCartModel>> delete(ExpeditionCartModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartModel>> insert(ExpeditionCartModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartModel>> select(QueryBuilder queryBuilder) async => [?item];

  @override
  Future<List<ExpeditionCartModel>> update(ExpeditionCartModel entity) async {
    _updates++;
    if (failFirstUpdate && _updates == 1) {
      throw Exception('Falha simulada na atualização do carrinho');
    }
    item = entity;
    return [entity];
  }
}

ExpeditionCartRouteInternshipModel _cartRoute() {
  return ExpeditionCartRouteInternshipModel(
    codEmpresa: 1,
    codCarrinhoPercurso: 200,
    item: '0001',
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codPercursoEstagio: 1,
    codCarrinho: 300,
    situacao: ExpeditionSituation.separando,
    dataInicio: DateTime(2026, 1, 1),
    horaInicio: '10:00:00',
    codUsuarioInicio: 1,
    nomeUsuarioInicio: 'User',
  );
}

ExpeditionCartModel _cart() {
  return ExpeditionCartModel(
    codEmpresa: 1,
    codCarrinho: 300,
    descricao: 'Carrinho Teste',
    ativo: Situation.ativo,
    codigoBarras: '123',
    situacao: ExpeditionCartSituation.emSeparacao,
  );
}
