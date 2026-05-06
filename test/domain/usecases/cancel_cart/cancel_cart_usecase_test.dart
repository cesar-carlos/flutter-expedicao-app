import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/expedition_cancellation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_failure.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_usecase.dart';

import '../../../support/fake_user_session_service.dart';

void main() {
  group('CancelCartUseCase', () {
    test('DataError no insert de cancelamento vira CancelCartFailure.networkError', () async {
      final cartRouteRepository = _MemoryCartRouteRepository(_cartRoute());
      final cancellationRepository = _ThrowingCancellationRepository();
      final cartRepository = _EmptyCartRepository();
      final userSessionService = FakeUserSessionService();

      final useCase = CancelCartUseCase(
        cartRepository: cartRepository,
        cancellationRepository: cancellationRepository,
        cartInternshipRouteRepository: cartRouteRepository,
        userSessionService: userSessionService,
      );

      final result = await useCase.call(const CancelCartParams(codEmpresa: 1, codCarrinhoPercurso: 200, item: '0001'));

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull();
      expect(failure, isA<CancelCartFailure>());
      expect((failure as CancelCartFailure).isNetworkError, isTrue);
    });
  });
}

class _MemoryCartRouteRepository implements BasicRepository<ExpeditionCartRouteInternshipModel> {
  _MemoryCartRouteRepository(this._route);

  ExpeditionCartRouteInternshipModel _route;

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> delete(ExpeditionCartRouteInternshipModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> insert(ExpeditionCartRouteInternshipModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> select(QueryBuilder queryBuilder) async => [_route];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> update(ExpeditionCartRouteInternshipModel entity) async {
    _route = entity;
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

class _EmptyCartRepository implements BasicRepository<ExpeditionCartModel> {
  @override
  Future<List<ExpeditionCartModel>> delete(ExpeditionCartModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartModel>> insert(ExpeditionCartModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartModel>> select(QueryBuilder queryBuilder) async => [];

  @override
  Future<List<ExpeditionCartModel>> update(ExpeditionCartModel entity) async => [entity];
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
