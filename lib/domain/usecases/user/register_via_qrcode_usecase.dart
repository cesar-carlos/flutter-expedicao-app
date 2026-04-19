import 'package:data7_expedicao/domain/usecases/base_usecase.dart';
import 'package:data7_expedicao/domain/models/user/system_qrcode_data.dart';
import 'package:data7_expedicao/domain/models/user/user_api_exception.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class RegisterViaQRCodeParams {
  final SystemQRCodeData qrCodeData;

  const RegisterViaQRCodeParams({required this.qrCodeData});

  bool get isValid => _validateFields().isEmpty;

  List<String> get validationErrors => _validateFields();

  List<String> _validateFields() {
    final errors = <String>[];

    if (qrCodeData.nomeUsuario.trim().isEmpty) errors.add('Nome de usuário é obrigatório');
    if (qrCodeData.senhaUsuario.trim().isEmpty) errors.add('Senha é obrigatória');
    if (qrCodeData.codUsuario <= 0) errors.add('Código do usuário deve ser maior que zero');
    if (qrCodeData.codEmpresa <= 0) errors.add('Código da empresa deve ser maior que zero');
    return errors;
  }
}

class RegisterViaQRCodeSuccess {
  final AppUser user;
  final String message;

  const RegisterViaQRCodeSuccess({
    required this.user,
    this.message = 'Usuário cadastrado com sucesso via Login System',
  });
}

class RegisterViaQRCodeFailure extends AppFailure {
  const RegisterViaQRCodeFailure({required super.message, super.code, super.exception});

  @override
  String get userMessage => message;

  factory RegisterViaQRCodeFailure.invalidQRCode(String details) {
    return RegisterViaQRCodeFailure(message: 'QR Code inválido: $details', code: 'INVALID_QRCODE');
  }

  factory RegisterViaQRCodeFailure.wrongPassword() {
    return const RegisterViaQRCodeFailure(
      message: 'Usuário já cadastrado, mas a senha não confere',
      code: 'WRONG_PASSWORD',
    );
  }

  factory RegisterViaQRCodeFailure.registrationFailed(String details) {
    return RegisterViaQRCodeFailure(message: 'Falha ao cadastrar: $details', code: 'REGISTRATION_FAILED');
  }

  /// Bug N: erros de rede/servidor agora sao distinguidos explicitamente
  /// (antes caiam silenciosamente no fluxo de "tentar criar usuario",
  /// que tambem falhava e gerava mensagem confusa).
  factory RegisterViaQRCodeFailure.networkError(String details, [Object? exception]) {
    return RegisterViaQRCodeFailure(
      message: 'Erro de comunicação com o servidor: $details',
      code: 'NETWORK_ERROR',
      exception: exception is Exception ? exception : Exception(exception?.toString() ?? details),
    );
  }
}

class RegisterViaQRCodeUseCase extends UseCase<RegisterViaQRCodeSuccess, RegisterViaQRCodeParams> {
  final UserRepository _userRepository;
  final IUserSessionService _userSessionService;

  RegisterViaQRCodeUseCase({
    required UserRepository userRepository,
    required UserSystemRepository userSystemRepository,
    required IUserSessionService userSessionService,
  }) : _userRepository = userRepository,
       _userSessionService = userSessionService;

  @override
  Future<Result<RegisterViaQRCodeSuccess>> call(RegisterViaQRCodeParams params) async {
    try {
      if (!params.isValid) {
        final errors = params.validationErrors.join(', ');
        return failure(RegisterViaQRCodeFailure.invalidQRCode(errors));
      }

      final qrData = params.qrCodeData;
      final userName = qrData.nomeUsuario.trim();

      try {
        final loginResponse = await _userRepository.login(userName, qrData.senhaUsuario);

        final userSystemModel = qrData.toUserSystemModel();

        final user = loginResponse.user.copyWith(codUsuario: qrData.codUsuario, userSystemModel: userSystemModel);

        await _userSessionService.saveUserSession(user);

        return success(
          RegisterViaQRCodeSuccess(user: user, message: 'Bem-vindo de volta, $userName! Login realizado com sucesso.'),
        );
      } on UserApiException catch (loginError) {
        // Bug N corrigido: usar `statusCode` em vez de string-match
        // (`errorMessage.contains('senha')`) que era frágil — qualquer
        // erro com a palavra 'senha' (ex.: validação) era tratado como
        // wrongPassword, e erros de rede caíam silenciosamente no
        // createUser, gerando mensagens confusas.
        //
        // Convencao do servidor (UserRepositoryImpl.login):
        //   401 = Credenciais inválidas (usuario existe mas senha errada
        //         OU usuario nao cadastrado — servidor nao revela qual)
        //   400 = Validacao
        //   outros = erro inesperado/rede
        final isCredentialError = loginError.statusCode == 401;
        if (!isCredentialError) {
          // Erro de rede/servidor — NAO devemos tentar criar usuario
          // (que tambem ia falhar e mascarar o erro real).
          AppLogger.warning(
            'Erro nao-credencial ao tentar login no register_via_qrcode (status=${loginError.statusCode}): ${loginError.message}',
            tag: 'RegisterViaQRCodeUseCase',
          );
          return failure(RegisterViaQRCodeFailure.networkError(loginError.message, loginError));
        }

        // 401: usuario nao existe OU senha errada. Tentamos criar:
        // - Se nao existir, createUser cria com sucesso
        // - Se existir e a senha estiver errada, createUser tambem falhara
        //   e detectamos abaixo via 400 (validacao) → wrongPassword
        try {
          final createResponse = await _userRepository.createUser(
            nome: userName,
            senha: qrData.senhaUsuario,
            profileImage: null,
            codUsuario: qrData.codUsuario,
          );

          final userSystemModel = qrData.toUserSystemModel();

          final user = AppUser(
            codLoginApp: createResponse.codLoginApp,
            ativo: Situation.fromCodeWithFallback(createResponse.ativo),
            nome: createResponse.nome,
            codUsuario: qrData.codUsuario,
            userSystemModel: userSystemModel,
          );

          await _userSessionService.saveUserSession(user);

          return success(
            RegisterViaQRCodeSuccess(user: user, message: 'Bem-vindo, $userName! Cadastro realizado via Login System.'),
          );
        } on UserApiException catch (createError) {
          // Servidor retorna 400 quando o usuario ja existe (validacao).
          // Combinado com login 401 anterior, isso significa: usuario
          // existente com senha diferente.
          if (createError.statusCode == 400 || createError.isValidationError) {
            return failure(RegisterViaQRCodeFailure.wrongPassword());
          }
          return failure(RegisterViaQRCodeFailure.registrationFailed(createError.message));
        }
      }
    } on UserApiException catch (e) {
      return failure(RegisterViaQRCodeFailure.networkError(e.message, e));
    } catch (e) {
      // Bug H: catch generico para `Error`s nao capturados.
      return failure(RegisterViaQRCodeFailure.registrationFailed('Erro inesperado: ${e.toString()}'));
    }
  }
}
