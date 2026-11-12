class Pagination {
  /// Teto técnico do LIMIT no SQL Server. Um LIMIT explícito do cliente
  /// não é cortado nos 1500 do servidor.
  static const int sqlIntMax = 2147483647;

  /// Página ao buscar a lista inteira em vários pedidos.
  /// 200 no coletor: payload leve o bastante para não travar a fila do socket.
  /// 500 (desktop) e 1500 (padrão do servidor) ainda pesam demais no coletor.
  static const int fetchPageSize = 200;

  /// 200 × 200 = 40_000 linhas. Acima disso a consulta está errada.
  static const int maxFetchPages = 200;

  final int limit;
  final int offset;
  final int page;

  const Pagination({required this.limit, required this.offset, required this.page});

  static Pagination create({int limit = 50, int offset = 0, int page = 1}) {
    return Pagination(limit: limit, offset: offset, page: page);
  }

  /// Uma página só, sem o teto de 1500 do servidor.
  factory Pagination.unbounded() {
    return const Pagination(limit: sqlIntMax, offset: 0, page: 1);
  }

  factory Pagination.page({required int page, required int pageSize}) {
    final size = pageSize < 1 ? 1 : pageSize;
    final normalizedPage = page < 1 ? 1 : page;
    return Pagination(limit: size, offset: (normalizedPage - 1) * size, page: normalizedPage);
  }

  String toQueryString() {
    return 'LIMIT=$limit&OFFSET=$offset&PAGE=$page';
  }

  @override
  String toString() {
    return 'Pagination(limit: $limit, offset: $offset, page: $page)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pagination && other.limit == limit && other.offset == offset && other.page == page;
  }

  @override
  int get hashCode => Object.hash(limit, offset, page);
}
