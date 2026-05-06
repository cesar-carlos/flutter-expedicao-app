import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/pagination/query_param.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_failure.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_usecase.dart';

import '../../../mocks/user_system_model_mock.dart';

void main() {
  group('StartSeparationUseCase', () {
    late _SessionFake session;
    late _MemorySeparateRepository separateRepo;
    late _MemoryStartCartRouteRepository cartRouteRepo;
    late StartSeparationUseCase useCase;

    AppUser loggedIn() {
      final u = createDefaultTestUserSystem();
      return AppUser(
        codLoginApp: 1,
        ativo: Situation.ativo,
        nome: u.nomeUsuario,
        codUsuario: u.codUsuario,
        userSystemModel: u,
      );
    }

    SeparateModel baseSeparation({ExpeditionSituation situacao = ExpeditionSituation.aguardando}) {
      return SeparateModel(
        codEmpresa: 1,
        codSepararEstoque: 100,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        codTipoOperacaoExpedicao: 1,
        tipoEntidade: EntityType.cliente,
        codEntidade: 1,
        nomeEntidade: 'Cliente',
        situacao: situacao,
        data: DateTime(2026, 1, 1),
        hora: '08:00:00',
        codPrioridade: 1,
      );
    }

    void configure({
      List<SeparateModel>? separations,
      List<ExpeditionCartRouteModel>? routes,
    }) {
      session = _SessionFake(loggedIn());
      separateRepo = _MemorySeparateRepository(separations ?? [baseSeparation()]);
      cartRouteRepo = _MemoryStartCartRouteRepository(routes ?? []);
      useCase = StartSeparationUseCase(
        separateRepository: separateRepo,
        cartRouteRepository: cartRouteRepo,
        userSessionService: session,
      );
    }

    test('retorna invalidParams quando codigo invalido', () async {
      configure();
      const params = StartSeparationParams(
        codEmpresa: 0,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
      );

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      final f = result.exceptionOrNull() as StartSeparationFailure;
      expect(f.type, StartSeparationFailureType.invalidParams);
    });

    test('retorna separationNotFound quando lista vazia', () async {
      configure(separations: []);

      final result = await useCase.call(
        const StartSeparationParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
        ),
      );

      expect(result.isError(), isTrue);
      final f = result.exceptionOrNull() as StartSeparationFailure;
      expect(f.type, StartSeparationFailureType.separationNotFound);
    });

    test('retorna separationNotInAwaitingStatus quando nao aguardando', () async {
      configure(separations: [baseSeparation(situacao: ExpeditionSituation.separando)]);

      final result = await useCase.call(
        const StartSeparationParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
        ),
      );

      expect(result.isError(), isTrue);
      final f = result.exceptionOrNull() as StartSeparationFailure;
      expect(f.type, StartSeparationFailureType.separationNotInAwaitingStatus);
    });

    test('retorna separationAlreadyStarted quando ja existe percurso ativo', () async {
      final existing = ExpeditionCartRouteModel(
        codEmpresa: 1,
        codCarrinhoPercurso: 55,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        situacao: ExpeditionCartSituation.emSeparacao,
        dataInicio: DateTime(2026, 1, 1),
        horaInicio: '08:00:00',
      );
      configure(routes: [existing]);

      final result = await useCase.call(
        const StartSeparationParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
        ),
      );

      expect(result.isError(), isTrue);
      final f = result.exceptionOrNull() as StartSeparationFailure;
      expect(f.type, StartSeparationFailureType.separationAlreadyStarted);
      expect(f.details, contains('55'));
    });

    test('sucesso cria rota e atualiza separacao para separando', () async {
      configure();

      final result = await useCase.call(
        const StartSeparationParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
        ),
      );

      expect(result.isSuccess(), isTrue);
      expect(cartRouteRepo.items.length, equals(1));
      expect(separateRepo.items.first.situacao, equals(ExpeditionSituation.separando));
    });

    test('retorna networkError quando lanca DataError na busca de separacao', () async {
      configure();
      separateRepo.throwOnSelect = true;

      final result = await useCase.call(
        const StartSeparationParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
        ),
      );

      expect(result.isError(), isTrue);
      final f = result.exceptionOrNull() as StartSeparationFailure;
      expect(f.isNetworkError, isTrue);
    });

    test('falha de sessao vira unknown com Exception', () async {
      configure();
      session.user = null;

      final result = await useCase.call(
        const StartSeparationParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
        ),
      );

      expect(result.isError(), isTrue);
      final f = result.exceptionOrNull() as StartSeparationFailure;
      expect(f.type, StartSeparationFailureType.unknownError);
    });
  });
}

class _SessionFake implements IUserSessionService {
  _SessionFake(this.user);

  AppUser? user;

  @override
  Future<void> clearUserSession() async {}

  @override
  Future<bool> hasActiveSession() async => user != null;

  @override
  Future<bool> isUserLoggedIn() async => user != null;

  @override
  Future<AppUser?> loadUserSession() async => user;

  @override
  Future<void> saveUserSession(AppUser appUser) async {
    user = appUser;
  }

  @override
  Future<void> updateUserSession(AppUser appUser) async {
    user = appUser;
  }
}

class _MemorySeparateRepository implements BasicRepository<SeparateModel> {
  _MemorySeparateRepository(List<SeparateModel> initial) : items = List<SeparateModel>.from(initial);

  final List<SeparateModel> items;
  bool throwOnSelect = false;

  @override
  Future<List<SeparateModel>> delete(SeparateModel entity) async => [entity];

  @override
  Future<List<SeparateModel>> insert(SeparateModel entity) async {
    items.add(entity);
    return [entity];
  }

  @override
  Future<List<SeparateModel>> select(QueryBuilder queryBuilder) async {
    if (throwOnSelect) {
      throw DataError(message: 'falha rede');
    }
    return items.where((m) => _matchesSeparateQuery(m, queryBuilder)).toList();
  }

  @override
  Future<List<SeparateModel>> update(SeparateModel entity) async {
    final i = items.indexWhere(
      (e) => e.codEmpresa == entity.codEmpresa && e.codSepararEstoque == entity.codSepararEstoque,
    );
    if (i < 0) {
      return [];
    }
    items[i] = entity;
    return [entity];
  }
}

bool _matchesSeparateQuery(SeparateModel m, QueryBuilder qb) {
  var ok = true;
  for (final QueryParam<dynamic> p in qb.params) {
    if (p.key == 'CodEmpresa' && p.operator == '=') {
      ok = ok && m.codEmpresa == p.value;
    } else if (p.key == 'CodSepararEstoque' && p.operator == '=') {
      ok = ok && m.codSepararEstoque == p.value;
    }
  }
  return ok;
}

class _MemoryStartCartRouteRepository implements BasicRepository<ExpeditionCartRouteModel> {
  _MemoryStartCartRouteRepository(List<ExpeditionCartRouteModel> initial)
    : items = List<ExpeditionCartRouteModel>.from(initial);

  final List<ExpeditionCartRouteModel> items;

  @override
  Future<List<ExpeditionCartRouteModel>> delete(ExpeditionCartRouteModel entity) async {
    items.removeWhere((e) => e.codCarrinhoPercurso == entity.codCarrinhoPercurso && e.codEmpresa == entity.codEmpresa);
    return [entity];
  }

  @override
  Future<List<ExpeditionCartRouteModel>> insert(ExpeditionCartRouteModel entity) async {
    final withId = entity.codCarrinhoPercurso == 0
        ? entity.copyWith(codCarrinhoPercurso: items.length + 100)
        : entity;
    items.add(withId);
    return [withId];
  }

  @override
  Future<List<ExpeditionCartRouteModel>> select(QueryBuilder queryBuilder) async {
    return items.where((r) => _matchesStartRoute(r, queryBuilder)).toList();
  }

  @override
  Future<List<ExpeditionCartRouteModel>> update(ExpeditionCartRouteModel entity) async {
    final i = items.indexWhere((e) => e.codCarrinhoPercurso == entity.codCarrinhoPercurso);
    if (i < 0) {
      return [];
    }
    items[i] = entity;
    return [entity];
  }
}

bool _matchesStartRoute(ExpeditionCartRouteModel r, QueryBuilder qb) {
  var include = true;
  for (final QueryParam<dynamic> p in qb.params) {
    if (p.key == 'CodEmpresa' && p.operator == '=') {
      include = include && r.codEmpresa == p.value;
    } else if (p.key == 'CodOrigem' && p.operator == '=') {
      include = include && r.codOrigem == p.value;
    } else if (p.key == 'Origem' && p.operator == '=') {
      include = include && r.origem.code == p.value;
    } else if (p.key == 'Situacao' && p.operator == '!=') {
      include = include && r.situacao.code != p.value;
    }
  }
  return include;
}
