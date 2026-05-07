import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/user/system_qrcode_data.dart';
import 'package:data7_expedicao/domain/models/user/user_api_exception.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/base_usecase.dart';

class RegisterViaQRCodeParams {
  final SystemQRCodeData qrCodeData;

  const RegisterViaQRCodeParams({required this.qrCodeData});

  bool get isValid => _validateFields().isEmpty;

  List<String> get validationErrors => _validateFields();

  List<String> _validateFields() {
    final errors = <String>[];

    if (qrCodeData.nomeUsuario.trim().isEmpty) {
      errors.add('Nome de usuario e obrigatorio');
    }
    if (qrCodeData.senhaUsuario.trim().isEmpty) {
      errors.add('Senha e obrigatoria');
    }
    if (qrCodeData.codUsuario <= 0) {
      errors.add('Codigo do usuario deve ser maior que zero');
    }
    if (qrCodeData.codEmpresa <= 0) {
      errors.add('Codigo da empresa deve ser maior que zero');
    }

    return errors;
  }
}

class RegisterViaQRCodeSuccess {
  final AppUser user;
  final String message;

  const RegisterViaQRCodeSuccess({
    required this.user,
    this.message = 'Usuario cadastrado com sucesso via Login System',
  });
}

class RegisterViaQRCodeFailure extends AppFailure {
  const RegisterViaQRCodeFailure({required super.message, super.code, super.exception});

  @override
  String get userMessage => message;

  factory RegisterViaQRCodeFailure.invalidQRCode(String details) {
    return RegisterViaQRCodeFailure(message: 'QR Code invalido: $details', code: 'INVALID_QRCODE');
  }

  factory RegisterViaQRCodeFailure.wrongPassword() {
    return const RegisterViaQRCodeFailure(
      message: 'Usuario ja cadastrado, mas a senha nao confere',
      code: 'WRONG_PASSWORD',
    );
  }

  factory RegisterViaQRCodeFailure.registrationFailed(String details) {
    return RegisterViaQRCodeFailure(message: 'Falha ao cadastrar: $details', code: 'REGISTRATION_FAILED');
  }

  factory RegisterViaQRCodeFailure.userConfirmationFailed([Object? exception]) {
    return RegisterViaQRCodeFailure(
      message: 'Nao foi possivel confirmar o usuario no sistema apos o login. Tente novamente.',
      code: 'USER_CONFIRMATION_FAILED',
      exception: exception is Exception ? exception : Exception(exception?.toString() ?? 'Falha ao confirmar usuario'),
    );
  }

  factory RegisterViaQRCodeFailure.networkError(String details, [Object? exception]) {
    return RegisterViaQRCodeFailure(
      message: 'Erro de comunicacao com o servidor: $details',
      code: 'NETWORK_ERROR',
      exception: exception is Exception ? exception : Exception(exception?.toString() ?? details),
    );
  }
}

class RegisterViaQRCodeUseCase extends UseCase<RegisterViaQRCodeSuccess, RegisterViaQRCodeParams> {
  RegisterViaQRCodeUseCase({
    required UserRepository userRepository,
    required UserSystemRepository userSystemRepository,
    required IUserSessionService userSessionService,
  }) : _userRepository = userRepository,
       _userSystemRepository = userSystemRepository,
       _userSessionService = userSessionService;

  final UserRepository _userRepository;
  final UserSystemRepository _userSystemRepository;
  final IUserSessionService _userSessionService;

  @override
  Future<Result<RegisterViaQRCodeSuccess>> call(RegisterViaQRCodeParams params) async {
    if (!params.isValid) {
      final errors = params.validationErrors.join(', ');
      AppLogger.warning('QR invalido recebido para login', tag: 'RegisterViaQRCodeUseCase');
      return failure(RegisterViaQRCodeFailure.invalidQRCode(errors));
    }

    final qrData = params.qrCodeData;
    final userName = qrData.nomeUsuario.trim();

    AppLogger.operation(
      'Iniciando autenticacao via QR para codUsuario=${qrData.codUsuario}',
      tag: 'RegisterViaQRCodeUseCase',
    );

    try {
      try {
        AppLogger.info('Tentando login-app com credenciais do QR', tag: 'RegisterViaQRCodeUseCase');
        final loginResponse = await _userRepository.login(userName, qrData.senhaUsuario);
        final user = await _confirmUserInSystem(
          codLoginApp: loginResponse.user.codLoginApp,
          ativo: loginResponse.user.ativo,
          nome: loginResponse.user.nome,
          codUsuario: qrData.codUsuario,
        );

        await _persistConfirmedSession(user);

        AppLogger.success('Login via QR confirmado em /usuarios', tag: 'RegisterViaQRCodeUseCase');
        return success(
          RegisterViaQRCodeSuccess(user: user, message: 'Bem-vindo de volta, $userName! Login realizado com sucesso.'),
        );
      } on UserApiException catch (loginError) {
        if (loginError.statusCode != 401) {
          AppLogger.warning(
            'Falha nao credencial em login-app via QR (status=${loginError.statusCode})',
            tag: 'RegisterViaQRCodeUseCase',
            error: loginError,
          );
          return failure(RegisterViaQRCodeFailure.networkError(loginError.message, loginError));
        }

        AppLogger.info(
          'Login-app retornou 401; tentando create-login-app para codUsuario=${qrData.codUsuario}',
          tag: 'RegisterViaQRCodeUseCase',
        );

        try {
          final createResponse = await _userRepository.createUser(
            nome: userName,
            senha: qrData.senhaUsuario,
            profileImage: null,
            codUsuario: qrData.codUsuario,
          );
          final user = await _confirmUserInSystem(
            codLoginApp: createResponse.codLoginApp,
            ativo: Situation.fromCodeWithFallback(createResponse.ativo),
            nome: createResponse.nome,
            codUsuario: qrData.codUsuario,
          );

          await _persistConfirmedSession(user);

          AppLogger.success('Cadastro via QR confirmado em /usuarios', tag: 'RegisterViaQRCodeUseCase');
          return success(
            RegisterViaQRCodeSuccess(user: user, message: 'Bem-vindo, $userName! Cadastro realizado via Login System.'),
          );
        } on UserApiException catch (createError) {
          if (createError.statusCode == 400 || createError.isValidationError) {
            AppLogger.warning(
              'create-login-app falhou com validacao apos 401 no login-app; senha divergente',
              tag: 'RegisterViaQRCodeUseCase',
              error: createError,
            );
            return failure(RegisterViaQRCodeFailure.wrongPassword());
          }

          AppLogger.warning(
            'Falha em create-login-app via QR (status=${createError.statusCode})',
            tag: 'RegisterViaQRCodeUseCase',
            error: createError,
          );
          return failure(RegisterViaQRCodeFailure.registrationFailed(createError.message));
        }
      }
    } on RegisterViaQRCodeFailure catch (failureResult) {
      return failure(failureResult);
    } on UserApiException catch (e) {
      return failure(RegisterViaQRCodeFailure.networkError(e.message, e));
    } catch (e, s) {
      AppLogger.error(
        'Erro inesperado no fluxo de login via QR',
        tag: 'RegisterViaQRCodeUseCase',
        error: e,
        stackTrace: s,
      );
      return failure(RegisterViaQRCodeFailure.registrationFailed('Erro inesperado: ${e.toString()}'));
    }
  }

  Future<AppUser> _confirmUserInSystem({
    required int codLoginApp,
    required Situation ativo,
    required String nome,
    required int codUsuario,
  }) async {
    try {
      AppLogger.info(
        'Confirmando usuario autenticado via /usuarios para codUsuario=$codUsuario',
        tag: 'RegisterViaQRCodeUseCase',
      );
      final userSystemModel = await _userSystemRepository.getUserById(codUsuario);

      if (userSystemModel == null) {
        AppLogger.warning(
          'Confirmacao autoritativa retornou null para codUsuario=$codUsuario',
          tag: 'RegisterViaQRCodeUseCase',
        );
        throw RegisterViaQRCodeFailure.userConfirmationFailed();
      }

      return AppUser(
        codLoginApp: codLoginApp,
        ativo: ativo,
        nome: nome,
        codUsuario: codUsuario,
        userSystemModel: userSystemModel,
      );
    } on RegisterViaQRCodeFailure {
      rethrow;
    } catch (e, s) {
      AppLogger.warning(
        'Confirmacao autoritativa falhou para codUsuario=$codUsuario',
        tag: 'RegisterViaQRCodeUseCase',
        error: e,
        stackTrace: s,
      );
      throw RegisterViaQRCodeFailure.userConfirmationFailed(e);
    }
  }

  Future<void> _persistConfirmedSession(AppUser user) async {
    AppLogger.info(
      'Persistindo sessao QR confirmada para codUsuario=${user.codUsuario}',
      tag: 'RegisterViaQRCodeUseCase',
    );
    await _userSessionService.saveUserSession(user);
  }
}
