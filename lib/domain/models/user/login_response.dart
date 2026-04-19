import 'package:data7_expedicao/domain/models/user/app_user.dart';

class LoginResponse {
  final String message;
  final AppUser user;

  LoginResponse({required this.message, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Bug ZZZZZZZZZZZ: antes era `json['message']` direto e
    // `AppUser.fromJson(json['user'])` sem checks. Se o servidor
    // retornasse `message` null ou `user` como tipo errado, crashava
    // com TypeError. Agora defensivo:
    // - message: fallback string vazia se ausente
    // - user: type check de Map antes de delegar; se ausente, lanca
    //   FormatException clara (login sem user nao faz sentido)
    final userRaw = json['user'];
    if (userRaw is! Map) {
      throw FormatException(
        'LoginResponse requer campo "user" como objeto, recebido ${userRaw.runtimeType}',
      );
    }
    return LoginResponse(
      message: json['message']?.toString() ?? '',
      user: AppUser.fromJson(Map<String, dynamic>.from(userRaw)),
    );
  }

  @override
  String toString() {
    return 'LoginResponse(message: $message, user: $user)';
  }
}
