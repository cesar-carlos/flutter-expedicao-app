import 'package:flutter_test/flutter_test.dart';
import 'package:exp/domain/models/query_builder.dart';
import 'package:exp/domain/models/query_builder_extension.dart';

void main() {
  group('QueryBuilderExtension Tests', () {
    late QueryBuilder queryBuilder;

    setUp(() {
      queryBuilder = QueryBuilder();
    });

    test('should add date range filter', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);

      queryBuilder.dateRange('created_at', startDate, endDate);

      expect(queryBuilder.params.length, 2);
      expect(queryBuilder.params.first.operator, '>');
      expect(queryBuilder.params.last.operator, '<');
    });

    test('should add text search filter', () {
      queryBuilder.search('name', 'John');

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.operator, 'LIKE');
      expect(queryBuilder.params.first.value, '%John%');
    });

    test('should add status filter', () {
      queryBuilder.status('active');

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.key, 'situacao');
      expect(queryBuilder.params.first.value, 'active');
      expect(queryBuilder.params.first.operator, '=');
    });

    test('should add code filter', () {
      queryBuilder.code('ABC123');

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.key, 'codigo');
      expect(queryBuilder.params.first.value, 'ABC123');
      expect(queryBuilder.params.first.operator, '=');
    });

    test('should support chaining with extensions', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);

      queryBuilder
          .status('active')
          .code('ABC123')
          .search('name', 'John')
          .dateRange('created_at', startDate, endDate)
          .paginate(limit: 20, offset: 10);

      expect(queryBuilder.params.length, 5);
      expect(queryBuilder.pagination, isNotNull);
    });
  });
}
