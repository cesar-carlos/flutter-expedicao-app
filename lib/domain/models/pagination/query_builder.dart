import 'package:data7_expedicao/domain/models/pagination/query_param.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/domain/models/pagination/query_order_by.dart';

class QueryBuilder {
  Pagination? _pagination;
  final List<QueryParam> _params = [];
  final List<OrderBy> _orderBy = [];

  QueryBuilder addParam<P>(String key, P value, {String operator = '='}) {
    _params.add(QueryParam.createWithOperator(key, value, operator));
    return this;
  }

  QueryBuilder equals<P>(String key, P value) {
    return addParam(key, value, operator: '=');
  }

  QueryBuilder notEquals<P>(String key, P value) {
    return addParam(key, value, operator: '!=');
  }

  QueryBuilder like(String key, String value) {
    return addParam(key, value, operator: 'LIKE');
  }

  QueryBuilder greaterThan<P>(String key, P value) {
    return addParam(key, value, operator: '>');
  }

  QueryBuilder lessThan<P>(String key, P value) {
    return addParam(key, value, operator: '<');
  }

  QueryBuilder inList<P>(String key, List<P> values) {
    if (values.isEmpty) return this;
    final valueString = '(${values.map((v) => _formatValue(v)).join(',')})';
    _params.add(QueryParam.createWithOperator(key, valueString, 'IN'));
    return this;
  }

  QueryBuilder fieldEquals(String key, String fieldName) {
    _params.add(QueryParam.createFieldComparison(key, fieldName, '='));
    return this;
  }

  QueryBuilder fieldGreaterThan(String key, String fieldName) {
    _params.add(QueryParam.createFieldComparison(key, fieldName, '>'));
    return this;
  }

  QueryBuilder fieldLessThan(String key, String fieldName) {
    _params.add(QueryParam.createFieldComparison(key, fieldName, '<'));
    return this;
  }

  QueryBuilder paginate({int limit = 10, int offset = 0, int page = 1}) {
    _pagination = Pagination(limit: limit, offset: offset, page: page);
    return this;
  }

  QueryBuilder orderBy(String field, {OrderDirection direction = OrderDirection.asc}) {
    _orderBy.add(OrderBy(field: field, direction: direction));
    return this;
  }

  QueryBuilder orderByAsc(String field) {
    _orderBy.add(OrderBy.asc(field));
    return this;
  }

  QueryBuilder orderByDesc(String field) {
    _orderBy.add(OrderBy.desc(field));
    return this;
  }

  QueryBuilder orderByMultiple(List<OrderBy> orders) {
    _orderBy.addAll(orders);
    return this;
  }

  String buildQuery() {
    return _params.map((param) => param.toQueryString()).join('&');
  }

  String buildSqlWhere() {
    if (_params.isEmpty) return '';
    return _params.map((param) => param.toSqlString()).join(' AND ');
  }

  String buildPagination() {
    if (_pagination == null) {
      return '';
    }
    return _pagination!.toQueryString();
  }

  String buildOrderBySql() {
    if (_orderBy.isEmpty) return '';
    return 'ORDER BY ${_orderBy.map((o) => o.toSqlString()).join(', ')}';
  }

  String buildOrderByQuery() {
    if (_orderBy.isEmpty) return '';

    final fields = _orderBy.map((o) => o.field).join(',');
    final directions = _orderBy.map((o) => o.direction.value).join(',');

    return 'order_by=$fields&order_direction=$directions';
  }

  String buildCompleteQuery() {
    final parts = <String>[];

    final queryParams = buildQuery();
    if (queryParams.isNotEmpty) {
      parts.add(queryParams);
    }

    final pagination = buildPagination();
    if (pagination.isNotEmpty) {
      parts.add(pagination);
    }

    final orderBy = buildOrderByQuery();
    if (orderBy.isNotEmpty) {
      parts.add(orderBy);
    }

    return parts.join('&');
  }

  List<QueryParam> get params => List.unmodifiable(_params);

  Pagination? get pagination => _pagination;

  List<OrderBy> get orderByClauses => List.unmodifiable(_orderBy);

  void clear() {
    _params.clear();
    _pagination = null;
    _orderBy.clear();
  }

  String _formatValue(dynamic value) {
    if (value is String) {
      return "'$value'";
    } else if (value is DateTime) {
      return "'${value.toIso8601String()}'";
    } else {
      return value.toString();
    }
  }

  @override
  String toString() {
    return 'QueryBuilder(params: ${_params.length}, pagination: $_pagination, orderBy: ${_orderBy.length})';
  }
}
