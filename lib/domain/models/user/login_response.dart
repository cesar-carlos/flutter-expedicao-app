import 'package:data7_expedicao/domain/models/user/app_user.dart';

class LoginResponse {
  final String message;
  final AppUser user;

  LoginResponse({required this.message, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(message: json['message'], user: AppUser.fromJson(json['user']));
  }

  @override
  String toString() {
    return 'LoginResponse(message: $message, user: $user)';
  }
}
