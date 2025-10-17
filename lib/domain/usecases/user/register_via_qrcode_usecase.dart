import 'package:data7_expedicao/domain/usecases/base_usecase.dart';
import 'package:data7_expedicao/domain/models/user/system_qrcode_data.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Parâmetros para registro via QR Code.
///
/// Encapsula os dados do QR Code e validações necessárias.
class RegisterViaQRCodeParams {
  final SystemQRCodeData qrCodeData;

  const RegisterViaQRCodeParams({required this.qrCodeData});

  /// Verifica se os dados são válidos para registro.
  bool get isValid => _validateFields().isEmpty;

  /// Lista de erros de validação.
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

/// Resultado de sucesso do registro via QR Code.
///
/// Contém o usuário criado e uma mensagem de confirmação.
class RegisterViaQRCodeSuccess {
  final AppUser user;
  final String message;

  const RegisterViaQRCodeSuccess({
    required this.user,
    this.message = 'Usuário cadastrado com sucesso via Login System',
  });
}

/// Falha no registro via QR Code.
///
/// Representa diferentes tipos de falhas que podem ocorrer durante o registro.
class RegisterViaQRCodeFailure extends AppFailure {
  const RegisterViaQRCodeFailure({required super.message, super.code, super.exception});

  @override
  String get userMessage => message;

  /// Falha por QR Code inválido.
  factory RegisterViaQRCodeFailure.invalidQRCode(String details) {
    return RegisterViaQRCodeFailure(message: 'QR Code inválido: $details', code: 'INVALID_QRCODE');
  }

  /// Falha por senha incorreta.
  factory RegisterViaQRCodeFailure.wrongPassword() {
    return const RegisterViaQRCodeFailure(
      message: 'Usuário já cadastrado, mas a senha não confere',
      code: 'WRONG_PASSWORD',
    );
  }

  /// Falha no processo de registro.
  factory RegisterViaQRCodeFailure.registrationFailed(String details) {
    return RegisterViaQRCodeFailure(message: 'Falha ao cadastrar: $details', code: 'REGISTRATION_FAILED');
  }
}

/// UseCase para registrar usuário via QR Code do Sistema
///
/// Este caso de uso:
/// 1. Valida os dados do QR Code
/// 2. Cria o cadastro local do usuário
/// 3. Vincula com os dados do sistema
/// 4. Salva a sessão do usuário
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
      // 1. Validar parâmetros de entrada
      if (!params.isValid) {
        final errors = params.validationErrors.join(', ');
        return failure(RegisterViaQRCodeFailure.invalidQRCode(errors));
      }

      final qrData = params.qrCodeData;
      final userName = qrData.nomeUsuario.trim();

      // 2. Verificar se o usuário já existe
      try {
        final loginResponse = await _userRepository.login(userName, qrData.senhaUsuario);

        // Usuário existe e senha está correta - atualizar dados do sistema e fazer login
        final userSystemModel = qrData.toUserSystemModel();

        // Atualizar o AppUser com os novos dados do sistema do QR Code
        final user = loginResponse.user.copyWith(codUsuario: qrData.codUsuario, userSystemModel: userSystemModel);

        await _userSessionService.saveUserSession(user);

        return success(
          RegisterViaQRCodeSuccess(user: user, message: 'Bem-vindo de volta, $userName! Login realizado com sucesso.'),
        );
      } catch (e) {
        // Usuário não existe ou senha incorreta - verificar qual caso
        final errorMessage = e.toString().toLowerCase();

        if (errorMessage.contains('senha') || errorMessage.contains('password')) {
          // Usuário existe mas senha está incorreta
          return failure(RegisterViaQRCodeFailure.wrongPassword());
        }

        // Usuário não existe - criar novo cadastro
        // 3. Criar cadastro local do usuário com CodUsuario do QR Code
        final createResponse = await _userRepository.createUser(
          nome: userName,
          senha: qrData.senhaUsuario,
          profileImage: null,
          codUsuario: qrData.codUsuario,
        );

        // 4. Converter dados do QR Code para UserSystemModel
        final userSystemModel = qrData.toUserSystemModel();

        // 5. Criar AppUser com os dados do sistema
        final user = AppUser(
          codLoginApp: createResponse.codLoginApp,
          ativo: Situation.fromCodeWithFallback(createResponse.ativo),
          nome: createResponse.nome,
          codUsuario: qrData.codUsuario,
          userSystemModel: userSystemModel,
        );

        // 6. Salvar sessão do usuário
        await _userSessionService.saveUserSession(user);

        // 7. Retornar sucesso
        return success(
          RegisterViaQRCodeSuccess(user: user, message: 'Bem-vindo, $userName! Cadastro realizado via Login System.'),
        );
      }
    } catch (e) {
      return failure(RegisterViaQRCodeFailure.registrationFailed('Erro inesperado: ${e.toString()}'));
    }
  }
}
