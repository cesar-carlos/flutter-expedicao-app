import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';

extension QueryBuilderExtension on QueryBuilder {
  static QueryBuilder withDefaultPagination({int limit = 20, int offset = 0, int page = 1}) {
    return QueryBuilder().paginate(limit: limit, offset: offset, page: page);
  }

  QueryBuilder dateRange(String key, DateTime start, DateTime end) {
    return greaterThan(key, start).lessThan(key, end);
  }

  QueryBuilder search(String key, String searchTerm) {
    return like(key, '%$searchTerm%');
  }

  QueryBuilder status(String status) {
    return equals('situacao', status);
  }

  QueryBuilder code(String code) {
    return equals('codigo', code);
  }

  QueryBuilder orderByNewest() {
    return orderByDesc('created_at');
  }

  QueryBuilder orderByOldest() {
    return orderByAsc('created_at');
  }

  QueryBuilder orderByName() {
    return orderByAsc('nome');
  }

  QueryBuilder orderByStatusAndDate() {
    return orderByAsc('situacao').orderByDesc('created_at');
  }

  QueryBuilder orderByPriority() {
    return orderByDesc('prioridade').orderByDesc('created_at');
  }
}
