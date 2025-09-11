import 'package:flutter_test/flutter_test.dart';
import 'package:exp/domain/models/pagination.dart';

void main() {
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
}
