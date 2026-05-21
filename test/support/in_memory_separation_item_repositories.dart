import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

class InMemorySeparateItemRepository implements BasicRepository<SeparateItemModel> {
  InMemorySeparateItemRepository(List<SeparateItemModel> rows) : _rows = List<SeparateItemModel>.from(rows);

  final List<SeparateItemModel> _rows;

  List<SeparateItemModel> get rows => List<SeparateItemModel>.unmodifiable(_rows);

  @override
  Future<List<SeparateItemModel>> delete(SeparateItemModel entity) async => <SeparateItemModel>[];

  @override
  Future<List<SeparateItemModel>> insert(SeparateItemModel entity) async => <SeparateItemModel>[];

  @override
  Future<List<SeparateItemModel>> select(QueryBuilder queryBuilder) async => List<SeparateItemModel>.from(_rows);

  @override
  Future<List<SeparateItemModel>> update(SeparateItemModel entity) async {
    final i = _rows.indexWhere(
      (r) =>
          r.codEmpresa == entity.codEmpresa &&
          r.codSepararEstoque == entity.codSepararEstoque &&
          r.codProduto == entity.codProduto &&
          r.item == entity.item,
    );
    if (i < 0) {
      return <SeparateItemModel>[];
    }
    _rows[i] = entity;
    return <SeparateItemModel>[entity];
  }
}

class InMemorySeparationItemRepository implements BasicRepository<SeparationItemModel> {
  InMemorySeparationItemRepository(List<SeparationItemModel> rows) : _rows = List<SeparationItemModel>.from(rows);

  final List<SeparationItemModel> _rows;

  List<SeparationItemModel> get rows => List<SeparationItemModel>.unmodifiable(_rows);

  @override
  Future<List<SeparationItemModel>> delete(SeparationItemModel entity) async {
    final i = _rows.indexWhere(
      (r) =>
          r.codEmpresa == entity.codEmpresa && r.codSepararEstoque == entity.codSepararEstoque && r.item == entity.item,
    );
    if (i < 0) {
      return <SeparationItemModel>[];
    }
    final removed = _rows.removeAt(i);
    return <SeparationItemModel>[removed];
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

class FailingSeparateItemUpdateRepository extends InMemorySeparateItemRepository {
  FailingSeparateItemUpdateRepository(super.rows);

  @override
  Future<List<SeparateItemModel>> update(SeparateItemModel entity) async => <SeparateItemModel>[];
}

class EmptyUpdateSeparationItemRepository extends InMemorySeparationItemRepository {
  EmptyUpdateSeparationItemRepository(super.rows);

  @override
  Future<List<SeparationItemModel>> update(SeparationItemModel entity) async => <SeparationItemModel>[];
}
