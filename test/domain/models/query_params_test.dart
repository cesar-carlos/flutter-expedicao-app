import 'package:flutter_test/flutter_test.dart';
import 'package:exp/domain/models/query_param.dart';
import 'package:exp/domain/models/pagination.dart';
import 'package:exp/domain/models/query_builder.dart';
import 'package:exp/domain/models/query_builder_extension.dart';

void main() {
  group('QueryParam Tests', () {
    test('should create QueryParam with default operator', () {
      final param = QueryParam.create('name', 'John');

      expect(param.key, 'name');
      expect(param.value, 'John');
      expect(param.operator, '=');
    });

    test('should create QueryParam with custom operator', () {
      final param = QueryParam.createWithOperator('age', 25, '>');

      expect(param.key, 'age');
      expect(param.value, 25);
      expect(param.operator, '>');
    });

    test('should format string value correctly', () {
      final param = QueryParam.create('name', 'John Doe');
      expect(param.toQueryString(), "name='John Doe'");
    });

    test('should format integer value correctly', () {
      final param = QueryParam.create('age', 25);
      expect(param.toQueryString(), 'age=25');
    });

    test('should format double value correctly', () {
      final param = QueryParam.create('price', 19.99);
      expect(param.toQueryString(), 'price=19.99');
    });

    test('should format DateTime value correctly', () {
      final date = DateTime(2024, 1, 15, 10, 30);
      final param = QueryParam.create('created_at', date);
      expect(param.toQueryString(), "created_at='2024-01-15T10:30:00.000'");
    });

    test('should format boolean value correctly', () {
      final param = QueryParam.create('active', true);
      expect(param.toQueryString(), 'active=true');
    });

    test('should handle different operators', () {
      final equalsParam = QueryParam.createWithOperator(
        'status',
        'active',
        '=',
      );
      final notEqualsParam = QueryParam.createWithOperator(
        'status',
        'inactive',
        '!=',
      );
      final likeParam = QueryParam.createWithOperator('name', 'John', 'LIKE');
      final greaterParam = QueryParam.createWithOperator('age', 18, '>');
      final lessParam = QueryParam.createWithOperator('age', 65, '<');

      expect(equalsParam.toQueryString(), "status='active'");
      expect(notEqualsParam.toQueryString(), "status!='inactive'");
      expect(likeParam.toQueryString(), "nameLIKE'John'");
      expect(greaterParam.toQueryString(), 'age>18');
      expect(lessParam.toQueryString(), 'age<65');
    });

    test('should implement equality correctly', () {
      final param1 = QueryParam.create('name', 'John');
      final param2 = QueryParam.create('name', 'John');
      final param3 = QueryParam.create('name', 'Jane');

      expect(param1, equals(param2));
      expect(param1, isNot(equals(param3)));
    });

    test('should implement hashCode correctly', () {
      final param1 = QueryParam.create('name', 'John');
      final param2 = QueryParam.create('name', 'John');
      final param3 = QueryParam.create('name', 'Jane');

      expect(param1.hashCode, equals(param2.hashCode));
      expect(param1.hashCode, isNot(equals(param3.hashCode)));
    });

    test('should have correct string representation', () {
      final param = QueryParam.create('name', 'John');
      expect(
        param.toString(),
        'QueryParam(key: name, value: John, operator: =)',
      );
    });
  });

  group('Pagination Tests', () {
    test('should create Pagination with required values', () {
      final pagination = Pagination(limit: 20, offset: 10);

      expect(pagination.limit, 20);
      expect(pagination.offset, 10);
    });

    test('should create Pagination with default values', () {
      final pagination = Pagination.create();

      expect(pagination.limit, 10);
      expect(pagination.offset, 0);
    });

    test('should create Pagination with custom values', () {
      final pagination = Pagination.create(limit: 50, offset: 100);

      expect(pagination.limit, 50);
      expect(pagination.offset, 100);
    });

    test('should convert to query string correctly', () {
      final pagination = Pagination(limit: 25, offset: 50);
      expect(pagination.toQueryString(), 'limit=25&offset=50');
    });

    test('should implement equality correctly', () {
      final pagination1 = Pagination(limit: 10, offset: 0);
      final pagination2 = Pagination(limit: 10, offset: 0);
      final pagination3 = Pagination(limit: 20, offset: 0);

      expect(pagination1, equals(pagination2));
      expect(pagination1, isNot(equals(pagination3)));
    });

    test('should implement hashCode correctly', () {
      final pagination1 = Pagination(limit: 10, offset: 0);
      final pagination2 = Pagination(limit: 10, offset: 0);
      final pagination3 = Pagination(limit: 20, offset: 0);

      expect(pagination1.hashCode, equals(pagination2.hashCode));
      expect(pagination1.hashCode, isNot(equals(pagination3.hashCode)));
    });

    test('should have correct string representation', () {
      final pagination = Pagination(limit: 15, offset: 30);
      expect(pagination.toString(), 'Pagination(limit: 15, offset: 30)');
    });
  });

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

  group('QueryBuilderExtension Tests', () {
    late QueryBuilder queryBuilder;

    setUp(() {
      queryBuilder = QueryBuilder();
    });

    test('should create QueryBuilder with default pagination', () {
      final query = QueryBuilderExtension.withDefaultPagination();

      expect(query.pagination, isNotNull);
      expect(query.pagination!.limit, 20);
      expect(query.pagination!.offset, 0);
      expect(query.params, isEmpty);
    });

    test('should create QueryBuilder with custom pagination', () {
      final query = QueryBuilderExtension.withDefaultPagination(
        limit: 50,
        offset: 100,
      );

      expect(query.pagination, isNotNull);
      expect(query.pagination!.limit, 50);
      expect(query.pagination!.offset, 100);
      expect(query.params, isEmpty);
    });

    test('should build query with default pagination', () {
      final query = QueryBuilderExtension.withDefaultPagination();

      expect(query.build(), 'limit=20&offset=0');
    });

    test('should build query with custom pagination', () {
      final query = QueryBuilderExtension.withDefaultPagination(
        limit: 10,
        offset: 30,
      );

      expect(query.build(), 'limit=10&offset=30');
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

    test('should support chaining with withDefaultPagination', () {
      final query = QueryBuilderExtension.withDefaultPagination()
          .status('active')
          .code('ABC123')
          .search('name', 'John');

      expect(query.params.length, 3);
      expect(query.pagination, isNotNull);
      expect(query.pagination!.limit, 20);
      expect(query.pagination!.offset, 0);
    });

    test('should build complete query with withDefaultPagination', () {
      final query = QueryBuilderExtension.withDefaultPagination()
          .status('active')
          .code('ABC123')
          .search('name', 'John')
          .build();

      expect(query, contains("situacao='active'"));
      expect(query, contains("codigo='ABC123'"));
      expect(query, contains("nameLIKE'%John%'"));
      expect(query, contains('limit=20&offset=0'));
    });
  });

  group('Complex Query Scenarios', () {
    test('should build complex query with all features', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);

      final query = QueryBuilder()
          .equals('status', 'active')
          .notEquals('deleted', true)
          .like('name', 'John')
          .greaterThan('age', 18)
          .lessThan('age', 65)
          .inList('category', ['electronics', 'books'])
          .dateRange('created_at', startDate, endDate)
          .search('description', 'important')
          .paginate(limit: 50, offset: 100)
          .build();

      expect(query, contains("status='active'"));
      expect(query, contains('deleted!=true'));
      expect(query, contains("nameLIKE'John'"));
      expect(query, contains('age>18'));
      expect(query, contains('age<65'));
      expect(query, contains("categoryIN''electronics','books''"));
      expect(query, contains('created_at>'));
      expect(query, contains('created_at<'));
      expect(query, contains("descriptionLIKE'%important%'"));
      expect(query, contains('limit=50&offset=100'));
    });

    test('should handle empty values gracefully', () {
      final query = QueryBuilder()
          .equals('name', '')
          .equals('age', 0)
          .equals('active', false)
          .build();

      expect(query, contains("name=''"));
      expect(query, contains('age=0'));
      expect(query, contains('active=false'));
    });

    test('should handle special characters in strings', () {
      final query = QueryBuilder()
          .equals('name', "O'Connor")
          .equals('description', 'Test "quoted" text')
          .build();

      expect(query, contains("name='O'Connor'"));
      expect(query, contains("description='Test \"quoted\" text'"));
    });
  });

  group('Real-world Usage Scenarios', () {
    test(
      'should build separate consultation query with default pagination',
      () {
        final query = QueryBuilderExtension.withDefaultPagination()
            .status('ATIVO')
            .code('SEP001')
            .search('descricao', 'urgente')
            .build();

        expect(query, contains("situacao='ATIVO'"));
        expect(query, contains("codigo='SEP001'"));
        expect(query, contains("descricaoLIKE'%urgente%'"));
        expect(query, contains('limit=20&offset=0'));
      },
    );

    test('should build separate consultation query with custom pagination', () {
      final query = QueryBuilderExtension.withDefaultPagination(
        limit: 50,
        offset: 100,
      ).status('PENDENTE').search('usuario', 'admin').build();

      expect(query, contains("situacao='PENDENTE'"));
      expect(query, contains("usuarioLIKE'%admin%'"));
      expect(query, contains('limit=50&offset=100'));
    });

    test('should build date range query for separate consultations', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);

      final query = QueryBuilderExtension.withDefaultPagination()
          .status('FINALIZADA')
          .dateRange('data_criacao', startDate, endDate)
          .build();

      expect(query, contains("situacao='FINALIZADA'"));
      expect(query, contains('data_criacao>'));
      expect(query, contains('data_criacao<'));
      expect(query, contains('limit=20&offset=0'));
    });

    test('should build complex filter query for separate consultations', () {
      final query = QueryBuilderExtension.withDefaultPagination()
          .status('ATIVO')
          .code('SEP')
          .search('observacoes', 'prioridade')
          .equals('usuario', 'admin')
          .notEquals('deleted', true)
          .build();

      expect(query, contains("situacao='ATIVO'"));
      expect(query, contains("codigo='SEP'"));
      expect(query, contains("observacoesLIKE'%prioridade%'"));
      expect(query, contains("usuario='admin'"));
      expect(query, contains('deleted!=true'));
      expect(query, contains('limit=20&offset=0'));
    });

    test('should build query with multiple status values', () {
      final query = QueryBuilderExtension.withDefaultPagination()
          .inList('situacao', ['ATIVO', 'PENDENTE', 'PROCESSANDO'])
          .search('codigo', 'SEP')
          .build();

      expect(query, contains("situacaoIN''ATIVO','PENDENTE','PROCESSANDO''"));
      expect(query, contains("codigoLIKE'%SEP%'"));
      expect(query, contains('limit=20&offset=0'));
    });

    test('should build query for different page sizes', () {
      final query1 = QueryBuilderExtension.withDefaultPagination(limit: 10);
      final query2 = QueryBuilderExtension.withDefaultPagination(limit: 100);

      expect(query1.build(), 'limit=10&offset=0');
      expect(query2.build(), 'limit=100&offset=0');
    });

    test('should build query for different page offsets', () {
      final query1 = QueryBuilderExtension.withDefaultPagination(offset: 0);
      final query2 = QueryBuilderExtension.withDefaultPagination(offset: 20);
      final query3 = QueryBuilderExtension.withDefaultPagination(offset: 40);

      expect(query1.build(), 'limit=20&offset=0');
      expect(query2.build(), 'limit=20&offset=20');
      expect(query3.build(), 'limit=20&offset=40');
    });
  });
}
