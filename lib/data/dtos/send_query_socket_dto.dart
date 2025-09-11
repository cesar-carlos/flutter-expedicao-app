enum OrderBy { ASC, DESC }

class SendQuerySocketDto {
  final String session;
  final String responseIn;
  final String? where;
  final String? pagination;
  final OrderBy orderBy;

  SendQuerySocketDto({
    required this.session,
    required this.responseIn,
    this.where,
    this.pagination,
    this.orderBy = OrderBy.ASC,
  });

  Map<String, dynamic> toJson() {
    return {
      'Session': session,
      'ResponseIn': responseIn,
      'Where': where,
      'Pagination': pagination,
      'OrderBy': orderBy.toString().split('.').last,
    };
  }

  @override
  String toString() {
    return '''
      SendQuerySocketDto(
        session: $session, 
        responseIn: $responseIn, 
        where: $where,
        pagination: $pagination,
        orderBy: $orderBy
    )''';
  }
}
