import 'query_param.dart';
import 'pagination.dart';

/// Query builder for constructing complex queries
class QueryBuilder {
  final List<QueryParam> _params = [];
  Pagination? _pagination;

  /// Adds a parameter to the query
  QueryBuilder addParam<P>(String key, P value, {String operator = '='}) {
    _params.add(QueryParam.createWithOperator(key, value, operator));
    return this;
  }

  /// Adds a parameter with equals operator
  QueryBuilder equals<P>(String key, P value) {
    return addParam(key, value, operator: '=');
  }

  /// Adds a parameter with not equals operator
  QueryBuilder notEquals<P>(String key, P value) {
    return addParam(key, value, operator: '!=');
  }

  /// Adds a parameter with like operator
  QueryBuilder like(String key, String value) {
    return addParam(key, value, operator: 'LIKE');
  }

  /// Adds a parameter with greater than operator
  QueryBuilder greaterThan<P>(String key, P value) {
    return addParam(key, value, operator: '>');
  }

  /// Adds a parameter with less than operator
  QueryBuilder lessThan<P>(String key, P value) {
    return addParam(key, value, operator: '<');
  }

  /// Adds a parameter with in operator
  QueryBuilder inList<P>(String key, List<P> values) {
    final valueString = values.map((v) => _formatValue(v)).join(',');
    return addParam(key, valueString, operator: 'IN');
  }

  /// Adds pagination to the query
  QueryBuilder paginate({int limit = 10, int offset = 0, int page = 1}) {
    _pagination = Pagination(limit: limit, offset: offset, page: page);
    return this;
  }

  /// Builds only the query parameters string (without pagination)
  String buildQuery() {
    return _params.map((param) => param.toQueryString()).join('&');
  }

  /// Builds only the pagination string
  String buildPagination() {
    if (_pagination == null) {
      return '';
    }
    return _pagination!.toQueryString();
  }

  /// Gets all parameters as a list
  List<QueryParam> get params => List.unmodifiable(_params);

  /// Gets pagination if set
  Pagination? get pagination => _pagination;

  /// Clears all parameters
  void clear() {
    _params.clear();
    _pagination = null;
  }

  /// Formats a value for query string
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
    return 'QueryBuilder(params: ${_params.length}, pagination: $_pagination)';
  }
}
