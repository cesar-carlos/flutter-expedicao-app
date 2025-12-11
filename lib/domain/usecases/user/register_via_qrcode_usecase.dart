import 'package:data7_expedicao/domain/usecases/base_usecase.dart';
import 'package:data7_expedicao/domain/models/user/system_qrcode_data.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

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
}

class RegisterViaQRCodeUseCase extends UseCase<RegisterViaQRCodeSuccess, RegisterViaQRCodeParams> {
  final UserRepository _userRepository;
  final UserSessionService _userSessionService;

  RegisterViaQRCodeUseCase({
    required UserRepository userRepository,
    required UserSystemRepository userSystemRepository,
    required UserSessionService userSessionService,
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
      } catch (e) {
        final errorMessage = e.toString().toLowerCase();

        if (errorMessage.contains('senha') || errorMessage.contains('password')) {
          return failure(RegisterViaQRCodeFailure.wrongPassword());
        }

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
      }
    } catch (e) {
      return failure(RegisterViaQRCodeFailure.registrationFailed('Erro inesperado: ${e.toString()}'));
    }
  }
}
