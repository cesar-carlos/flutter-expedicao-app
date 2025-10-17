import 'dart:io';

import 'package:data7_expedicao/domain/models/user/user_models.dart';

abstract class UserRepository {
  Future<CreateUserResponse> createUser({
    required String nome,
    required String senha,
    File? profileImage,
    int? codUsuario,
  });

  Future<LoginResponse> login(String nome, String senha);

  Future<AppUserConsultation> getAppUser(int codLoginApp);

  Future<AppUserConsultation> putAppUser(AppUser appUser);

  /// Valida se a senha atual do usuário está correta
  Future<bool> validateCurrentPassword({required String nome, required String currentPassword});

  /// Altera a senha do usuário
  Future<bool> changePassword({required String nome, required String currentPassword, required String newPassword});
}
