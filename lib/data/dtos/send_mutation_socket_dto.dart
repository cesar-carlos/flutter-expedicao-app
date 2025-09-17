class SendMutationSocketDto {
  final String session;
  final String responseIn;
  final Map<String, dynamic> mutation;

  SendMutationSocketDto({required this.session, required this.responseIn, required this.mutation});

  Map<String, dynamic> toJson() {
    return {'Session': session, 'ResponseIn': responseIn, 'Mutation': mutation};
  }
}
