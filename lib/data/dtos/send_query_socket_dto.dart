class SendQuerySocketDto {
  final String session;
  final String responseIn;
  final String? where;
  final String? pagination;
  final String? orderBy;

  const SendQuerySocketDto({
    required this.session,
    required this.responseIn,
    this.where,
    this.pagination,
    this.orderBy,
  });

  SendQuerySocketDto copyWith({
    String? session,
    String? responseIn,
    String? where,
    String? pagination,
    String? orderBy,
  }) {
    return SendQuerySocketDto(
      session: session ?? this.session,
      responseIn: responseIn ?? this.responseIn,
      where: where ?? this.where,
      pagination: pagination ?? this.pagination,
      orderBy: orderBy ?? this.orderBy,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'Session': session, 'ResponseIn': responseIn};

    if (where != null && where!.isNotEmpty) {
      json['Where'] = where;
    }
    if (pagination != null && pagination!.isNotEmpty) {
      json['Pagination'] = pagination;
    }
    if (orderBy != null && orderBy!.isNotEmpty) {
      json['OrderBy'] = orderBy;
    }

    return json;
  }

  factory SendQuerySocketDto.fromJson(Map<String, dynamic> json) {
    return SendQuerySocketDto(
      session: json['Session'] as String,
      responseIn: json['ResponseIn'] as String,
      where: json['Where'] as String?,
      pagination: json['Pagination'] as String?,
      orderBy: json['OrderBy'] as String?,
    );
  }

  @override
  String toString() {
    return 'SendQuerySocketDto('
        'session: $session, '
        'responseIn: $responseIn, '
        'where: $where, '
        'pagination: $pagination, '
        'orderBy: $orderBy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SendQuerySocketDto &&
        other.session == session &&
        other.responseIn == responseIn &&
        other.where == where &&
        other.pagination == pagination &&
        other.orderBy == orderBy;
  }

  @override
  int get hashCode {
    return Object.hash(session, responseIn, where, pagination, orderBy);
  }
}
