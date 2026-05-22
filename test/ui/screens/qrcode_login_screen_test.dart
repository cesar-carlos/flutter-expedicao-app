import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/constants/scan_failure_codes.dart';
import 'package:data7_expedicao/data/dtos/user_system_list_response_dto.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/domain/usecases/user/login_user_usecase.dart';
import 'package:data7_expedicao/domain/usecases/user/register_via_qrcode_usecase.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/l10n/app_localizations.dart';
import 'package:data7_expedicao/ui/screens/qrcode_login_screen.dart';
import 'package:data7_expedicao/ui/services/camera_barcode_scan_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QRCodeLoginScreen', () {
    late _FakeCameraBarcodeScanService scanService;
    late _FakeRegisterViaQRCodeUseCase registerUseCase;
    late _FakeUserSessionService sessionService;
    late _FakeUserSystemRepository userSystemRepository;
    late AuthViewModel authViewModel;

    setUp(() {
      scanService = _FakeCameraBarcodeScanService();
      registerUseCase = _FakeRegisterViaQRCodeUseCase();
      sessionService = _FakeUserSessionService();
      userSystemRepository = _FakeUserSystemRepository();
      authViewModel = AuthViewModel(
        loginUserUseCase: LoginUserUseCase(_FakeUserRepository()),
        userSessionService: sessionService,
        userSystemRepository: userSystemRepository,
      );
    });

    testWidgets('should show loading indicator while scan is in progress', (tester) async {
      final completer = Completer<Result<String>>();
      scanService.nextResultBuilder = () => completer.future;

      await tester.pumpWidget(_buildScreen(authViewModel, scanService, registerUseCase));

      await tester.tap(find.text('Escanear QR Code'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(scanService.callCount, equals(1));

      completer.complete(
        Failure(DataFailure(message: 'Scan cancelado pelo usuario', code: ScanFailureCodes.cancelled)),
      );
      await tester.pump();
    });

    testWidgets('should show confirmation failure with retry actions and rescan on retry', (tester) async {
      scanService.nextResult = Success(_validQrJson);
      registerUseCase.nextResult = Failure(RegisterViaQRCodeFailure.userConfirmationFailed());

      await tester.pumpWidget(_buildScreen(authViewModel, scanService, registerUseCase));

      await tester.tap(find.text('Escanear QR Code'));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Nao foi possivel confirmar o usuario no sistema apos o login. Tente novamente.'),
        findsOneWidget,
      );
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(find.text('Voltar ao login'), findsOneWidget);
      expect(scanService.callCount, equals(1));

      scanService.nextResult = Success(_validQrJson);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      expect(scanService.callCount, equals(2));
    });

    testWidgets('should map permission denied scan failure by code', (tester) async {
      scanService.nextResult = Failure(
        DataFailure(message: 'raw permission message', code: ScanFailureCodes.permissionDenied),
      );

      await tester.pumpWidget(_buildScreen(authViewModel, scanService, registerUseCase));

      await tester.tap(find.text('Escanear QR Code'));
      await tester.pump();

      expect(find.text('Permissão de câmera negada. Libere o acesso à câmera e tente novamente.'), findsOneWidget);
      expect(find.textContaining('raw permission message'), findsNothing);
    });

    testWidgets('should refresh auth status after successful registration', (tester) async {
      final authoritativeUser = _userSystemModel(codUsuario: 123, nomeUsuario: 'Maria');
      final confirmedUser = AppUser(
        codLoginApp: 99,
        ativo: Situation.ativo,
        nome: 'Maria',
        codUsuario: 123,
        userSystemModel: authoritativeUser,
      );

      userSystemRepository.user = authoritativeUser;
      scanService.nextResult = Success(_validQrJson);
      registerUseCase.nextResultBuilder = () async {
        await sessionService.saveUserSession(confirmedUser);
        return Success(RegisterViaQRCodeSuccess(user: confirmedUser, message: 'Cadastro realizado com sucesso'));
      };

      await tester.pumpWidget(_buildScreen(authViewModel, scanService, registerUseCase));

      await tester.tap(find.text('Escanear QR Code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(authViewModel.status, equals(AuthStatus.authenticated));
      expect(authViewModel.currentUser?.userSystemModel, equals(authoritativeUser));
      expect(find.text('Cadastro realizado com sucesso'), findsOneWidget);
    });
  });
}

Widget _buildScreen(
  AuthViewModel authViewModel,
  CameraBarcodeScanService scanService,
  RegisterViaQRCodeUseCase registerUseCase,
) {
  return MaterialApp(
    locale: const Locale('pt', 'BR'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ChangeNotifierProvider<AuthViewModel>.value(
      value: authViewModel,
      child: QRCodeLoginScreen(scanService: scanService, registerViaQRCodeUseCase: registerUseCase),
    ),
  );
}

const String _validQrJson =
    '{"CodUsuario":123,"NomeUsuario":"Maria","SenhaUsuario":"1234","CodEmpresa":1,"NomeEmpresa":"Empresa Teste"}';

class _FakeCameraBarcodeScanService extends CameraBarcodeScanService {
  Result<String>? nextResult;
  Future<Result<String>> Function()? nextResultBuilder;
  int callCount = 0;

  @override
  Future<Result<String>> scan(BuildContext context) async {
    callCount++;
    final builder = nextResultBuilder;
    if (builder != null) {
      return builder();
    }
    return nextResult ?? Failure(DataFailure(message: 'Scan cancelado pelo usuario', code: ScanFailureCodes.cancelled));
  }
}

class _FakeRegisterViaQRCodeUseCase extends RegisterViaQRCodeUseCase {
  _FakeRegisterViaQRCodeUseCase()
    : super(
        userRepository: _FakeUserRepository(),
        userSystemRepository: _FakeUserSystemRepository(),
        userSessionService: _FakeUserSessionService(),
      );

  Result<RegisterViaQRCodeSuccess>? nextResult;
  Future<Result<RegisterViaQRCodeSuccess>> Function()? nextResultBuilder;

  @override
  Future<Result<RegisterViaQRCodeSuccess>> call(RegisterViaQRCodeParams params) async {
    final builder = nextResultBuilder;
    if (builder != null) {
      return builder();
    }
    return nextResult ?? Failure(const RegisterViaQRCodeFailure(message: 'Falha nao configurada'));
  }
}

class _FakeUserSessionService implements IUserSessionService {
  AppUser? session;

  @override
  Future<void> clearUserSession() async {
    session = null;
  }

  @override
  Future<bool> hasActiveSession() async => session != null;

  @override
  Future<bool> isUserLoggedIn() async => session != null;

  @override
  Future<AppUser?> loadUserSession() async => session;

  @override
  Future<void> saveUserSession(AppUser appUser) async {
    session = appUser;
  }

  @override
  Future<void> updateUserSession(AppUser appUser) async {
    session = appUser;
  }
}

class _FakeUserSystemRepository implements UserSystemRepository {
  UserSystemModel? user;

  @override
  Future<UserSystemModel?> getUserById(int codUsuario) async => user;

  @override
  Future<UserSystemListResponseDto> getUsers({int? codEmpresa, Situation? apenasAtivos, Pagination? pagination}) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getUserSystemInfo(int codUsuario) {
    throw UnimplementedError();
  }

  @override
  Future<UserSystemListResponseDto> searchUsersByName(
    String nome, {
    int? codEmpresa,
    Situation apenasAtivos = Situation.ativo,
    Pagination? pagination,
  }) {
    throw UnimplementedError();
  }
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<bool> changePassword({required String nome, required String currentPassword, required String newPassword}) {
    throw UnimplementedError();
  }

  @override
  Future<CreateUserResponse> createUser({
    required String nome,
    required String senha,
    File? profileImage,
    int? codUsuario,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppUserConsultation> getAppUser(int codLoginApp) {
    throw UnimplementedError();
  }

  @override
  Future<LoginResponse> login(String nome, String senha) {
    throw UnimplementedError();
  }

  @override
  Future<AppUserConsultation> putAppUser(AppUser appUser) {
    throw UnimplementedError();
  }

  @override
  Future<bool> validateCurrentPassword({required String nome, required String currentPassword}) {
    throw UnimplementedError();
  }
}

UserSystemModel _userSystemModel({required int codUsuario, required String nomeUsuario}) {
  return UserSystemModel(
    codUsuario: codUsuario,
    nomeUsuario: nomeUsuario,
    ativo: Situation.ativo,
    codEmpresa: 1,
    nomeEmpresa: 'Empresa Teste',
    codContaFinanceira: 'CONTA001',
    nomeContaFinanceira: 'Conta Teste',
    nomeCaixaOperador: 'Caixa Teste',
    codSetorEstoque: 10,
    nomeSetorEstoque: 'Setor Principal',
    permiteSepararForaSequencia: Situation.ativo,
    visualizaTodasSeparacoes: Situation.ativo,
    expedicaoObrigaEscanearPrateleira: Situation.inativo,
    permiteConferirForaSequencia: Situation.inativo,
    visualizaTodasConferencias: Situation.inativo,
    permiteArmazenarForaSequencia: Situation.inativo,
    visualizaTodasArmazenagem: Situation.inativo,
    editaCarrinhoOutroUsuario: Situation.inativo,
    salvaCarrinhoOutroUsuario: Situation.inativo,
    excluiCarrinhoOutroUsuario: Situation.inativo,
    expedicaoEntregaBalcaoPreVenda: Situation.inativo,
  );
}
