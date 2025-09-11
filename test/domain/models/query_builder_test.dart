import 'package:flutter_test/flutter_test.dart';
import 'package:exp/domain/models/query_builder.dart';

void main() {
  group('QueryBuilder Tests', () {
    late QueryBuilder queryBuilder;

    setUp(() {
      queryBuilder = QueryBuilder();
    });

    test('should start with empty parameters', () {
      expect(queryBuilder.params, isEmpty);
      expect(queryBuilder.pagination, isNull);
    });

    test('should add parameter with addParam', () {
      queryBuilder.addParam('name', 'John');

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.key, 'name');
      expect(queryBuilder.params.first.value, 'John');
      expect(queryBuilder.params.first.operator, '=');
    });

    test('should add parameter with custom operator', () {
      queryBuilder.addParam('age', 25, operator: '>');

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.operator, '>');
    });

    test('should add equals parameter', () {
      queryBuilder.equals('status', 'active');

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.operator, '=');
    });

    test('should add not equals parameter', () {
      queryBuilder.notEquals('status', 'inactive');

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.operator, '!=');
    });

    test('should add like parameter', () {
      queryBuilder.like('name', 'John');

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.operator, 'LIKE');
    });

    test('should add greater than parameter', () {
      queryBuilder.greaterThan('age', 18);

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.operator, '>');
    });

    test('should add less than parameter', () {
      queryBuilder.lessThan('age', 65);

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.operator, '<');
    });

    test('should add in list parameter', () {
      queryBuilder.inList('status', ['active', 'pending']);

      expect(queryBuilder.params.length, 1);
      expect(queryBuilder.params.first.operator, 'IN');
      expect(queryBuilder.params.first.value, "'active','pending'");
    });

    test('should add pagination', () {
      queryBuilder.paginate(limit: 20, offset: 10);

      expect(queryBuilder.pagination, isNotNull);
      expect(queryBuilder.pagination!.limit, 20);
      expect(queryBuilder.pagination!.offset, 10);
    });

    test('should add pagination with default values', () {
      queryBuilder.paginate();

      expect(queryBuilder.pagination, isNotNull);
      expect(queryBuilder.pagination!.limit, 10);
      expect(queryBuilder.pagination!.offset, 0);
    });

    test('should build query string with single parameter', () {
      queryBuilder.equals('name', 'John');

      expect(queryBuilder.build(), "name='John'");
    });

    test('should build query string with multiple parameters', () {
      queryBuilder
          .equals('name', 'John')
          .equals('age', 25)
          .equals('status', 'active');

      expect(queryBuilder.build(), "name='John'&age=25&status='active'");
    });

    test('should build query string with pagination only', () {
      queryBuilder.paginate(limit: 20, offset: 10);

      expect(queryBuilder.build(), 'limit=20&offset=10');
    });

    test('should build query string with parameters and pagination', () {
      queryBuilder
          .equals('name', 'John')
          .equals('status', 'active')
          .paginate(limit: 20, offset: 10);

      expect(
        queryBuilder.build(),
        "name='John'&status='active'&limit=20&offset=10",
      );
    });

    test('should build empty query string when no parameters', () {
      expect(queryBuilder.build(), '');
    });

    test('should clear all parameters', () {
      queryBuilder
          .equals('name', 'John')
          .equals('age', 25)
          .paginate(limit: 10, offset: 0);

      expect(queryBuilder.params.length, 2);
      expect(queryBuilder.pagination, isNotNull);

      queryBuilder.clear();

      expect(queryBuilder.params, isEmpty);
      expect(queryBuilder.pagination, isNull);
    });

    test('should support method chaining', () {
      final result = queryBuilder
          .equals('name', 'John')
          .equals('age', 25)
          .like('email', 'john@example.com')
          .paginate(limit: 20, offset: 10);

      expect(result, same(queryBuilder));
      expect(queryBuilder.params.length, 3);
      expect(queryBuilder.pagination, isNotNull);
    });

    test('should handle different data types', () {
      final date = DateTime(2024, 1, 15);

      queryBuilder
          .equals('name', 'John')
          .equals('age', 25)
          .equals('price', 19.99)
          .equals('active', true)
          .equals('created_at', date);

      expect(
        queryBuilder.build(),
        "name='John'&age=25&price=19.99&active=true&created_at='2024-01-15T00:00:00.000'",
      );
    });

    test('should have correct string representation', () {
      queryBuilder
          .equals('name', 'John')
          .equals('age', 25)
          .paginate(limit: 10, offset: 0);

      expect(
        queryBuilder.toString(),
        'QueryBuilder(params: 2, pagination: Pagination(limit: 10, offset: 0))',
      );
    });
  });
}
