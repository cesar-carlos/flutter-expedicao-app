import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/validation/schemas/model_schema/pagination_schemas.dart';

void main() {
  group('PaginationSchemas.validatePaginationIndices', () {
    test('aceita lista vazia (totalItems=0) sem RangeError', () {
      // Bug latente anterior: clamp(0, totalItems-1) crashava com
      // RangeError quando totalItems == 0 (lower=0 > upper=-1).
      expect(
        PaginationSchemas.validatePaginationIndices(0, 0, 1, 20, 0),
        isTrue,
      );
      // Qualquer par para lista vazia eh aceito (politica permissiva).
      expect(
        PaginationSchemas.validatePaginationIndices(99, 99, 5, 10, 0),
        isTrue,
      );
    });

    test('rejeita parametros invalidos (pageSize <= 0, valores negativos)', () {
      expect(PaginationSchemas.validatePaginationIndices(0, 9, 1, 0, 100), isFalse);
      expect(PaginationSchemas.validatePaginationIndices(-1, 9, 1, 10, 100), isFalse);
      expect(PaginationSchemas.validatePaginationIndices(0, 9, 0, 10, 100), isFalse);
    });

    test('valida indices corretos para pagina cheia', () {
      // Pagina 1, pageSize 10, total 100 -> indices [0..9]
      expect(
        PaginationSchemas.validatePaginationIndices(0, 9, 1, 10, 100),
        isTrue,
      );
      // Pagina 3, pageSize 10, total 100 -> indices [20..29]
      expect(
        PaginationSchemas.validatePaginationIndices(20, 29, 3, 10, 100),
        isTrue,
      );
    });

    test('valida indices da ultima pagina parcial', () {
      // Pagina 5, pageSize 10, total 47 -> indices [40..46]
      expect(
        PaginationSchemas.validatePaginationIndices(40, 46, 5, 10, 47),
        isTrue,
      );
    });

    test('rejeita startIndex > endIndex em lista nao vazia', () {
      expect(
        PaginationSchemas.validatePaginationIndices(20, 10, 1, 10, 100),
        isFalse,
      );
    });

    test('rejeita indices inconsistentes com pagina informada', () {
      // Pagina 3 (esperado [20..29]) mas passou [0..9]
      expect(
        PaginationSchemas.validatePaginationIndices(0, 9, 3, 10, 100),
        isFalse,
      );
    });
  });

  group('PaginationSchemas.validatePaginationConsistency', () {
    test('rejeita pageSize <= 0 (evita divisao por zero indireta)', () {
      // Bug latente anterior: pageSize=0 causava `(totalItems-1)/0`
      // = Infinity em Dart, comportamento indefinido depois.
      expect(
        PaginationSchemas.validatePaginationConsistency(1, 1, 100, 0),
        isFalse,
      );
      expect(
        PaginationSchemas.validatePaginationConsistency(1, 1, 100, -5),
        isFalse,
      );
    });

    test('rejeita currentPage < 1', () {
      expect(
        PaginationSchemas.validatePaginationConsistency(0, 10, 100, 10),
        isFalse,
      );
    });

    test('aceita lista vazia (totalItems=0, totalPages=0)', () {
      expect(
        PaginationSchemas.validatePaginationConsistency(1, 0, 0, 10),
        isTrue,
      );
    });

    test('valida consistencia correta', () {
      // total 100, pageSize 10 -> totalPages = 10
      expect(
        PaginationSchemas.validatePaginationConsistency(1, 10, 100, 10),
        isTrue,
      );
      // total 47, pageSize 10 -> totalPages = 5
      expect(
        PaginationSchemas.validatePaginationConsistency(3, 5, 47, 10),
        isTrue,
      );
    });

    test('rejeita totalPages inconsistente', () {
      expect(
        PaginationSchemas.validatePaginationConsistency(1, 5, 100, 10),
        isFalse,
      );
    });
  });
}
