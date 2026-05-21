import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_failure.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_usecase.dart';

import '../../mocks/user_system_model_mock.dart';
import '../../support/fake_user_session_service.dart';
import '../../support/in_memory_separation_item_repositories.dart';

void main() {
  AddItemSeparationParams baseParams({double quantidade = 2.0}) {
    return AddItemSeparationParams(
      codEmpresa: 1,
      codSepararEstoque: 100,
      sessionId: 'abcd12345678',
      codCarrinhoPercurso: 200,
      itemCarrinhoPercurso: '00001',
      itemSepararEstoque: '00001',
      codSeparador: 1,
      nomeSeparador: 'Operador',
      codProduto: 42,
      codUnidadeMedida: 'UN',
      quantidade: quantidade,
    );
  }

  UserSystemModel user() => createDefaultTestUserSystem();

  SeparateItemModel separateAvailable({double qSep = 5.0}) {
    return SeparateItemModel(
      codEmpresa: 1,
      codSepararEstoque: 100,
      item: '00001',
      codSetorEstoque: 1,
      origem: ExpeditionOrigem.separacaoEstoque,
      codOrigem: 100,
      codLocalArmazenagem: 1,
      codProduto: 42,
      codUnidadeMedida: 'UN',
      quantidade: 10,
      quantidadeInterna: 10,
      quantidadeExterna: 0,
      quantidadeSeparacao: qSep,
    );
  }

  group('AddItemSeparationUseCase', () {
    test('retorna invalidParams quando parametros invalidos', () async {
      final uc = AddItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: _TrackingSeparationRepo(),
        userSessionService: FakeUserSessionService(),
      );

      final bad = AddItemSeparationParams(
        codEmpresa: 0,
        codSepararEstoque: 100,
        sessionId: 'abcd12345678',
        codCarrinhoPercurso: 200,
        itemCarrinhoPercurso: '00001',
        itemSepararEstoque: '00001',
        codSeparador: 1,
        nomeSeparador: 'Op',
        codProduto: 42,
        codUnidadeMedida: 'UN',
        quantidade: 1,
      );

      final result = await uc.call(bad, userSystem: user());

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as AddItemSeparationFailure?;
      expect(failure?.type, AddItemSeparationFailureType.invalidParams);
    });

    test('retorna separateItemNotFound quando produto nao existe', () async {
      final uc = AddItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: _TrackingSeparationRepo(),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(baseParams(), userSystem: user());

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as AddItemSeparationFailure?;
      expect(failure?.type, AddItemSeparationFailureType.separateItemNotFound);
    });

    test('retorna insufficientQuantity quando estoque disponivel menor que solicitado', () async {
      final uc = AddItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([separateAvailable(qSep: 9.0)]),
        separationItemRepository: _TrackingSeparationRepo(),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(baseParams(quantidade: 2.0), userSystem: user());

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as AddItemSeparationFailure?;
      expect(failure?.type, AddItemSeparationFailureType.insufficientQuantity);
    });

    test('retorna insertSeparationItemFailed quando insert nao persiste', () async {
      final uc = AddItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([separateAvailable()]),
        separationItemRepository: _InsertFailsSeparationRepo(),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(baseParams(), userSystem: user());

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as AddItemSeparationFailure?;
      expect(failure?.type, AddItemSeparationFailureType.insertSeparationItemFailed);
    });

    test('retorna updateSeparateItemFailed e tenta rollback delete quando update falha', () async {
      final separationRepo = _TrackingSeparationRepo();
      final uc = AddItemSeparationUseCase(
        separateItemRepository: FailingSeparateItemUpdateRepository([separateAvailable()]),
        separationItemRepository: separationRepo,
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(baseParams(), userSystem: user());

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as AddItemSeparationFailure?;
      expect(failure?.type, AddItemSeparationFailureType.updateSeparateItemFailed);
      expect(separationRepo.deleteCallCount, greaterThanOrEqualTo(1));
    });

    test('insere separation_item e atualiza quantidadeSeparacao', () async {
      final separationRepo = _TrackingSeparationRepo();
      final uc = AddItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([separateAvailable()]),
        separationItemRepository: separationRepo,
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(baseParams(), userSystem: user());

      expect(result.isSuccess(), isTrue);
      result.fold((success) {
        expect(success.createdSeparationItem.situacao, ExpeditionItemSituation.separado);
        expect(success.updatedSeparateItem.quantidadeSeparacao, 7.0);
        expect(success.addedQuantity, 2.0);
      }, (_) => fail('expected success'));
    });

    test('usa o itemSepararEstoque para atualizar a linha correta quando o produto se repete', () async {
      final separationRepo = _TrackingSeparationRepo();
      final separateItemRepository = InMemorySeparateItemRepository([
        separateAvailable(qSep: 1.0),
        separateAvailable(qSep: 4.0).copyWith(item: '00002'),
      ]);
      final uc = AddItemSeparationUseCase(
        separateItemRepository: separateItemRepository,
        separationItemRepository: separationRepo,
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(
        baseParams(quantidade: 2.0).copyWithForTest(itemSepararEstoque: '00002'),
        userSystem: user(),
      );

      expect(result.isSuccess(), isTrue);
      final success = result.getOrNull()!;
      expect(success.updatedSeparateItem.item, equals('00002'));
      expect(success.updatedSeparateItem.quantidadeSeparacao, equals(6.0));
      expect(separateItemRepository.rows.firstWhere((row) => row.item == '00001').quantidadeSeparacao, equals(1.0));
    });

    test('sem userSystem carrega sessao via IUserSessionService', () async {
      final separationRepo = _TrackingSeparationRepo();
      final uc = AddItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([separateAvailable()]),
        separationItemRepository: separationRepo,
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(baseParams());

      expect(result.isSuccess(), isTrue);
    });
  });
}

extension on AddItemSeparationParams {
  AddItemSeparationParams copyWithForTest({String? itemSepararEstoque}) {
    return AddItemSeparationParams(
      codEmpresa: codEmpresa,
      codSepararEstoque: codSepararEstoque,
      sessionId: sessionId,
      codCarrinhoPercurso: codCarrinhoPercurso,
      itemCarrinhoPercurso: itemCarrinhoPercurso,
      itemSepararEstoque: itemSepararEstoque ?? this.itemSepararEstoque,
      codSeparador: codSeparador,
      nomeSeparador: nomeSeparador,
      codProduto: codProduto,
      codUnidadeMedida: codUnidadeMedida,
      quantidade: quantidade,
    );
  }
}

class _TrackingSeparationRepo implements BasicRepository<SeparationItemModel> {
  final List<SeparationItemModel> _rows = [];
  int deleteCallCount = 0;

  @override
  Future<List<SeparationItemModel>> delete(SeparationItemModel entity) async {
    deleteCallCount++;
    _rows.removeWhere(
      (r) =>
          r.codEmpresa == entity.codEmpresa &&
          r.codSepararEstoque == entity.codSepararEstoque &&
          r.item == entity.item &&
          r.codProduto == entity.codProduto,
    );
    return <SeparationItemModel>[entity];
  }

  @override
  Future<List<SeparationItemModel>> insert(SeparationItemModel entity) async {
    _rows.add(entity);
    return <SeparationItemModel>[entity];
  }

  @override
  Future<List<SeparationItemModel>> select(QueryBuilder queryBuilder) async => List<SeparationItemModel>.from(_rows);

  @override
  Future<List<SeparationItemModel>> update(SeparationItemModel entity) async {
    final i = _rows.indexWhere(
      (r) =>
          r.codEmpresa == entity.codEmpresa && r.codSepararEstoque == entity.codSepararEstoque && r.item == entity.item,
    );
    if (i < 0) {
      return <SeparationItemModel>[];
    }
    _rows[i] = entity;
    return <SeparationItemModel>[entity];
  }
}

class _InsertFailsSeparationRepo implements BasicRepository<SeparationItemModel> {
  @override
  Future<List<SeparationItemModel>> delete(SeparationItemModel entity) async => <SeparationItemModel>[];

  @override
  Future<List<SeparationItemModel>> insert(SeparationItemModel entity) async => <SeparationItemModel>[];

  @override
  Future<List<SeparationItemModel>> select(QueryBuilder queryBuilder) async => <SeparationItemModel>[];

  @override
  Future<List<SeparationItemModel>> update(SeparationItemModel entity) async => <SeparationItemModel>[];
}
