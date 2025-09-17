import 'package:flutter_test/flutter_test.dart';
import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/models/pagination/query_param.dart';
import 'package:exp/domain/models/pagination/query_order_by.dart';
import 'package:exp/domain/models/pagination/query_builder_extension.dart';

void main() {
  group('QueryBuilder', () {
    late QueryBuilder queryBuilder;

    setUp(() {
      queryBuilder = QueryBuilder();
    });

    group('Basic Parameter Operations', () {
      test('should add parameter with default equals operator', () {
        queryBuilder.addParam('name', 'John');

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'name');
        expect(queryBuilder.params.first.value, 'John');
        expect(queryBuilder.params.first.operator, '=');
      });

      test('should add parameter with custom operator', () {
        queryBuilder.addParam('age', 25, operator: '>');

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'age');
        expect(queryBuilder.params.first.value, 25);
        expect(queryBuilder.params.first.operator, '>');
      });

      test('should chain multiple parameter additions', () {
        queryBuilder.addParam('name', 'John').addParam('age', 25).addParam('city', 'New York');

        expect(queryBuilder.params.length, 3);
        expect(queryBuilder.params[0].key, 'name');
        expect(queryBuilder.params[1].key, 'age');
        expect(queryBuilder.params[2].key, 'city');
      });

      test('should return QueryBuilder instance for method chaining', () {
        final result = queryBuilder.addParam('test', 'value');
        expect(result, isA<QueryBuilder>());
        expect(result, same(queryBuilder));
      });
    });

    group('Specific Operator Methods', () {
      test('should add equals parameter', () {
        queryBuilder.equals('status', 'active');

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'status');
        expect(queryBuilder.params.first.value, 'active');
        expect(queryBuilder.params.first.operator, '=');
      });

      test('should add not equals parameter', () {
        queryBuilder.notEquals('status', 'inactive');

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'status');
        expect(queryBuilder.params.first.value, 'inactive');
        expect(queryBuilder.params.first.operator, '!=');
      });

      test('should add like parameter', () {
        queryBuilder.like('name', 'John%');

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'name');
        expect(queryBuilder.params.first.value, 'John%');
        expect(queryBuilder.params.first.operator, 'LIKE');
      });

      test('should add greater than parameter', () {
        queryBuilder.greaterThan('age', 18);

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'age');
        expect(queryBuilder.params.first.value, 18);
        expect(queryBuilder.params.first.operator, '>');
      });

      test('should add less than parameter', () {
        queryBuilder.lessThan('age', 65);

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'age');
        expect(queryBuilder.params.first.value, 65);
        expect(queryBuilder.params.first.operator, '<');
      });

      test('should add in list parameter', () {
        queryBuilder.inList('status', ['active', 'pending', 'completed']);

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'status');
        expect(queryBuilder.params.first.value, "'active','pending','completed'");
        expect(queryBuilder.params.first.operator, 'IN');
      });

      test('should handle empty list in inList', () {
        queryBuilder.inList('status', <String>[]);

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'status');
        expect(queryBuilder.params.first.value, '');
        expect(queryBuilder.params.first.operator, 'IN');
      });
    });

    group('Pagination', () {
      test('should add pagination with default values', () {
        queryBuilder.paginate();

        expect(queryBuilder.pagination, isNotNull);
        expect(queryBuilder.pagination?.limit, 10);
        expect(queryBuilder.pagination?.offset, 0);
        expect(queryBuilder.pagination?.page, 1);
      });

      test('should add pagination with custom values', () {
        queryBuilder.paginate(limit: 20, offset: 40, page: 3);

        expect(queryBuilder.pagination, isNotNull);
        expect(queryBuilder.pagination?.limit, 20);
        expect(queryBuilder.pagination?.offset, 40);
        expect(queryBuilder.pagination?.page, 3);
      });

      test('should return QueryBuilder instance for pagination chaining', () {
        final result = queryBuilder.paginate();
        expect(result, isA<QueryBuilder>());
        expect(result, same(queryBuilder));
      });
    });

    group('Order By Operations', () {
      test('should add order by with default ascending direction', () {
        queryBuilder.orderBy('name');

        expect(queryBuilder.orderByClauses.length, 1);
        expect(queryBuilder.orderByClauses.first.field, 'name');
        expect(queryBuilder.orderByClauses.first.direction, OrderDirection.asc);
      });

      test('should add order by with descending direction', () {
        queryBuilder.orderBy('created_at', direction: OrderDirection.desc);

        expect(queryBuilder.orderByClauses.length, 1);
        expect(queryBuilder.orderByClauses.first.field, 'created_at');
        expect(queryBuilder.orderByClauses.first.direction, OrderDirection.desc);
      });

      test('should add ascending order by', () {
        queryBuilder.orderByAsc('name');

        expect(queryBuilder.orderByClauses.length, 1);
        expect(queryBuilder.orderByClauses.first.field, 'name');
        expect(queryBuilder.orderByClauses.first.direction, OrderDirection.asc);
      });

      test('should add descending order by', () {
        queryBuilder.orderByDesc('created_at');

        expect(queryBuilder.orderByClauses.length, 1);
        expect(queryBuilder.orderByClauses.first.field, 'created_at');
        expect(queryBuilder.orderByClauses.first.direction, OrderDirection.desc);
      });

      test('should add multiple order by clauses', () {
        final orders = [OrderBy.asc('name'), OrderBy.desc('created_at'), OrderBy.asc('id')];

        queryBuilder.orderByMultiple(orders);

        expect(queryBuilder.orderByClauses.length, 3);
        expect(queryBuilder.orderByClauses[0].field, 'name');
        expect(queryBuilder.orderByClauses[0].direction, OrderDirection.asc);
        expect(queryBuilder.orderByClauses[1].field, 'created_at');
        expect(queryBuilder.orderByClauses[1].direction, OrderDirection.desc);
        expect(queryBuilder.orderByClauses[2].field, 'id');
        expect(queryBuilder.orderByClauses[2].direction, OrderDirection.asc);
      });

      test('should chain multiple order by operations', () {
        queryBuilder.orderByAsc('name').orderByDesc('created_at').orderBy('status');

        expect(queryBuilder.orderByClauses.length, 3);
        expect(queryBuilder.orderByClauses[0].field, 'name');
        expect(queryBuilder.orderByClauses[1].field, 'created_at');
        expect(queryBuilder.orderByClauses[2].field, 'status');
      });

      test('should return QueryBuilder instance for order by chaining', () {
        final result = queryBuilder.orderBy('name');
        expect(result, isA<QueryBuilder>());
        expect(result, same(queryBuilder));
      });
    });

    group('Query Building', () {
      test('should build query parameters string', () {
        queryBuilder.equals('status', 'active').greaterThan('age', 18).like('name', 'John%');

        final queryString = queryBuilder.buildQuery();
        expect(queryString, contains("status='active'"));
        expect(queryString, contains('age>18'));
        expect(queryString, contains("nameLIKE'John%'"));
      });

      test('should build empty query string when no parameters', () {
        final queryString = queryBuilder.buildQuery();
        expect(queryString, isEmpty);
      });

      test('should build pagination string', () {
        queryBuilder.paginate(limit: 20, offset: 40, page: 3);

        final paginationString = queryBuilder.buildPagination();
        expect(paginationString, 'LIMIT=20&OFFSET=40&PAGE=3');
      });

      test('should build empty pagination string when no pagination', () {
        final paginationString = queryBuilder.buildPagination();
        expect(paginationString, isEmpty);
      });

      test('should build ORDER BY SQL string', () {
        queryBuilder.orderByAsc('name').orderByDesc('created_at');

        final orderBySql = queryBuilder.buildOrderBySql();
        expect(orderBySql, 'ORDER BY name ASC, created_at DESC');
      });

      test('should build empty ORDER BY SQL string when no order by', () {
        final orderBySql = queryBuilder.buildOrderBySql();
        expect(orderBySql, isEmpty);
      });

      test('should build ORDER BY query string', () {
        queryBuilder.orderByAsc('name').orderByDesc('created_at');

        final orderByQuery = queryBuilder.buildOrderByQuery();
        expect(orderByQuery, 'order_by=name,created_at&order_direction=ASC,DESC');
      });

      test('should build empty ORDER BY query string when no order by', () {
        final orderByQuery = queryBuilder.buildOrderByQuery();
        expect(orderByQuery, isEmpty);
      });

      test('should build complete query with all components', () {
        queryBuilder
            .equals('status', 'active')
            .greaterThan('age', 18)
            .paginate(limit: 10, offset: 0, page: 1)
            .orderByAsc('name');

        final completeQuery = queryBuilder.buildCompleteQuery();

        expect(completeQuery, contains("status='active'"));
        expect(completeQuery, contains('age>18'));
        expect(completeQuery, contains('LIMIT=10&OFFSET=0&PAGE=1'));
        expect(completeQuery, contains('order_by=name&order_direction=ASC'));
      });

      test('should build complete query with only parameters', () {
        queryBuilder.equals('status', 'active');

        final completeQuery = queryBuilder.buildCompleteQuery();
        expect(completeQuery, "status='active'");
      });

      test('should build complete query with only pagination', () {
        queryBuilder.paginate(limit: 20, offset: 40, page: 3);

        final completeQuery = queryBuilder.buildCompleteQuery();
        expect(completeQuery, 'LIMIT=20&OFFSET=40&PAGE=3');
      });

      test('should build complete query with only order by', () {
        queryBuilder.orderByDesc('created_at');

        final completeQuery = queryBuilder.buildCompleteQuery();
        expect(completeQuery, 'order_by=created_at&order_direction=DESC');
      });

      test('should build empty complete query when no components', () {
        final completeQuery = queryBuilder.buildCompleteQuery();
        expect(completeQuery, isEmpty);
      });
    });

    group('Getters and Properties', () {
      test('should return unmodifiable params list', () {
        queryBuilder.equals('test', 'value');

        final params = queryBuilder.params;
        expect(params, isA<List<QueryParam>>());
        expect(() => params.add(QueryParam.create('new', 'value')), throwsUnsupportedError);
      });

      test('should return pagination when set', () {
        queryBuilder.paginate(limit: 10, offset: 0, page: 1);

        final pagination = queryBuilder.pagination;
        expect(pagination, isNotNull);
        expect(pagination?.limit, 10);
        expect(pagination?.offset, 0);
        expect(pagination?.page, 1);
      });

      test('should return null pagination when not set', () {
        final pagination = queryBuilder.pagination;
        expect(pagination, isNull);
      });

      test('should return unmodifiable order by clauses list', () {
        queryBuilder.orderByAsc('name');

        final orderByClauses = queryBuilder.orderByClauses;
        expect(orderByClauses, isA<List<OrderBy>>());
        expect(() => orderByClauses.add(OrderBy.asc('new')), throwsUnsupportedError);
      });
    });

    group('Clear Operations', () {
      test('should clear all parameters', () {
        queryBuilder
            .equals('status', 'active')
            .greaterThan('age', 18)
            .paginate(limit: 10, offset: 0, page: 1)
            .orderByAsc('name');

        queryBuilder.clear();

        expect(queryBuilder.params, isEmpty);
        expect(queryBuilder.pagination, isNull);
        expect(queryBuilder.orderByClauses, isEmpty);
      });

      test('should allow adding parameters after clear', () {
        queryBuilder.equals('status', 'active');
        queryBuilder.clear();
        queryBuilder.equals('new_status', 'inactive');

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'new_status');
        expect(queryBuilder.params.first.value, 'inactive');
      });
    });

    group('Value Formatting', () {
      test('should format string values with quotes', () {
        queryBuilder.equals('name', 'John Doe');

        final queryString = queryBuilder.buildQuery();
        expect(queryString, "name='John Doe'");
      });

      test('should format DateTime values with ISO string', () {
        final dateTime = DateTime(2023, 12, 25, 10, 30, 0);
        queryBuilder.equals('created_at', dateTime);

        final queryString = queryBuilder.buildQuery();
        expect(queryString, contains("created_at='2023-12-25T10:30:00.000"));
      });

      test('should format numeric values without quotes', () {
        queryBuilder.equals('age', 25);
        queryBuilder.equals('price', 99.99);

        final queryString = queryBuilder.buildQuery();
        expect(queryString, contains('age=25'));
        expect(queryString, contains('price=99.99'));
      });

      test('should format boolean values without quotes', () {
        queryBuilder.equals('is_active', true);
        queryBuilder.equals('is_deleted', false);

        final queryString = queryBuilder.buildQuery();
        expect(queryString, contains('is_active=true'));
        expect(queryString, contains('is_deleted=false'));
      });
    });

    group('ToString', () {
      test('should return descriptive string representation', () {
        queryBuilder.equals('status', 'active').paginate(limit: 10, offset: 0, page: 1).orderByAsc('name');

        final stringRepresentation = queryBuilder.toString();

        expect(stringRepresentation, contains('QueryBuilder'));
        expect(stringRepresentation, contains('params: 1'));
        expect(stringRepresentation, contains('pagination:'));
        expect(stringRepresentation, contains('orderBy: 1'));
      });

      test('should return string representation with zero counts', () {
        final stringRepresentation = queryBuilder.toString();

        expect(stringRepresentation, contains('QueryBuilder'));
        expect(stringRepresentation, contains('params: 0'));
        expect(stringRepresentation, contains('pagination: null'));
        expect(stringRepresentation, contains('orderBy: 0'));
      });
    });

    group('Edge Cases and Validation', () {
      test('should handle null values in parameters', () {
        queryBuilder.addParam('nullable_field', null);

        expect(queryBuilder.params.length, 1);
        expect(queryBuilder.params.first.key, 'nullable_field');
        expect(queryBuilder.params.first.value, null);
      });

      test('should handle empty string values', () {
        queryBuilder.equals('empty_field', '');

        final queryString = queryBuilder.buildQuery();
        expect(queryString, "empty_field=''");
      });

      test('should handle special characters in string values', () {
        queryBuilder.equals('special_field', "test'with\"quotes&symbols");

        final queryString = queryBuilder.buildQuery();
        expect(queryString, contains("special_field='test'with\"quotes&symbols'"));
      });

      test('should handle very long string values', () {
        final longString = 'a' * 1000;
        queryBuilder.equals('long_field', longString);

        final queryString = queryBuilder.buildQuery();
        expect(queryString, contains("long_field='$longString'"));
      });

      test('should handle negative numbers', () {
        queryBuilder.equals('negative_number', -10);
        queryBuilder.greaterThan('negative_comparison', -5);

        final queryString = queryBuilder.buildQuery();
        expect(queryString, contains('negative_number=-10'));
        expect(queryString, contains('negative_comparison>-5'));
      });

      test('should handle zero values', () {
        queryBuilder.equals('zero_number', 0);
        queryBuilder.equals('zero_double', 0.0);

        final queryString = queryBuilder.buildQuery();
        expect(queryString, contains('zero_number=0'));
        expect(queryString, contains('zero_double=0.0'));
      });

      test('should handle large numbers', () {
        queryBuilder.equals('large_number', 999999999);
        queryBuilder.equals('large_double', 999999999.99);

        final queryString = queryBuilder.buildQuery();
        expect(queryString, contains('large_number=999999999'));
        expect(queryString, contains('large_double=999999999.99'));
      });
    });

    group('Complex Scenarios', () {
      test('should build complex query with all features', () {
        final complexQuery = QueryBuilder()
            .equals('status', 'active')
            .notEquals('deleted', true)
            .greaterThan('age', 18)
            .lessThan('age', 65)
            .like('name', 'John%')
            .inList('category', ['electronics', 'books', 'clothing'])
            .paginate(limit: 20, offset: 40, page: 3)
            .orderByAsc('name')
            .orderByDesc('created_at')
            .buildCompleteQuery();

        expect(complexQuery, contains("status='active'"));
        expect(complexQuery, contains('deleted!=true'));
        expect(complexQuery, contains('age>18'));
        expect(complexQuery, contains('age<65'));
        expect(complexQuery, contains("nameLIKE'John%'"));
        expect(complexQuery, contains("categoryIN''electronics','books','clothing''"));
        expect(complexQuery, contains('LIMIT=20&OFFSET=40&PAGE=3'));
        expect(complexQuery, contains('order_by=name,created_at&order_direction=ASC,DESC'));
      });

      test('should handle multiple parameters with same key', () {
        queryBuilder
            .equals('status', 'active')
            .equals('status', 'pending'); // This will add another parameter with same key

        expect(queryBuilder.params.length, 2);
        expect(queryBuilder.params[0].key, 'status');
        expect(queryBuilder.params[0].value, 'active');
        expect(queryBuilder.params[1].key, 'status');
        expect(queryBuilder.params[1].value, 'pending');
      });

      test('should handle multiple order by with same field', () {
        queryBuilder.orderByAsc('name').orderByDesc('name'); // This will add another order by with same field

        expect(queryBuilder.orderByClauses.length, 2);
        expect(queryBuilder.orderByClauses[0].field, 'name');
        expect(queryBuilder.orderByClauses[0].direction, OrderDirection.asc);
        expect(queryBuilder.orderByClauses[1].field, 'name');
        expect(queryBuilder.orderByClauses[1].direction, OrderDirection.desc);
      });

      test('should handle real-world scenario with codSepararEstoque field', () {
        // Simula o uso real do QueryBuilder no SeparateConsultationViewModel
        queryBuilder.paginate(limit: 20, offset: 0, page: 1).orderByDesc('codSepararEstoque');

        expect(queryBuilder.orderByClauses.length, 1);
        expect(queryBuilder.orderByClauses.first.field, 'codSepararEstoque');
        expect(queryBuilder.orderByClauses.first.direction, OrderDirection.desc);

        // Verifica se a query completa está correta
        final completeQuery = queryBuilder.buildCompleteQuery();
        expect(completeQuery, contains('LIMIT=20&OFFSET=0&PAGE=1'));
        expect(completeQuery, contains('order_by=codSepararEstoque&order_direction=DESC'));

        // Verifica se o SQL ORDER BY está correto
        final orderBySql = queryBuilder.buildOrderBySql();
        expect(orderBySql, 'ORDER BY codSepararEstoque DESC');
      });

      test('should verify that QueryBuilderExtension.withDefaultPagination + orderByDesc works', () {
        // Testa se o problema original foi resolvido
        final builder = QueryBuilderExtension.withDefaultPagination(
          limit: 20,
          offset: 0,
        ).orderByDesc('codSepararEstoque');

        expect(builder.orderByClauses.length, 1);
        expect(builder.orderByClauses.first.field, 'codSepararEstoque');
        expect(builder.orderByClauses.first.direction, OrderDirection.desc);
        expect(builder.buildOrderByQuery(), 'order_by=codSepararEstoque&order_direction=DESC');
        expect(builder.buildCompleteQuery(), contains('LIMIT=20&OFFSET=0&PAGE=1'));
        expect(builder.buildCompleteQuery(), contains('order_by=codSepararEstoque&order_direction=DESC'));
      });

      test('should verify pagination behavior - replace vs append', () {
        // Simula o comportamento de paginação
        final page1 = QueryBuilderExtension.withDefaultPagination(
          limit: 20,
          offset: 0,
        ).orderByDesc('codSepararEstoque');

        final page2 = QueryBuilderExtension.withDefaultPagination(
          limit: 20,
          offset: 20,
        ).orderByDesc('codSepararEstoque');

        // Verifica se ambas as páginas têm orderByDesc
        expect(page1.buildOrderByQuery(), 'order_by=codSepararEstoque&order_direction=DESC');
        expect(page2.buildOrderByQuery(), 'order_by=codSepararEstoque&order_direction=DESC');

        // Verifica se os offsets estão corretos
        expect(page1.buildCompleteQuery(), contains('OFFSET=0'));
        expect(page2.buildCompleteQuery(), contains('OFFSET=20'));
      });

      test('should verify error message handling', () {
        // Simula diferentes tipos de erro para testar o tratamento
        final dataError = DataError(message: 'Erro de conexão com o servidor');
        final stringError = 'Erro de validação';
        final genericError = Exception('Erro genérico');

        // Verifica se DataError.toString() retorna a mensagem
        expect(dataError.toString(), 'Erro de conexão com o servidor');

        // Verifica se outros tipos funcionam normalmente
        expect(stringError.toString(), 'Erro de validação');
        expect(genericError.toString(), contains('Erro genérico'));
      });

      test('should verify correct field name for code search', () {
        // Simula a busca por código usando o campo correto
        final queryBuilder = QueryBuilder()
          ..paginate(limit: 20, offset: 0)
          ..equals('CodSepararEstoque', '123')
          ..orderByDesc('codSepararEstoque');

        // Verifica se o campo correto está sendo usado (com aspas simples)
        expect(queryBuilder.buildCompleteQuery(), contains('CodSepararEstoque=\'123\''));
        expect(queryBuilder.buildOrderByQuery(), 'order_by=codSepararEstoque&order_direction=DESC');
      });
    });
  });
}
