import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/pagination/query_param.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

bool matchesSeparateModelQuery(SeparateModel m, QueryBuilder qb) {
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

class InMemorySeparateModelRepository implements BasicRepository<SeparateModel> {
  InMemorySeparateModelRepository(
    List<SeparateModel> rows, {
    this.filterSelectByQuery = true,
    this.throwOnSelect = false,
  }) : _rows = List<SeparateModel>.from(rows);

  final List<SeparateModel> _rows;

  bool filterSelectByQuery;
  bool throwOnSelect;

  List<SeparateModel> get rows => List<SeparateModel>.unmodifiable(_rows);

  @override
  Future<List<SeparateModel>> delete(SeparateModel entity) async => <SeparateModel>[];

  @override
  Future<List<SeparateModel>> insert(SeparateModel entity) async => <SeparateModel>[];

  @override
  Future<List<SeparateModel>> select(QueryBuilder queryBuilder) async {
    if (throwOnSelect) {
      throw DataError(message: 'falha rede');
    }
    if (filterSelectByQuery) {
      return _rows.where((m) => matchesSeparateModelQuery(m, queryBuilder)).toList();
    }
    return List<SeparateModel>.from(_rows);
  }

  @override
  Future<List<SeparateModel>> update(SeparateModel entity) async {
    final i = _rows.indexWhere(
      (r) => r.codEmpresa == entity.codEmpresa && r.codSepararEstoque == entity.codSepararEstoque,
    );
    if (i < 0) {
      return <SeparateModel>[];
    }
    _rows[i] = entity;
    return <SeparateModel>[entity];
  }
}
