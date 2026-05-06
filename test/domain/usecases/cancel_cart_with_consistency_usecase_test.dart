import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_cancellation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_with_consistency_usecase.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_usecase.dart';

import '../../support/fake_user_session_service.dart';

void main() {
  group('CancelCartWithConsistencyUseCase', () {
    test('deve reverter itens quando cancelamento do carrinho falha', () async {
      final separateItemRepository = _InMemorySeparateItemRepository(
        items: [_buildSeparateItem(quantidadeSeparacao: 5)],
      );
      final separationItemRepository = _InMemorySeparationItemRepository(
        items: [_buildSeparationItem(situacao: ExpeditionItemSituation.separado, quantidade: 2)],
      );
      final cancellationRepository = _InMemoryCancellationRepository();
      final cartRouteRepository = _InMemoryCartRouteRepository(item: _buildCartRoute(), failOnUpdate: true);
      final cartRepository = _InMemoryCartRepository(item: _buildCart());
      final userSessionService = FakeUserSessionService();

      final cancelItemsUseCase = CancelCardItemSeparationUseCase(
        separateItemRepository: separateItemRepository,
        separationItemRepository: separationItemRepository,
        userSessionService: userSessionService,
      );
      final cancelCartUseCase = CancelCartUseCase(
        cartRepository: cartRepository,
        cancellationRepository: cancellationRepository,
        cartInternshipRouteRepository: cartRouteRepository,
        userSessionService: userSessionService,
      );
      final orchestrator = CancelCartWithConsistencyUseCase(
        cancelCartUseCase: cancelCartUseCase,
        cancelCardItemSeparationUseCase: cancelItemsUseCase,
      );

      final result = await orchestrator.call(
        cancelCartParams: const CancelCartParams(codEmpresa: 1, codCarrinhoPercurso: 200, item: '0001'),
        cancelItemParams: const CancelCardItemSeparationParams(
          codEmpresa: 1,
          codSepararEstoque: 100,
          codCarrinhoPercurso: 200,
          itemCarrinhoPercurso: '0001',
        ),
      );

      expect(result.isError(), isTrue);
      expect(separateItemRepository.items.first.quantidadeSeparacao, equals(5));
      expect(separationItemRepository.items.first.situacao, equals(ExpeditionItemSituation.separado));
    });
  });
}

class _InMemorySeparateItemRepository implements BasicRepository<SeparateItemModel> {
  _InMemorySeparateItemRepository({required this.items});

  final List<SeparateItemModel> items;

  @override
  Future<List<SeparateItemModel>> delete(SeparateItemModel entity) async {
    items.removeWhere((e) => e.codProduto == entity.codProduto);
    return [entity];
  }

  @override
  Future<List<SeparateItemModel>> insert(SeparateItemModel entity) async {
    items.add(entity);
    return [entity];
  }

  @override
  Future<List<SeparateItemModel>> select(QueryBuilder queryBuilder) async {
    return List<SeparateItemModel>.from(items);
  }

  @override
  Future<List<SeparateItemModel>> update(SeparateItemModel entity) async {
    final index = items.indexWhere(
      (e) =>
          e.codEmpresa == entity.codEmpresa &&
          e.codSepararEstoque == entity.codSepararEstoque &&
          e.item == entity.item &&
          e.codProduto == entity.codProduto,
    );
    if (index == -1) return [];
    items[index] = entity;
    return [entity];
  }
}

class _InMemorySeparationItemRepository implements BasicRepository<SeparationItemModel> {
  _InMemorySeparationItemRepository({required this.items});

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

class _InMemoryCartRouteRepository implements BasicRepository<ExpeditionCartRouteInternshipModel> {
  _InMemoryCartRouteRepository({required this.item, this.failOnUpdate = false});

  ExpeditionCartRouteInternshipModel item;
  final bool failOnUpdate;

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> delete(ExpeditionCartRouteInternshipModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> insert(ExpeditionCartRouteInternshipModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> select(QueryBuilder queryBuilder) async => [item];

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> update(ExpeditionCartRouteInternshipModel entity) async {
    if (failOnUpdate) {
      throw Exception('Falha simulada na atualização do percurso');
    }
    item = entity;
    return [entity];
  }
}

class _InMemoryCartRepository implements BasicRepository<ExpeditionCartModel> {
  _InMemoryCartRepository({required this.item});

  ExpeditionCartModel item;

  @override
  Future<List<ExpeditionCartModel>> delete(ExpeditionCartModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartModel>> insert(ExpeditionCartModel entity) async => [entity];

  @override
  Future<List<ExpeditionCartModel>> select(QueryBuilder queryBuilder) async => [item];

  @override
  Future<List<ExpeditionCartModel>> update(ExpeditionCartModel entity) async {
    item = entity;
    return [entity];
  }
}

class _InMemoryCancellationRepository implements BasicRepository<ExpeditionCancellationModel> {
  final List<ExpeditionCancellationModel> _items = [];

  @override
  Future<List<ExpeditionCancellationModel>> delete(ExpeditionCancellationModel entity) async => [entity];

  @override
  Future<List<ExpeditionCancellationModel>> insert(ExpeditionCancellationModel entity) async {
    _items.add(entity.copyWith(codCancelamento: _items.length + 1));
    return [_items.last];
  }

  @override
  Future<List<ExpeditionCancellationModel>> select(QueryBuilder queryBuilder) async {
    return List<ExpeditionCancellationModel>.from(_items);
  }

  @override
  Future<List<ExpeditionCancellationModel>> update(ExpeditionCancellationModel entity) async => [entity];
}

SeparateItemModel _buildSeparateItem({required double quantidadeSeparacao}) {
  return SeparateItemModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: '1',
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codLocalArmazenagem: 1,
    codProduto: 10,
    codUnidadeMedida: 'UN',
    quantidade: 10,
    quantidadeInterna: 10,
    quantidadeExterna: 0,
    quantidadeSeparacao: quantidadeSeparacao,
  );
}

SeparationItemModel _buildSeparationItem({required ExpeditionItemSituation situacao, required double quantidade}) {
  return SeparationItemModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: 'SI1',
    sessionId: 'S1',
    situacao: situacao,
    codCarrinhoPercurso: 200,
    itemCarrinhoPercurso: '0001',
    codSeparador: 1,
    nomeSeparador: 'User',
    dataSeparacao: DateTime(2026, 1, 1),
    horaSeparacao: '10:00:00',
    codProduto: 10,
    codUnidadeMedida: 'UN',
    quantidade: quantidade,
  );
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
