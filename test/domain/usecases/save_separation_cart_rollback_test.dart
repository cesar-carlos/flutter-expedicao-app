import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_progress_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/tipo_fator_conversao_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_failure.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';

import '../../support/fake_user_session_service.dart';

void main() {
  group('SaveSeparationCartUseCase rollback', () {
    test('deve restaurar itens e percurso quando update do carrinho falha', () async {
      final cartRouteRepository = _InMemoryCartRouteRepository(item: _buildCartRoute());
      final separationItemConsultationRepository = _FakeSeparationItemConsultationRepository(
        items: [_buildSeparationItemConsultation()],
      );
      final separateItemConsultationRepository = _FakeSeparateItemConsultationRepository(items: [_buildSeparateItem()]);
      final progressRepository = _FakeProgressRepository(
        item: const SeparateProgressConsultationModel(
          codEmpresa: 1,
          codSepararEstoque: 100,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: 100,
          situacao: ExpeditionSituation.separando,
          processoSeparacao: ExpeditionSituation.separando,
        ),
      );
      final separationItemModelRepository = _InMemorySeparationItemModelRepository(
        items: [_buildSeparationItemModel()],
      );
      final cartRepository = _InMemoryCartRepository(item: _buildCart(), failOnFirstUpdate: true);
      final userSessionService = FakeUserSessionService();

      final useCase = SaveSeparationCartUseCase(
        cartRouteInternshipRepository: cartRouteRepository,
        separationItemConsultationRepository: separationItemConsultationRepository,
        separateItemRepository: separateItemConsultationRepository,
        separateProgressRepository: progressRepository,
        separationItemModelRepository: separationItemModelRepository,
        cartRepository: cartRepository,
        userSessionService: userSessionService,
      );

      final result = await useCase.call(
        const SaveSeparationCartParams(
          codEmpresa: 1,
          codCarrinhoPercurso: 200,
          itemCarrinhoPercurso: '0001',
          codSepararEstoque: 100,
        ),
      );

      expect(result.isError(), isTrue);
      expect(cartRouteRepository.item.situacao, equals(ExpeditionSituation.separando));
      expect(separationItemModelRepository.items.first.situacao, equals(ExpeditionItemSituation.separado));
    });
  });

  group('SaveSeparationCartUseCase timeouts (relógio fake)', () {
    test('falha quando atualizacao em lote de itens estoura timeout de 10s', () {
      FakeAsync().run((async) {
        final cartRouteRepository = _InMemoryCartRouteRepository(item: _buildCartRoute());
        final separationItemConsultationRepository = _FakeSeparationItemConsultationRepository(
          items: [_buildSeparationItemConsultation()],
        );
        final separateItemConsultationRepository = _FakeSeparateItemConsultationRepository(
          items: [_buildSeparateItem()],
        );
        final progressRepository = _FakeProgressRepository(
          item: const SeparateProgressConsultationModel(
            codEmpresa: 1,
            codSepararEstoque: 100,
            origem: ExpeditionOrigem.separacaoEstoque,
            codOrigem: 100,
            situacao: ExpeditionSituation.separando,
            processoSeparacao: ExpeditionSituation.separando,
          ),
        );
        final separationItemModelRepository = _SlowSeparationItemModelRepository(items: [_buildSeparationItemModel()]);
        final cartRepository = _InMemoryCartRepository(item: _buildCart());
        final userSessionService = FakeUserSessionService();

        final useCase = SaveSeparationCartUseCase(
          cartRouteInternshipRepository: cartRouteRepository,
          separationItemConsultationRepository: separationItemConsultationRepository,
          separateItemRepository: separateItemConsultationRepository,
          separateProgressRepository: progressRepository,
          separationItemModelRepository: separationItemModelRepository,
          cartRepository: cartRepository,
          userSessionService: userSessionService,
        );

        SaveSeparationCartFailure? failure;

        useCase
            .call(
              const SaveSeparationCartParams(
                codEmpresa: 1,
                codCarrinhoPercurso: 200,
                itemCarrinhoPercurso: '0001',
                codSepararEstoque: 100,
              ),
            )
            .then((r) {
              failure = r.exceptionOrNull() as SaveSeparationCartFailure?;
            });

        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 11));
        async.flushMicrotasks();

        expect(failure, isNotNull);
        expect(failure!.message, contains('TimeoutException'));
      });
    });

    test('falha quando consulta de itens separados na validacao estoura timeout de 10s', () {
      FakeAsync().run((async) {
        final cartRouteRepository = _InMemoryCartRouteRepository(item: _buildCartRoute());
        final separationItemConsultationRepository = _FakeSeparationItemConsultationRepository(
          items: [_buildSeparationItemConsultation()],
        );
        final separateItemConsultationRepository = _HangingSeparateItemConsultationRepository(
          items: [_buildSeparateItem()],
        );
        final progressRepository = _FakeProgressRepository(
          item: const SeparateProgressConsultationModel(
            codEmpresa: 1,
            codSepararEstoque: 100,
            origem: ExpeditionOrigem.separacaoEstoque,
            codOrigem: 100,
            situacao: ExpeditionSituation.separando,
            processoSeparacao: ExpeditionSituation.separando,
          ),
        );
        final separationItemModelRepository = _InMemorySeparationItemModelRepository(
          items: [_buildSeparationItemModel()],
        );
        final cartRepository = _InMemoryCartRepository(item: _buildCart());
        final userSessionService = FakeUserSessionService();

        final useCase = SaveSeparationCartUseCase(
          cartRouteInternshipRepository: cartRouteRepository,
          separationItemConsultationRepository: separationItemConsultationRepository,
          separateItemRepository: separateItemConsultationRepository,
          separateProgressRepository: progressRepository,
          separationItemModelRepository: separationItemModelRepository,
          cartRepository: cartRepository,
          userSessionService: userSessionService,
        );

        SaveSeparationCartFailure? failure;

        useCase
            .call(
              const SaveSeparationCartParams(
                codEmpresa: 1,
                codCarrinhoPercurso: 200,
                itemCarrinhoPercurso: '0001',
                codSepararEstoque: 100,
              ),
            )
            .then((r) {
              failure = r.exceptionOrNull() as SaveSeparationCartFailure?;
            });

        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 11));
        async.flushMicrotasks();

        expect(failure, isNotNull);
        expect(failure!.message, contains('TimeoutException'));
      });
    });
  });
}

class _InMemoryCartRouteRepository implements BasicRepository<ExpeditionCartRouteInternshipModel> {
  _InMemoryCartRouteRepository({required this.item});

  ExpeditionCartRouteInternshipModel item;

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> delete(ExpeditionCartRouteInternshipModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> insert(ExpeditionCartRouteInternshipModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> select(QueryBuilder queryBuilder) async => [item];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> update(ExpeditionCartRouteInternshipModel entity) async {
    item = entity;
    return [entity];
  }
}

class _InMemoryCartRepository implements BasicRepository<ExpeditionCartModel> {
  _InMemoryCartRepository({required this.item, this.failOnFirstUpdate = false});

  ExpeditionCartModel item;
  bool failOnFirstUpdate;
  int updateCount = 0;

  @override
  Future<List<ExpeditionCartModel>> delete(ExpeditionCartModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartModel>> insert(ExpeditionCartModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartModel>> select(QueryBuilder queryBuilder) async => [item];

  @override
  Future<List<ExpeditionCartModel>> update(ExpeditionCartModel entity) async {
    updateCount++;
    if (failOnFirstUpdate && updateCount == 1) {
      throw Exception('Falha simulada ao atualizar carrinho');
    }
    item = entity;
    return [entity];
  }
}

class _SlowSeparationItemModelRepository implements BasicRepository<SeparationItemModel> {
  _SlowSeparationItemModelRepository({required this.items});

  final List<SeparationItemModel> items;

  @override
  Future<List<SeparationItemModel>> delete(SeparationItemModel entity) async {
    items.removeWhere((e) => e.item == entity.item);
    return [entity];
  }

  @override
  Future<List<SeparationItemModel>> insert(SeparationItemModel entity) async {
    items.add(entity);
    return [entity];
  }

  @override
  Future<List<SeparationItemModel>> select(QueryBuilder queryBuilder) async {
    return List<SeparationItemModel>.from(items);
  }

  @override
  Future<List<SeparationItemModel>> update(SeparationItemModel entity) async {
    await Future<void>.delayed(const Duration(seconds: 11));
    final index = items.indexWhere((e) => e.item == entity.item);
    if (index == -1) return [];
    items[index] = entity;
    return [entity];
  }
}

class _HangingSeparateItemConsultationRepository implements BasicConsultationRepository<SeparateItemConsultationModel> {
  _HangingSeparateItemConsultationRepository({required this.items});

  final List<SeparateItemConsultationModel> items;

  @override
  Future<List<SeparateItemConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    await Future<void>.delayed(const Duration(days: 1));
    return List<SeparateItemConsultationModel>.from(items);
  }
}

class _InMemorySeparationItemModelRepository implements BasicRepository<SeparationItemModel> {
  _InMemorySeparationItemModelRepository({required this.items});

  final List<SeparationItemModel> items;

  @override
  Future<List<SeparationItemModel>> delete(SeparationItemModel entity) async {
    items.removeWhere((e) => e.item == entity.item);
    return [entity];
  }

  @override
  Future<List<SeparationItemModel>> insert(SeparationItemModel entity) async {
    items.add(entity);
    return [entity];
  }

  @override
  Future<List<SeparationItemModel>> select(QueryBuilder queryBuilder) async {
    return List<SeparationItemModel>.from(items);
  }

  @override
  Future<List<SeparationItemModel>> update(SeparationItemModel entity) async {
    final index = items.indexWhere((e) => e.item == entity.item);
    if (index == -1) return [];
    items[index] = entity;
    return [entity];
  }
}

class _FakeSeparationItemConsultationRepository
    implements BasicConsultationRepository<SeparationItemConsultationModel> {
  _FakeSeparationItemConsultationRepository({required this.items});

  final List<SeparationItemConsultationModel> items;

  @override
  Future<List<SeparationItemConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async => items;
}

class _FakeSeparateItemConsultationRepository implements BasicConsultationRepository<SeparateItemConsultationModel> {
  _FakeSeparateItemConsultationRepository({required this.items});

  final List<SeparateItemConsultationModel> items;

  @override
  Future<List<SeparateItemConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async => items;
}

class _FakeProgressRepository implements BasicConsultationRepository<SeparateProgressConsultationModel> {
  _FakeProgressRepository({required this.item});

  final SeparateProgressConsultationModel item;

  @override
  Future<List<SeparateProgressConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async => [item];
}

ExpeditionCartRouteInternshipModel _buildCartRoute() {
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

ExpeditionCartModel _buildCart() {
  return ExpeditionCartModel(
    codEmpresa: 1,
    codCarrinho: 300,
    descricao: 'Carrinho Teste',
    ativo: Situation.ativo,
    codigoBarras: '123',
    situacao: ExpeditionCartSituation.emSeparacao,
  );
}

SeparationItemConsultationModel _buildSeparationItemConsultation() {
  return SeparationItemConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: 'SIC1',
    sessionId: 'session',
    situacao: ExpeditionItemSituation.separado,
    codCarrinho: 300,
    nomeCarrinho: 'Carrinho',
    codigoBarrasCarrinho: '123',
    codCarrinhoPercurso: 200,
    itemCarrinhoPercurso: '0001',
    codProduto: 10,
    nomeProduto: 'Produto',
    codUnidadeMedida: 'UN',
    nomeUnidadeMedida: 'Unidade',
    codGrupoProduto: 1,
    nomeGrupoProduto: 'Grupo',
    codSeparador: 1,
    nomeSeparador: 'User',
    dataSeparacao: DateTime(2026, 1, 1),
    horaSeparacao: '10:00:00',
    quantidade: 2,
  );
}

SeparateItemConsultationModel _buildSeparateItem() {
  return SeparateItemConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: '1',
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codProduto: 10,
    nomeProduto: 'Produto',
    ativo: Situation.ativo,
    codTipoProduto: '1',
    codUnidadeMedida: 'UN',
    nomeUnidadeMedida: 'Unidade',
    codGrupoProduto: 1,
    nomeGrupoProduto: 'Grupo',
    codLocalArmazenagem: 1,
    nomeLocaArmazenagem: 'Local',
    quantidade: 10,
    quantidadeInterna: 10,
    quantidadeExterna: 0,
    quantidadeSeparacao: 2,
    unidadeMedidas: [
      SeparateItemUnidadeMedidaConsultationModel(
        codEmpresa: 1,
        codSepararEstoque: 100,
        item: '1',
        codProduto: 10,
        itemUnidadeMedida: '1',
        codUnidadeMedida: 'UN',
        unidadeMedidaDescricao: 'Unidade',
        unidadeMedidaPadrao: Situation.ativo,
        tipoFatorConversao: TipoFatorConversao.multiplicacao,
        fatorConversao: 1,
      ),
    ],
  );
}

SeparationItemModel _buildSeparationItemModel() {
  return SeparationItemModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: 'SIM1',
    sessionId: 'session',
    situacao: ExpeditionItemSituation.separado,
    codCarrinhoPercurso: 200,
    itemCarrinhoPercurso: '0001',
    codSeparador: 1,
    nomeSeparador: 'User',
    dataSeparacao: DateTime(2026, 1, 1),
    horaSeparacao: '10:00:00',
    codProduto: 10,
    codUnidadeMedida: 'UN',
    quantidade: 2,
  );
}
