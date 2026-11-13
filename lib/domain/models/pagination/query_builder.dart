import 'package:data7_expedicao/domain/models/pagination/query_param.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/domain/models/pagination/query_order_by.dart';

class QueryBuilder {
  Pagination? _pagination;
  bool _fetchAllPages = false;
  int _fetchPageSize = Pagination.fetchPageSize;
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

  QueryBuilder greaterThanOrEqual<P>(String key, P value) {
    return addParam(key, value, operator: '>=');
  }

  QueryBuilder lessThan<P>(String key, P value) {
    return addParam(key, value, operator: '<');
  }

  QueryBuilder inList<P>(String key, List<P> values) {
    _params.add(QueryParam.createWithOperator(key, List<P>.from(values), 'IN'));
    return this;
  }

  QueryBuilder isNull(String key) {
    _params.add(QueryParam<String?>(key: key, value: null, operator: 'IS NULL'));
    return this;
  }

  QueryBuilder isNotNull(String key) {
    _params.add(QueryParam<String?>(key: key, value: null, operator: 'IS NOT NULL'));
    return this;
  }

  QueryBuilder rawWhere(String sql) {
    _params.add(QueryParam.createWithOperator('where', sql, 'RAW'));
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

  /// Pede a lista inteira em páginas. Sem isto o servidor corta em 1500,
  /// ou, na unidade de medida, devolve tudo num único payload.
  ///
  /// [thenBy] entra depois de [orderField] para o OFFSET não pular linha
  /// quando o primeiro campo se repete.
  QueryBuilder allRows({
    String orderField = 'Item',
    List<String> thenBy = const [],
    int pageSize = Pagination.fetchPageSize,
  }) {
    _fetchAllPages = true;
    _fetchPageSize = pageSize < 1 ? 1 : pageSize;
    if (_orderBy.isEmpty) {
      orderByAsc(orderField);
    }
    for (final field in thenBy) {
      if (field.isNotEmpty && !_hasOrderField(field)) {
        orderByAsc(field);
      }
    }
    return this;
  }

  QueryBuilder copy() {
    final clone = QueryBuilder();
    clone._params.addAll(_params);
    clone._orderBy.addAll(_orderBy);
    clone._pagination = _pagination;
    clone._fetchAllPages = _fetchAllPages;
    clone._fetchPageSize = _fetchPageSize;
    return clone;
  }

  /// Clona e aplica [allRows] se ainda não houver página.
  QueryBuilder withAllRows({
    String orderField = 'Item',
    List<String> thenBy = const [],
    int pageSize = Pagination.fetchPageSize,
  }) {
    final query = copy();
    if (query._fetchAllPages || query._pagination != null) {
      return query;
    }
    return query.allRows(orderField: orderField, thenBy: thenBy, pageSize: pageSize);
  }

  bool _hasOrderField(String field) {
    return _orderBy.any((order) => order.field == field);
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

  /// Where no contrato Socket.IO: lista `{ key, operator?, value? }`.
  List<Map<String, dynamic>>? buildWhereParams() {
    if (_params.isEmpty) {
      return null;
    }
    return _params.map((param) => param.toSocketWhere()).toList(growable: false);
  }

  String buildPagination() {
    if (_pagination == null) {
      return '';
    }
    return _pagination!.toQueryString();
  }

  /// Só pagina em loop quando o chamador pediu `allRows()`. Lookup sem
  /// `paginate` vai numa ida só — o servidor aplica o teto padrão.
  bool get shouldFetchAllPages => _fetchAllPages;

  /// Gera cláusula SQL ORDER BY no formato `ORDER BY field1 ASC, field2 DESC`.
  /// Diferente de [buildOrderByQuery] (que produz query string para REST/URL).
  String buildOrderBySql() {
    if (_orderBy.isEmpty) return '';
    return 'ORDER BY ${_orderBy.map((o) => '${o.field} ${o.direction.value}').join(', ')}';
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

  bool get fetchAllPages => _fetchAllPages;

  int get fetchPageSize => _fetchPageSize;

  List<OrderBy> get orderByClauses => List.unmodifiable(_orderBy);

  void clear() {
    _params.clear();
    _pagination = null;
    _fetchAllPages = false;
    _fetchPageSize = Pagination.fetchPageSize;
    _orderBy.clear();
  }

  @override
  String toString() {
    return 'QueryBuilder(params: ${_params.length}, pagination: $_pagination, orderBy: ${_orderBy.length})';
  }
}
