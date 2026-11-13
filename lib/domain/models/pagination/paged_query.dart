import 'package:data7_expedicao/domain/models/pagination/pagination.dart';

class PagedQuery {
  static Future<List<T>> collect<T>({
    required Future<List<T>> Function(int page, int pageSize) fetchPage,
    int pageSize = Pagination.fetchPageSize,
    int maxPages = Pagination.maxFetchPages,
  }) async {
    final size = pageSize < 1 ? 1 : pageSize;
    final all = <T>[];

    for (var page = 1; page <= maxPages; page++) {
      final rows = await fetchPage(page, size);
      all.addAll(rows);
      if (rows.length < size) return all;
      await Future<void>.delayed(Duration.zero);
    }

    throw StateError('A consulta ultrapassou $maxPages páginas de $size itens.');
  }
}
