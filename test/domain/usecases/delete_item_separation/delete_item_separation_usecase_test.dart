import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/delete_item_separation/delete_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/delete_item_separation/delete_item_separation_usecase.dart';

import '../../../support/fake_user_session_service.dart';

void main() {
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
  });
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
