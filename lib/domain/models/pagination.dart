/// Pagination parameters
class Pagination {
  final int limit;
  final int offset;

  const Pagination({required this.limit, required this.offset});

  /// Creates pagination with default values
  static Pagination create({int limit = 10, int offset = 0}) {
    return Pagination(limit: limit, offset: offset);
  }

  /// Converts to query string format
  String toQueryString() {
    return 'limit=$limit&offset=$offset';
  }

  @override
  String toString() {
    return 'Pagination(limit: $limit, offset: $offset)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pagination &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(limit, offset);
}
