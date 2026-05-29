import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/expedition_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/user_system/user_system_list_page.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/pagination/query_param.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_failure.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_usecase.dart';

import '../../../mocks/user_system_model_mock.dart';

void main() {
  group('AddCartUseCase', () {
    late _FakeUserSessionService session;
    late _FakeUserSystemRepository userRepo;
    late _MemoryCartRepository cartRepo;
    late _MemoryCartRouteRepository cartRouteRepo;
    late _MemoryCartRouteInternshipRepository cartRouteInternshipRepo;
    late _MemoryCartConsultationRepository consultationRepo;
    late _MemoryInternshipRepository internshipRepo;
    late AddCartUseCase useCase;

    UserSystemModel userModel() => createDefaultTestUserSystem();

    AppUser appUserWith(UserSystemModel u) {
      return AppUser(
        codLoginApp: 1,
        ativo: Situation.ativo,
        nome: u.nomeUsuario,
        codUsuario: u.codUsuario,
        userSystemModel: u,
      );
    }

    ExpeditionCartConsultationModel liberadoCart({int codCarrinho = 10}) {
      return ExpeditionCartConsultationModel(
        codEmpresa: 1,
        codCarrinho: codCarrinho,
        descricaoCarrinho: 'Carrinho',
        ativo: Situation.ativo,
        situacao: ExpeditionCartSituation.liberado,
        codigoBarras: '1234567890123',
      );
    }

    ExpeditionCartRouteModel activeRoute({int codCarrinhoPercurso = 500}) {
      return ExpeditionCartRouteModel(
        codEmpresa: 1,
        codCarrinhoPercurso: codCarrinhoPercurso,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        situacao: ExpeditionCartSituation.emSeparacao,
        dataInicio: DateTime(2026, 1, 1),
        horaInicio: '08:00:00',
      );
    }

    ExpeditionInternshipModel internshipSeparacao() {
      return ExpeditionInternshipModel(
        codPercursoEstagio: 7,
        descricao: 'Estágio',
        ativo: Situation.ativo,
        origem: ExpeditionOrigem.separacaoEstoque,
        sequencia: 1,
      );
    }

    ExpeditionInternshipModel internshipCompra() {
      return ExpeditionInternshipModel(
        codPercursoEstagio: 8,
        descricao: 'Estágio CP',
        ativo: Situation.ativo,
        origem: ExpeditionOrigem.compraMercadoria,
        sequencia: 1,
      );
    }

    void resetDeps({
      ExpeditionCartConsultationModel? scanned,
      List<ExpeditionCartRouteModel>? routes,
      List<ExpeditionCartRouteInternshipModel>? internshipsRoute,
      List<ExpeditionInternshipModel>? internships,
      ExpeditionCartModel? cartState,
    }) {
      session = _FakeUserSessionService(appUserWith(userModel()));
      userRepo = _FakeUserSystemRepository();
      cartRepo = _MemoryCartRepository(
        cartState ??
            ExpeditionCartModel(
              codEmpresa: 1,
              codCarrinho: scanned?.codCarrinho ?? 10,
              descricao: scanned?.descricaoCarrinho ?? 'Carrinho',
              ativo: Situation.ativo,
              codigoBarras: scanned?.codigoBarras ?? '1234567890123',
              situacao: ExpeditionCartSituation.liberado,
            ),
      );
      cartRouteRepo = _MemoryCartRouteRepository(items: routes ?? [activeRoute()]);
      cartRouteInternshipRepo = _MemoryCartRouteInternshipRepository(items: internshipsRoute ?? []);
      consultationRepo = _MemoryCartConsultationRepository(carts: scanned != null ? [scanned] : []);
      internshipRepo = _MemoryInternshipRepository(items: internships ?? [internshipSeparacao()]);
      useCase = AddCartUseCase(
        cartRepository: cartRepo,
        cartRouteRepository: cartRouteRepo,
        cartRouteInternshipRepository: cartRouteInternshipRepo,
        cartConsultationRepository: consultationRepo,
        expeditionInternshipRepository: internshipRepo,
        userSystemRepository: userRepo,
        userSessionService: session,
      );
    }

    test('retorna invalidParameters quando params invalidos', () async {
      resetDeps(scanned: liberadoCart());
      const params = AddCartParams(
        codEmpresa: 0,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        codCarrinho: 10,
      );

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull();
      expect(failure, isA<AddCartFailure>());
      expect((failure as AddCartFailure).code, equals('INVALID_PARAMETERS'));
    });

    test('retorna userNotAuthenticated quando sessao sem userSystemModel', () async {
      session = _FakeUserSessionService(null);
      userRepo = _FakeUserSystemRepository();
      cartRepo = _MemoryCartRepository(
        ExpeditionCartModel(
          codEmpresa: 1,
          codCarrinho: 10,
          descricao: 'X',
          ativo: Situation.ativo,
          codigoBarras: '1',
          situacao: ExpeditionCartSituation.liberado,
        ),
      );
      cartRouteRepo = _MemoryCartRouteRepository(items: [activeRoute()]);
      cartRouteInternshipRepo = _MemoryCartRouteInternshipRepository(items: []);
      consultationRepo = _MemoryCartConsultationRepository(carts: []);
      internshipRepo = _MemoryInternshipRepository(items: [internshipSeparacao()]);
      useCase = AddCartUseCase(
        cartRepository: cartRepo,
        cartRouteRepository: cartRouteRepo,
        cartRouteInternshipRepository: cartRouteInternshipRepo,
        cartConsultationRepository: consultationRepo,
        expeditionInternshipRepository: internshipRepo,
        userSystemRepository: userRepo,
        userSessionService: session,
      );

      final result = await useCase.call(
        AddCartParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
          codCarrinho: 10,
          scannedCart: liberadoCart(),
        ),
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<AddCartFailure>());
      expect((result.exceptionOrNull() as AddCartFailure).code, equals('USER_NOT_AUTHENTICATED'));
    });

    test('retorna cartNotFound quando busca por codigo sem scannedCart', () async {
      resetDeps(scanned: null);
      consultationRepo.carts.clear();

      final result = await useCase.call(
        const AddCartParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
          codCarrinho: 99,
        ),
      );

      expect(result.isError(), isTrue);
      expect((result.exceptionOrNull() as AddCartFailure).code, equals('CART_NOT_FOUND'));
    });

    test('retorna repositoryError quando consulta de carrinho lanca', () async {
      resetDeps(scanned: null);
      consultationRepo.throwOnSelect = true;

      final result = await useCase.call(
        const AddCartParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
          codCarrinho: 10,
        ),
      );

      expect(result.isError(), isTrue);
      expect((result.exceptionOrNull() as AddCartFailure).code, equals('REPOSITORY_ERROR'));
    });

    test('retorna invalidSituation quando carrinho nao esta liberado', () async {
      final blocked = ExpeditionCartConsultationModel(
        codEmpresa: 1,
        codCarrinho: 10,
        descricaoCarrinho: 'Carrinho',
        ativo: Situation.ativo,
        situacao: ExpeditionCartSituation.emSeparacao,
        codigoBarras: '1234567890123',
      );
      resetDeps(scanned: blocked);

      final result = await useCase.call(
        AddCartParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
          codCarrinho: 10,
          scannedCart: blocked,
        ),
      );

      expect(result.isError(), isTrue);
      expect((result.exceptionOrNull() as AddCartFailure).code, equals('INVALID_CART_SITUATION'));
    });

    test('retorna routeNotFound quando nao ha percurso separacaoEstoque', () async {
      resetDeps(scanned: liberadoCart());
      cartRouteRepo.items.clear();

      final result = await useCase.call(
        AddCartParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
          codCarrinho: 10,
          scannedCart: liberadoCart(),
        ),
      );

      expect(result.isError(), isTrue);
      expect((result.exceptionOrNull() as AddCartFailure).code, equals('ROUTE_NOT_FOUND'));
    });

    test('usa codCarrinhoPercurso informado sem consultar rota separacaoEstoque', () async {
      resetDeps(scanned: liberadoCart());
      cartRouteRepo.items.clear();

      final result = await useCase.call(
        AddCartParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
          codCarrinho: 10,
          scannedCart: liberadoCart(),
          codCarrinhoPercurso: 777,
        ),
      );

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull()?.codCarrinhoPercurso, equals(777));
      expect(cartRepo.lastUpdated?.situacao, equals(ExpeditionCartSituation.emSeparacao));
    });

    test('fluxo compraMercadoria resolve rota por internship repository', () async {
      final cart = liberadoCart();
      final routeItem = ExpeditionCartRouteInternshipModel(
        codEmpresa: 1,
        codCarrinhoPercurso: 900,
        item: '00001',
        origem: ExpeditionOrigem.compraMercadoria,
        codOrigem: 200,
        codPercursoEstagio: 8,
        codCarrinho: cart.codCarrinho,
        situacao: ExpeditionSituation.separando,
        dataInicio: DateTime(2026, 1, 2),
        horaInicio: '09:00:00',
        codUsuarioInicio: 1,
        nomeUsuarioInicio: 'U',
      );
      resetDeps(
        scanned: cart,
        routes: [],
        internshipsRoute: [routeItem],
        internships: [internshipCompra()],
        cartState: ExpeditionCartModel(
          codEmpresa: 1,
          codCarrinho: 10,
          descricao: 'Carrinho',
          ativo: Situation.ativo,
          codigoBarras: '1234567890123',
          situacao: ExpeditionCartSituation.liberado,
        ),
      );

      final result = await useCase.call(
        const AddCartParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.compraMercadoria,
          codOrigem: 200,
          codCarrinho: 10,
        ),
      );

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull()?.codCarrinhoPercurso, equals(900));
    });

    test('retorna generic quando estagio nao existe para origem', () async {
      resetDeps(scanned: liberadoCart(), internships: []);

      final result = await useCase.call(
        AddCartParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
          codCarrinho: 10,
          scannedCart: liberadoCart(),
        ),
      );

      expect(result.isError(), isTrue);
      expect((result.exceptionOrNull() as AddCartFailure).code, equals('GENERIC_ERROR'));
    });

    test('sucesso completo com scannedCart insere internship e atualiza carrinho', () async {
      final cart = liberadoCart();
      resetDeps(scanned: cart);

      final result = await useCase.call(
        AddCartParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
          codCarrinho: 10,
          scannedCart: cart,
        ),
      );

      expect(result.isSuccess(), isTrue);
      expect(cartRouteInternshipRepo.inserted.length, equals(1));
      expect(cartRepo.lastUpdated?.situacao, equals(ExpeditionCartSituation.emSeparacao));
    });

    test('rollback para liberado quando insert do internship falha apos update', () async {
      final cart = liberadoCart();
      resetDeps(scanned: cart);
      cartRouteInternshipRepo.failInsert = true;

      final result = await useCase.call(
        AddCartParams(
          codEmpresa: 1,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
          codCarrinho: 10,
          scannedCart: cart,
        ),
      );

      expect(result.isError(), isTrue);
      expect((result.exceptionOrNull() as AddCartFailure).code, equals('REPOSITORY_ERROR'));
      expect(cartRepo.lastUpdated?.situacao, equals(ExpeditionCartSituation.liberado));
    });
  });
}

class _FakeUserSessionService implements IUserSessionService {
  _FakeUserSessionService(this._user);

  AppUser? _user;

  @override
  Future<void> clearUserSession() async {}

  @override
  Future<bool> hasActiveSession() async => _user != null;

  @override
  Future<bool> isUserLoggedIn() async => _user != null;

  @override
  Future<AppUser?> loadUserSession() async => _user;

  @override
  Future<void> saveUserSession(AppUser appUser) async {
    _user = appUser;
  }

  @override
  Future<void> updateUserSession(AppUser appUser) async {
    _user = appUser;
  }
}

class _FakeUserSystemRepository implements UserSystemRepository {
  @override
  Future<Map<String, dynamic>> getUserSystemInfo(int codUsuario) async => {};

  @override
  Future<UserSystemListPage> getUsers({
    int? codEmpresa,
    Situation? apenasAtivos,
    Pagination? pagination,
  }) async {
    return const UserSystemListPage(users: [], total: 0, success: true);
  }

  @override
  Future<UserSystemModel?> getUserById(int codUsuario) async => null;

  @override
  Future<UserSystemListPage> searchUsersByName(
    String nome, {
    int? codEmpresa,
    Situation apenasAtivos = Situation.ativo,
    Pagination? pagination,
  }) async {
    return const UserSystemListPage(users: [], total: 0, success: true);
  }
}

class _MemoryCartRepository implements BasicRepository<ExpeditionCartModel> {
  _MemoryCartRepository(this._state);

  ExpeditionCartModel _state;
  ExpeditionCartModel? lastUpdated;

  ExpeditionCartModel get state => _state;

  @override
  Future<List<ExpeditionCartModel>> delete(ExpeditionCartModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartModel>> insert(ExpeditionCartModel entity) async {
    _state = entity;
    return [entity];
  }

  @override
  Future<List<ExpeditionCartModel>> select(QueryBuilder queryBuilder) async => [_state];

  @override
  Future<List<ExpeditionCartModel>> update(ExpeditionCartModel entity) async {
    lastUpdated = entity;
    _state = entity;
    return [entity];
  }
}

class _MemoryCartRouteRepository implements BasicRepository<ExpeditionCartRouteModel> {
  _MemoryCartRouteRepository({required this.items});

  final List<ExpeditionCartRouteModel> items;

  @override
  Future<List<ExpeditionCartRouteModel>> delete(ExpeditionCartRouteModel entity) async {
    items.removeWhere(
      (e) =>
          e.codEmpresa == entity.codEmpresa &&
          e.codCarrinhoPercurso == entity.codCarrinhoPercurso &&
          e.origem == entity.origem,
    );
    return [entity];
  }

  @override
  Future<List<ExpeditionCartRouteModel>> insert(ExpeditionCartRouteModel entity) async {
    items.add(entity);
    return [entity];
  }

  @override
  Future<List<ExpeditionCartRouteModel>> select(QueryBuilder queryBuilder) async {
    return items.where((r) => _matchesCartRoute(r, queryBuilder)).toList();
  }

  @override
  Future<List<ExpeditionCartRouteModel>> update(ExpeditionCartRouteModel entity) async {
    final index = items.indexWhere(
      (e) => e.codEmpresa == entity.codEmpresa && e.codCarrinhoPercurso == entity.codCarrinhoPercurso,
    );
    if (index >= 0) {
      items[index] = entity;
    }
    return [entity];
  }
}

class _MemoryCartRouteInternshipRepository implements BasicRepository<ExpeditionCartRouteInternshipModel> {
  _MemoryCartRouteInternshipRepository({required this.items});

  final List<ExpeditionCartRouteInternshipModel> items;
  final List<ExpeditionCartRouteInternshipModel> inserted = [];
  bool failInsert = false;

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> delete(ExpeditionCartRouteInternshipModel entity) async => [
    entity,
  ];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> insert(ExpeditionCartRouteInternshipModel entity) async {
    if (failInsert) {
      throw Exception('insert falhou');
    }
    inserted.add(entity);
    items.add(entity);
    return [entity];
  }

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> select(QueryBuilder queryBuilder) async {
    return items.where((r) => _matchesCartRouteInternship(r, queryBuilder)).toList();
  }

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> update(ExpeditionCartRouteInternshipModel entity) async => [
    entity,
  ];
}

class _MemoryCartConsultationRepository implements BasicConsultationRepository<ExpeditionCartConsultationModel> {
  _MemoryCartConsultationRepository({required this.carts});

  final List<ExpeditionCartConsultationModel> carts;
  bool throwOnSelect = false;

  @override
  Future<List<ExpeditionCartConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    if (throwOnSelect) {
      throw Exception('erro rede');
    }
    return carts.where((c) => _matchesConsultationCart(c, queryBuilder)).toList();
  }
}

class _MemoryInternshipRepository implements BasicRepository<ExpeditionInternshipModel> {
  _MemoryInternshipRepository({required this.items});

  final List<ExpeditionInternshipModel> items;

  @override
  Future<List<ExpeditionInternshipModel>> delete(ExpeditionInternshipModel entity) async => [entity];

  @override
  Future<List<ExpeditionInternshipModel>> insert(ExpeditionInternshipModel entity) async {
    items.add(entity);
    return [entity];
  }

  @override
  Future<List<ExpeditionInternshipModel>> select(QueryBuilder queryBuilder) async {
    return items.where((m) => _matchesInternship(m, queryBuilder)).toList();
  }

  @override
  Future<List<ExpeditionInternshipModel>> update(ExpeditionInternshipModel entity) async => [entity];
}

bool _matchesConsultationCart(ExpeditionCartConsultationModel c, QueryBuilder qb) {
  for (final QueryParam<dynamic> p in qb.params) {
    if (p.operator != '=') continue;
    if (p.key == 'codCarrinho' && c.codCarrinho != p.value) {
      return false;
    }
  }
  return true;
}

bool _matchesCartRoute(ExpeditionCartRouteModel r, QueryBuilder qb) {
  var ok = true;
  for (final QueryParam<dynamic> p in qb.params) {
    if (p.key == 'CodEmpresa' && p.operator == '=') {
      ok = ok && r.codEmpresa == p.value;
    } else if (p.key == 'CodOrigem' && p.operator == '=') {
      ok = ok && r.codOrigem == p.value;
    } else if (p.key == 'Origem' && p.operator == '=') {
      ok = ok && r.origem.code == p.value;
    } else if (p.key == 'Situacao' && p.operator == '!=') {
      ok = ok && r.situacao.code != p.value;
    }
  }
  return ok;
}

bool _matchesCartRouteInternship(ExpeditionCartRouteInternshipModel r, QueryBuilder qb) {
  var ok = true;
  for (final QueryParam<dynamic> p in qb.params) {
    if (p.key == 'CodEmpresa' && p.operator == '=') {
      ok = ok && r.codEmpresa == p.value;
    } else if (p.key == 'CodOrigem' && p.operator == '=') {
      ok = ok && r.codOrigem == p.value;
    } else if (p.key == 'Origem' && p.operator == '=') {
      ok = ok && r.origem.code == p.value;
    }
  }
  return ok;
}

bool _matchesInternship(ExpeditionInternshipModel m, QueryBuilder qb) {
  for (final QueryParam<dynamic> p in qb.params) {
    if (p.key == 'Origem' && p.operator == '=') {
      return m.origem.code == p.value;
    }
  }
  return true;
}
