import 'dart:io';
import 'package:exp/domain/models/user/user_models.dart';
import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/domain/usecases/base_usecase.dart';

/// Parâmetros para o caso de uso de registro de usuário
class RegisterUserParams {
  final String nome;
  final String senha;
  final File? profileImage;

  RegisterUserParams({required this.nome, required this.senha, this.profileImage});
}

/// Caso de uso para registrar um novo usuário
class RegisterUserUseCase implements UseCase<CreateUserResponse, RegisterUserParams> {
  final UserRepository _userRepository;

  RegisterUserUseCase(this._userRepository);

  @override
  Future<CreateUserResponse> call(RegisterUserParams params) async {
    // Validações de negócio podem ser feitas aqui se necessário
    // Por exemplo: verificar se nome não está vazio, senha atende critérios, etc.

    return await _userRepository.createUser(
      nome: params.nome.trim(),
      senha: params.senha,
      profileImage: params.profileImage,
    );
  }
}
