enum OrderBy { ASC, DESC }

class SendQuerySocketDto {
  final String session;
  final String responseIn;
  final String where;
  final int limit;
  final OrderBy orderBy;

  SendQuerySocketDto({
    required this.session,
    required this.responseIn,
    required this.where,
    this.limit = 0,
    this.orderBy = OrderBy.ASC,
  });

  Map<String, dynamic> toJson() {
    return {
      'Session': session,
      'ResponseIn': responseIn,
      'Where': where,
      'Limit': limit,
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
        limit: $limit,
        orderBy: $orderBy
    )''';
  }
}
