import 'package:exp/domain/models/user/user_models.dart';
import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/domain/usecases/legacy_usecase.dart';

class LoginUserParams {
  final String nome;
  final String senha;

  LoginUserParams({required this.nome, required this.senha});
}

class LoginUserUseCase implements LegacyUseCase<LoginResponse, LoginUserParams> {
  final UserRepository _userRepository;
  LoginUserUseCase(this._userRepository);

  @override
  Future<LoginResponse> call(LoginUserParams params) async {
    final nome = params.nome.trim();

    if (nome.isEmpty) {
      throw UserApiException('Nome de usuário é obrigatório', statusCode: 400, isValidationError: true);
    }

    if (params.senha.length < 4) {
      throw UserApiException('Senha deve ter pelo menos 4 caracteres', statusCode: 400, isValidationError: true);
    }

    final loginResponse = await _userRepository.login(nome, params.senha);

    if (!loginResponse.user.isActive) {
      throw UserApiException('Usuário não está ativo no sistema', statusCode: 401);
    }

    return loginResponse;
  }
}
