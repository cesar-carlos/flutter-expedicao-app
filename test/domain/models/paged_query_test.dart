import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/pagination/paged_query.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';

void main() {
  group('PagedQuery.collect', () {
    test('concatena páginas até a última vir curta', () async {
      final pages = <int, List<int>>{
        1: List<int>.generate(Pagination.fetchPageSize, (i) => i),
        2: List<int>.generate(10, (i) => i + Pagination.fetchPageSize),
      };

      final result = await PagedQuery.collect(
        fetchPage: (page, pageSize) async {
          expect(pageSize, Pagination.fetchPageSize);
          return pages[page] ?? const [];
        },
      );

      expect(result, hasLength(Pagination.fetchPageSize + 10));
      expect(result.first, 0);
      expect(result.last, Pagination.fetchPageSize + 9);
    });

    test('para na primeira página vazia', () async {
      final result = await PagedQuery.collect(
        fetchPage: (page, pageSize) async => const [],
      );

      expect(result, isEmpty);
    });

    test('lança quando ultrapassa o teto de páginas', () async {
      await expectLater(
        PagedQuery.collect(
          pageSize: 2,
          maxPages: 2,
          fetchPage: (page, pageSize) async => [1, 2],
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('ultrapassou 2 páginas'),
          ),
        ),
      );
    });
  });

  group('Pagination', () {
    test('unbounded usa o teto técnico do SQL INT', () {
      final page = Pagination.unbounded();

      expect(page.limit, Pagination.sqlIntMax);
      expect(page.offset, 0);
      expect(page.page, 1);
      expect(page.toQueryString(), 'LIMIT=${Pagination.sqlIntMax}&OFFSET=0&PAGE=1');
    });

    test('page calcula OFFSET a partir do número da página', () {
      final page = Pagination.page(page: 3, pageSize: 500);

      expect(page.limit, 500);
      expect(page.offset, 1000);
      expect(page.page, 3);
    });
  });
}
