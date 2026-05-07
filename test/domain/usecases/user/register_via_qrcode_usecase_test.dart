import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/system_qrcode_data.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/usecases/user/register_via_qrcode_usecase.dart';

import 'register_via_qrcode_usecase_test.mocks.dart';

@GenerateMocks([UserRepository, UserSystemRepository, UserSessionService])
void main() {
  group('RegisterViaQRCodeUseCase', () {
    late RegisterViaQRCodeUseCase useCase;
    late MockUserRepository mockUserRepository;
    late MockUserSystemRepository mockUserSystemRepository;
    late MockUserSessionService mockUserSessionService;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockUserSystemRepository = MockUserSystemRepository();
      mockUserSessionService = MockUserSessionService();

      useCase = RegisterViaQRCodeUseCase(
        userRepository: mockUserRepository,
        userSystemRepository: mockUserSystemRepository,
        userSessionService: mockUserSessionService,
      );
    });

    group('Sucesso', () {
      test('deve fazer login quando usuario ja existe e confirmar via /usuarios', () async {
        final qrCodeData = _defaultQrCodeData(nomeUsuario: 'Usuario Existente');
        final loginResponse = LoginResponse(
          message: 'Login realizado',
          user: AppUser(codLoginApp: 789, ativo: Situation.ativo, nome: 'Usuario Existente', codUsuario: 999),
        );
        final authoritativeUser = _userSystemModel(codUsuario: 123, nomeUsuario: 'Usuario Existente');

        when(mockUserRepository.login('Usuario Existente', '1234')).thenAnswer((_) async => loginResponse);
        when(mockUserSystemRepository.getUserById(123)).thenAnswer((_) async => authoritativeUser);
        when(mockUserSessionService.saveUserSession(any)).thenAnswer((_) async {});

        final result = await useCase(RegisterViaQRCodeParams(qrCodeData: qrCodeData));

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.user.codLoginApp, equals(789));
        expect(success.user.nome, equals('Usuario Existente'));
        expect(success.user.codUsuario, equals(123));
        expect(success.user.userSystemModel, equals(authoritativeUser));
        expect(success.message, contains('Bem-vindo de volta'));

        verify(mockUserRepository.login('Usuario Existente', '1234')).called(1);
        verify(mockUserSystemRepository.getUserById(123)).called(1);
        verify(mockUserSessionService.saveUserSession(any)).called(1);
        verifyNever(
          mockUserRepository.createUser(
            nome: anyNamed('nome'),
            senha: anyNamed('senha'),
            profileImage: anyNamed('profileImage'),
            codUsuario: anyNamed('codUsuario'),
          ),
        );
      });

      test('deve registrar usuario quando login retorna 401 e confirmar via /usuarios', () async {
        final qrCodeData = _defaultQrCodeData(nomeUsuario: 'Teste QR');
        final createUserResponse = CreateUserResponse(codLoginApp: 456, ativo: 'S', nome: 'Teste QR');
        final authoritativeUser = _userSystemModel(codUsuario: 123, nomeUsuario: 'Teste QR');

        when(
          mockUserRepository.login('Teste QR', '1234'),
        ).thenThrow(UserApiException('Credenciais invalidas', statusCode: 401));
        when(
          mockUserRepository.createUser(nome: 'Teste QR', senha: '1234', profileImage: null, codUsuario: 123),
        ).thenAnswer((_) async => createUserResponse);
        when(mockUserSystemRepository.getUserById(123)).thenAnswer((_) async => authoritativeUser);
        when(mockUserSessionService.saveUserSession(any)).thenAnswer((_) async {});

        final result = await useCase(RegisterViaQRCodeParams(qrCodeData: qrCodeData));

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.user.codLoginApp, equals(456));
        expect(success.user.codUsuario, equals(123));
        expect(success.user.userSystemModel, equals(authoritativeUser));
        expect(success.message, contains('Cadastro realizado via Login System'));

        verify(mockUserRepository.login('Teste QR', '1234')).called(1);
        verify(
          mockUserRepository.createUser(nome: 'Teste QR', senha: '1234', profileImage: null, codUsuario: 123),
        ).called(1);
        verify(mockUserSystemRepository.getUserById(123)).called(1);
        verify(mockUserSessionService.saveUserSession(any)).called(1);
      });
    });

    group('Falhas', () {
      test('deve falhar quando usuario existe mas senha esta incorreta', () async {
        final qrCodeData = _defaultQrCodeData(nomeUsuario: 'Usuario Existente', senhaUsuario: 'senhaErrada');

        when(
          mockUserRepository.login('Usuario Existente', 'senhaErrada'),
        ).thenThrow(UserApiException('Credenciais invalidas', statusCode: 401));
        when(
          mockUserRepository.createUser(
            nome: 'Usuario Existente',
            senha: 'senhaErrada',
            profileImage: null,
            codUsuario: 123,
          ),
        ).thenThrow(UserApiException('Usuario ja cadastrado', statusCode: 400, isValidationError: true));

        final result = await useCase(RegisterViaQRCodeParams(qrCodeData: qrCodeData));

        final failure = result.exceptionOrNull() as RegisterViaQRCodeFailure?;
        expect(failure, isNotNull);
        expect(failure!.code, equals('WRONG_PASSWORD'));

        verify(mockUserRepository.login('Usuario Existente', 'senhaErrada')).called(1);
        verify(
          mockUserRepository.createUser(
            nome: 'Usuario Existente',
            senha: 'senhaErrada',
            profileImage: null,
            codUsuario: 123,
          ),
        ).called(1);
        verifyNever(mockUserSystemRepository.getUserById(any));
        verifyNever(mockUserSessionService.saveUserSession(any));
      });

      test('deve falhar com networkError quando login falha por motivo nao credencial', () async {
        when(
          mockUserRepository.login('Usuario', '1234'),
        ).thenThrow(UserApiException('Erro interno do servidor', statusCode: 500));

        final result = await useCase(RegisterViaQRCodeParams(qrCodeData: _defaultQrCodeData(nomeUsuario: 'Usuario')));

        final failure = result.exceptionOrNull() as RegisterViaQRCodeFailure?;
        expect(failure, isNotNull);
        expect(failure!.code, equals('NETWORK_ERROR'));

        verifyNever(
          mockUserRepository.createUser(
            nome: anyNamed('nome'),
            senha: anyNamed('senha'),
            profileImage: anyNamed('profileImage'),
            codUsuario: anyNamed('codUsuario'),
          ),
        );
        verifyNever(mockUserSystemRepository.getUserById(any));
        verifyNever(mockUserSessionService.saveUserSession(any));
      });

      test('deve falhar quando QR Code tem dados invalidos', () async {
        final qrCodeData = _defaultQrCodeData(nomeUsuario: '');

        final result = await useCase(RegisterViaQRCodeParams(qrCodeData: qrCodeData));

        final failure = result.exceptionOrNull() as RegisterViaQRCodeFailure?;
        expect(failure, isNotNull);
        expect(failure!.userMessage, contains('Nome de usuario'));

        verifyNever(mockUserRepository.login(any, any));
        verifyNever(mockUserSystemRepository.getUserById(any));
        verifyNever(mockUserSessionService.saveUserSession(any));
      });

      test('deve falhar quando createUser lanca erro 5xx', () async {
        when(
          mockUserRepository.login('Teste QR', '1234'),
        ).thenThrow(UserApiException('Credenciais invalidas', statusCode: 401));
        when(
          mockUserRepository.createUser(nome: 'Teste QR', senha: '1234', profileImage: null, codUsuario: 123),
        ).thenThrow(UserApiException('Erro interno do servidor', statusCode: 500));

        final result = await useCase(RegisterViaQRCodeParams(qrCodeData: _defaultQrCodeData(nomeUsuario: 'Teste QR')));

        final failure = result.exceptionOrNull() as RegisterViaQRCodeFailure?;
        expect(failure, isNotNull);
        expect(failure!.code, equals('REGISTRATION_FAILED'));

        verifyNever(mockUserSystemRepository.getUserById(any));
        verifyNever(mockUserSessionService.saveUserSession(any));
      });

      test('deve falhar quando confirmacao autoritativa retorna null', () async {
        final loginResponse = LoginResponse(
          message: 'Login realizado',
          user: AppUser(codLoginApp: 789, ativo: Situation.ativo, nome: 'Usuario Existente', codUsuario: 999),
        );

        when(mockUserRepository.login('Usuario Existente', '1234')).thenAnswer((_) async => loginResponse);
        when(mockUserSystemRepository.getUserById(123)).thenAnswer((_) async => null);

        final result = await useCase(
          RegisterViaQRCodeParams(qrCodeData: _defaultQrCodeData(nomeUsuario: 'Usuario Existente')),
        );

        final failure = result.exceptionOrNull() as RegisterViaQRCodeFailure?;
        expect(failure, isNotNull);
        expect(failure!.code, equals('USER_CONFIRMATION_FAILED'));
        verifyNever(mockUserSessionService.saveUserSession(any));
      });

      test('deve falhar quando confirmacao autoritativa lanca erro', () async {
        final createUserResponse = CreateUserResponse(codLoginApp: 456, ativo: 'S', nome: 'Teste QR');

        when(
          mockUserRepository.login('Teste QR', '1234'),
        ).thenThrow(UserApiException('Credenciais invalidas', statusCode: 401));
        when(
          mockUserRepository.createUser(nome: 'Teste QR', senha: '1234', profileImage: null, codUsuario: 123),
        ).thenAnswer((_) async => createUserResponse);
        when(
          mockUserSystemRepository.getUserById(123),
        ).thenThrow(UserApiException('Erro ao consultar /usuarios', statusCode: 503));

        final result = await useCase(RegisterViaQRCodeParams(qrCodeData: _defaultQrCodeData(nomeUsuario: 'Teste QR')));

        final failure = result.exceptionOrNull() as RegisterViaQRCodeFailure?;
        expect(failure, isNotNull);
        expect(failure!.code, equals('USER_CONFIRMATION_FAILED'));
        verifyNever(mockUserSessionService.saveUserSession(any));
      });
    });
  });
}

SystemQRCodeData _defaultQrCodeData({
  int codUsuario = 123,
  String nomeUsuario = 'Teste',
  String senhaUsuario = '1234',
  int codEmpresa = 1,
  String nomeEmpresa = 'Empresa Teste',
}) {
  return SystemQRCodeData(
    codUsuario: codUsuario,
    nomeUsuario: nomeUsuario,
    senhaUsuario: senhaUsuario,
    ativo: 'S',
    codEmpresa: codEmpresa,
    nomeEmpresa: nomeEmpresa,
    permiteSepararForaSequencia: 'N',
    visualizaTodasSeparacoes: 'N',
    permiteConferirForaSequencia: 'N',
    visualizaTodasConferencias: 'N',
    permiteArmazenarForaSequencia: 'N',
    visualizaTodasArmazenagem: 'N',
    editaCarrinhoOutroUsuario: 'N',
    salvaCarrinhoOutroUsuario: 'N',
    excluiCarrinhoOutroUsuario: 'N',
    expedicaoEntregaBalcaoPreVenda: 'N',
  );
}

UserSystemModel _userSystemModel({required int codUsuario, required String nomeUsuario, int codEmpresa = 1}) {
  return UserSystemModel(
    codUsuario: codUsuario,
    nomeUsuario: nomeUsuario,
    ativo: Situation.ativo,
    codEmpresa: codEmpresa,
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
