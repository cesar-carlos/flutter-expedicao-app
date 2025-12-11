import 'dart:io';
import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/usecases/legacy_usecase.dart';

class RegisterUserParams {
  final String nome;
  final String senha;
  final File? profileImage;

  RegisterUserParams({required this.nome, required this.senha, this.profileImage});
}

class RegisterUserUseCase implements LegacyUseCase<CreateUserResponse, RegisterUserParams> {
  final UserRepository _userRepository;

  RegisterUserUseCase(this._userRepository);

  @override
  Future<CreateUserResponse> call(RegisterUserParams params) async {
    return await _userRepository.createUser(
      nome: params.nome.trim(),
      senha: params.senha,
      profileImage: params.profileImage,
    );
  }
}
