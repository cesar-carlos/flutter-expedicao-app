import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/delete_item_separation/delete_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/delete_item_separation/delete_item_separation_usecase.dart';

import '../../../support/fake_user_session_service.dart';
import '../../../support/in_memory_separate_model_repository.dart';
import '../../../support/in_memory_separation_item_repositories.dart';

void main() {
  const validParams = DeleteItemSeparationParams(codEmpresa: 1, codSepararEstoque: 100, item: '00001');

  group('DeleteItemSeparationUseCase', () {
    test('DataError na busca do item vira NetworkFailure', () async {
      final useCase = DeleteItemSeparationUseCase(
        separateItemRepository: _EmptySeparateItemRepository(),
        separationItemRepository: _ThrowingSeparationItemRepository(),
        separateRepository: _EmptySeparateRepository(),
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(
        const DeleteItemSeparationParams(codEmpresa: 1, codSepararEstoque: 100, item: 'X1'),
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<NetworkFailure>());
    });

    test('retorna ValidationFailure quando parametros invalidos', () async {
      final useCase = DeleteItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([]),
        separateRepository: InMemorySeparateModelRepository([]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(
        const DeleteItemSeparationParams(codEmpresa: 0, codSepararEstoque: 100, item: '1'),
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<ValidationFailure>());
    });

    test('retorna AuthFailure quando sessao sem usuario', () async {
      final useCase = DeleteItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([]),
        separateRepository: InMemorySeparateModelRepository([]),
        userSessionService: FakeUserSessionService(loggedOut: true),
      );

      final result = await useCase.call(validParams);

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<AuthFailure>());
    });

    test('retorna DataFailure quando separation_item nao existe', () async {
      final useCase = DeleteItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([]),
        separateRepository: InMemorySeparateModelRepository([_headerSeparando()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(validParams);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as DataFailure;
      expect(failure.code, 'NOT_FOUND');
    });

    test('retorna DataFailure quando separate_item nao existe', () async {
      final useCase = DeleteItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([_separationRow()]),
        separateRepository: InMemorySeparateModelRepository([_headerSeparando()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(validParams);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as DataFailure;
      expect(failure.code, 'NOT_FOUND');
    });

    test('retorna DataFailure quando cabecalho separate nao existe', () async {
      final useCase = DeleteItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateItemRow()]),
        separationItemRepository: InMemorySeparationItemRepository([_separationRow()]),
        separateRepository: InMemorySeparateModelRepository([]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(validParams);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as DataFailure;
      expect(failure.code, 'NOT_FOUND');
    });

    test('retorna BusinessFailure quando separacao nao esta SEPARANDO', () async {
      final useCase = DeleteItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateItemRow()]),
        separationItemRepository: InMemorySeparationItemRepository([_separationRow()]),
        separateRepository: InMemorySeparateModelRepository([
          _headerSeparando().copyWith(situacao: ExpeditionSituation.separado),
        ]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(validParams);

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<BusinessFailure>());
    });

    test('exclui separation_item e reduz quantidadeSeparacao no separate_item', () async {
      final separationRepo = InMemorySeparationItemRepository([_separationRow()]);
      final separateItemRepo = InMemorySeparateItemRepository([_separateItemRow()]);
      final useCase = DeleteItemSeparationUseCase(
        separateItemRepository: separateItemRepo,
        separationItemRepository: separationRepo,
        separateRepository: InMemorySeparateModelRepository([_headerSeparando()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(validParams);

      expect(result.isSuccess(), isTrue);
      expect(separationRepo.rows, isEmpty);
      expect(separateItemRepo.rows.single.quantidadeSeparacao, 4.0);
      result.fold((success) {
        expect(success.deletedQuantity, 2.0);
        expect(success.hasUpdatedSeparateItem, isTrue);
      }, (_) => fail('expected success'));
    });

    test('retorna DataFailure com DELETE_FAILED quando delete nao remove na API', () async {
      final useCase = DeleteItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateItemRow()]),
        separationItemRepository: _SeparationDeleteReturnsEmpty([_separationRow()]),
        separateRepository: InMemorySeparateModelRepository([_headerSeparando()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(validParams);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as DataFailure;
      expect(failure.code, 'DELETE_FAILED');
    });

    test('rollback re-insere separation_item quando update do separate_item falha', () async {
      final original = _separationRow();
      final separationRepo = InMemorySeparationItemRepository([original]);
      final separateItemRepo = FailingSeparateItemUpdateRepository([_separateItemRow()]);
      final useCase = DeleteItemSeparationUseCase(
        separateItemRepository: separateItemRepo,
        separationItemRepository: separationRepo,
        separateRepository: InMemorySeparateModelRepository([_headerSeparando()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await useCase.call(validParams);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as DataFailure;
      expect(failure.code, 'UPDATE_FAILED');
      expect(separationRepo.rows.length, 1);
      expect(separationRepo.rows.single.item, original.item);
      expect(separateItemRepo.rows.single.quantidadeSeparacao, 6.0);
    });
  });
}

SeparationItemModel _separationRow() {
  return SeparationItemModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: '00001',
    sessionId: 'abcd12345678',
    situacao: ExpeditionItemSituation.separado,
    codCarrinhoPercurso: 200,
    itemCarrinhoPercurso: '0001',
    codSeparador: 1,
    nomeSeparador: 'Op',
    dataSeparacao: DateTime(2026, 1, 1),
    horaSeparacao: '10:00:00',
    codProduto: 42,
    codUnidadeMedida: 'UN',
    quantidade: 2.0,
  );
}

SeparateItemModel _separateItemRow() {
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
    quantidadeSeparacao: 6,
  );
}

SeparateModel _headerSeparando() {
  return SeparateModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codTipoOperacaoExpedicao: 1,
    tipoEntidade: EntityType.cliente,
    codEntidade: 1,
    nomeEntidade: 'Cliente',
    situacao: ExpeditionSituation.separando,
    data: DateTime(2026, 1, 1),
    hora: '08:00:00',
    codPrioridade: 1,
  );
}

class _SeparationDeleteReturnsEmpty implements BasicRepository<SeparationItemModel> {
  _SeparationDeleteReturnsEmpty(this._rows);

  final List<SeparationItemModel> _rows;

  @override
  Future<List<SeparationItemModel>> delete(SeparationItemModel entity) async => <SeparationItemModel>[];

  @override
  Future<List<SeparationItemModel>> insert(SeparationItemModel entity) async => <SeparationItemModel>[];

  @override
  Future<List<SeparationItemModel>> select(QueryBuilder queryBuilder) async => List<SeparationItemModel>.from(_rows);

  @override
  Future<List<SeparationItemModel>> update(SeparationItemModel entity) async => <SeparationItemModel>[];
}

class _ThrowingSeparationItemRepository implements BasicRepository<SeparationItemModel> {
  @override
  Future<List<SeparationItemModel>> delete(SeparationItemModel entity) async => [entity];

  @override
  Future<List<SeparationItemModel>> insert(SeparationItemModel entity) async => [entity];

  @override
  Future<List<SeparationItemModel>> select(QueryBuilder queryBuilder) async {
    throw DataError(message: 'erro api');
  }

  @override
  Future<List<SeparationItemModel>> update(SeparationItemModel entity) async => [entity];
}

class _EmptySeparateItemRepository implements BasicRepository<SeparateItemModel> {
  @override
  Future<List<SeparateItemModel>> delete(SeparateItemModel entity) async => [entity];

  @override
  Future<List<SeparateItemModel>> insert(SeparateItemModel entity) async => [entity];

  @override
  Future<List<SeparateItemModel>> select(QueryBuilder queryBuilder) async => [];

  @override
  Future<List<SeparateItemModel>> update(SeparateItemModel entity) async => [entity];
}

class _EmptySeparateRepository implements BasicRepository<SeparateModel> {
  @override
  Future<List<SeparateModel>> delete(SeparateModel entity) async => [entity];

  @override
  Future<List<SeparateModel>> insert(SeparateModel entity) async => [entity];

  @override
  Future<List<SeparateModel>> select(QueryBuilder queryBuilder) async => [];

  @override
  Future<List<SeparateModel>> update(SeparateModel entity) async => [entity];
}
