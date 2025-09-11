import 'query_builder.dart';

/// Extension for easy query building
extension QueryBuilderExtension on QueryBuilder {
  /// Creates a new QueryBuilder with default pagination
  static QueryBuilder withDefaultPagination({int limit = 20, int offset = 0}) {
    return QueryBuilder().paginate(limit: limit, offset: offset);
  }

  /// Adds a date range filter
  QueryBuilder dateRange(String key, DateTime start, DateTime end) {
    return greaterThan(key, start).lessThan(key, end);
  }

  /// Adds a text search filter
  QueryBuilder search(String key, String searchTerm) {
    return like(key, '%$searchTerm%');
  }

  /// Adds a status filter
  QueryBuilder status(String status) {
    return equals('situacao', status);
  }

  /// Adds a code filter
  QueryBuilder code(String code) {
    return equals('codigo', code);
  }
}
