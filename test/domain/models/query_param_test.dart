import 'package:flutter_test/flutter_test.dart';
import 'package:exp/domain/models/query_param.dart';

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
}
