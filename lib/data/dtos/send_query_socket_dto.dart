class SendQuerySocketDto {
  final String session;
  final String responseIn;
  final String where;

  SendQuerySocketDto({
    required this.session,
    required this.responseIn,
    required this.where,
  });

  Map<String, dynamic> toJson() {
    return {'Session': session, 'ResponseIn': responseIn, 'Where': where};
  }
}
