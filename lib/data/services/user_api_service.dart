import 'dart:io';

import 'package:exp/domain/models/user/user_models.dart';
import 'package:exp/domain/repositories/user_repository.dart';

class UserApiService {
  final UserRepository _userRepository;

  /// Cria uma instância do UserApiService
  ///
  /// [_userRepository] deve ser uma implementação de UserRepository,
  /// geralmente UserRepositoryImpl configurado com ApiConfig
  UserApiService(this._userRepository);

  /// Cria um novo usuário delegando para o Repository
  ///
  /// Retorna [CreateUserResponse] em caso de sucesso
  /// Throws [UserApiException] em caso de erro
  Future<CreateUserResponse> createUser({
    required String nome,
    required String senha,
    File? profileImage,
  }) async {
    return await _userRepository.createUser(
      nome: nome,
      senha: senha,
      profileImage: profileImage,
    );
  }

  /// Busca dados do AppUser por código delegando para o Repository
  ///
  /// [codLoginApp] código do login do app para consulta
  /// Retorna [AppUserConsultationResponse] em caso de sucesso
  /// Throws [UserApiException] em caso de erro (ex: usuário não encontrado)
  Future<AppUserConsultation> getAppUserConsultation(int codLoginApp) async {
    return await _userRepository.getAppUser(codLoginApp);
  }
}
