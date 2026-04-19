import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:data7_expedicao/domain/usecases/user/register_via_qrcode_usecase.dart';
import 'package:data7_expedicao/domain/models/user/system_qrcode_data.dart';
import 'package:data7_expedicao/domain/models/user/user_api_exception.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

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
      test('deve fazer login quando usuário já existe com senha correta', () async {
        // Arrange
        const qrCodeData = SystemQRCodeData(
          codUsuario: 123,
          nomeUsuario: 'Usuario Existente',
          senhaUsuario: '1234',
          ativo: 'S',
          codEmpresa: 1,
          nomeEmpresa: 'Empresa Teste',
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

        final existingUser = AppUser(
          codLoginApp: 789,
          ativo: Situation.ativo,
          nome: 'Usuario Existente',
          codUsuario: 100,
        );

        final loginResponse = LoginResponse(message: 'Login realizado', user: existingUser);

        // Mock login bem-sucedido
        when(mockUserRepository.login('Usuario Existente', '1234')).thenAnswer((_) async => loginResponse);

        when(mockUserSessionService.saveUserSession(any)).thenAnswer((_) async {});

        final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((success) {
          expect(success.user.codLoginApp, equals(789));
          expect(success.user.nome, equals('Usuario Existente'));
          expect(success.user.codUsuario, equals(123)); // Atualizado do QR Code
          expect(success.message, contains('Bem-vindo de volta'));
        }, (failure) => fail('Deveria ter sucesso, mas falhou: $failure'));

        // Verificar que login foi chamado
        verify(mockUserRepository.login('Usuario Existente', '1234')).called(1);

        // Verificar que createUser NÃO foi chamado
        verifyNever(
          mockUserRepository.createUser(
            nome: anyNamed('nome'),
            senha: anyNamed('senha'),
            profileImage: anyNamed('profileImage'),
            codUsuario: anyNamed('codUsuario'),
          ),
        );

        // Verificar se a sessão foi salva
        verify(mockUserSessionService.saveUserSession(any)).called(1);
      });

      test('deve registrar usuário com CodUsuario do QR Code quando não existe', () async {
        // Arrange
        const qrCodeData = SystemQRCodeData(
          codUsuario: 123,
          nomeUsuario: 'Teste QR',
          senhaUsuario: '1234',
          ativo: 'S',
          codEmpresa: 1,
          nomeEmpresa: 'Empresa Teste',
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

        final createUserResponse = CreateUserResponse(codLoginApp: 456, ativo: 'S', nome: 'Teste QR');

        // Mock login falhando com 401 (Bug N: usar statusCode em vez de string match)
        when(mockUserRepository.login('Teste QR', '1234'))
            .thenThrow(UserApiException('Credenciais inválidas', statusCode: 401));

        when(
          mockUserRepository.createUser(
            nome: 'Teste QR',
            senha: '1234',
            profileImage: null,
            codUsuario: 123, // ← Aqui está o ponto crucial!
          ),
        ).thenAnswer((_) async => createUserResponse);

        when(mockUserSessionService.saveUserSession(any)).thenAnswer((_) async {});

        final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((success) {
          expect(success.user.codUsuario, equals(123));
          expect(success.user.nome, equals('Teste QR'));
          expect(success.user.codLoginApp, equals(456));
          expect(success.message, contains('Teste QR'));
        }, (failure) => fail('Deveria ter sucesso, mas falhou: $failure'));

        // Verificar se o createUser foi chamado com CodUsuario
        verify(
          mockUserRepository.createUser(
            nome: 'Teste QR',
            senha: '1234',
            profileImage: null,
            codUsuario: 123, // ← Verificar se foi passado corretamente
          ),
        ).called(1);

        // Verificar se a sessão foi salva
        verify(mockUserSessionService.saveUserSession(any)).called(1);
      });

      test('deve processar QR Code com todos os campos opcionais', () async {
        // Arrange
        const qrCodeData = SystemQRCodeData(
          codUsuario: 999,
          nomeUsuario: 'Admin Sistema',
          senhaUsuario: 'admin123',
          ativo: 'S',
          codEmpresa: 2,
          nomeEmpresa: 'Empresa Admin',
          codVendedor: 100,
          nomeVendedor: 'Vendedor Teste',
          codLocalArmazenagem: 50,
          nomeLocalArmazenagem: 'Local A',
          codContaFinanceira: 'CONTA001',
          nomeContaFinanceira: 'Conta Principal',
          nomeCaixaOperador: 'Caixa 1',
          codSetorEstoque: 10,
          nomeSetorEstoque: 'Setor Principal',
          permiteSepararForaSequencia: 'S',
          visualizaTodasSeparacoes: 'S',
          codSetorConferencia: 20,
          nomeSetorConferencia: 'Setor Conferência',
          permiteConferirForaSequencia: 'S',
          visualizaTodasConferencias: 'S',
          codSetorArmazenagem: 30,
          nomeSetorArmazenagem: 'Setor Armazenagem',
          permiteArmazenarForaSequencia: 'S',
          visualizaTodasArmazenagem: 'S',
          editaCarrinhoOutroUsuario: 'S',
          salvaCarrinhoOutroUsuario: 'S',
          excluiCarrinhoOutroUsuario: 'S',
          expedicaoEntregaBalcaoPreVenda: 'S',
        );

        final createUserResponse = CreateUserResponse(codLoginApp: 789, ativo: 'S', nome: 'Admin Sistema');

        // Mock login falhando com 401 (Bug N: usar statusCode)
        when(mockUserRepository.login('Admin Sistema', 'admin123'))
            .thenThrow(UserApiException('Credenciais inválidas', statusCode: 401));

        when(
          mockUserRepository.createUser(nome: 'Admin Sistema', senha: 'admin123', profileImage: null, codUsuario: 999),
        ).thenAnswer((_) async => createUserResponse);

        when(mockUserSessionService.saveUserSession(any)).thenAnswer((_) async {});

        final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((success) {
          expect(success.user.codUsuario, equals(999));
          expect(success.user.nome, equals('Admin Sistema'));
          expect(success.user.userSystemModel?.codVendedor, equals(100));
          expect(success.user.userSystemModel?.nomeVendedor, equals('Vendedor Teste'));
          expect(success.user.userSystemModel?.codLocalArmazenagem, equals(50));
          expect(success.user.userSystemModel?.permiteSepararForaSequencia, equals(Situation.ativo));
        }, (failure) => fail('Deveria ter sucesso, mas falhou: $failure'));
      });
    });

    group('Falhas', () {
      test('deve falhar quando usuário existe mas senha está incorreta', () async {
        // Bug N corrigido: agora detectamos via statusCode em vez de string.
        // Login retorna 401 + createUser retorna 400 (validacao = ja existe)
        // → wrongPassword. Servidor nao revela "senha errada" no login por
        // seguranca (sempre retorna 401), entao a deteccao acontece no
        // momento de tentar criar.
        const qrCodeData = SystemQRCodeData(
          codUsuario: 123,
          nomeUsuario: 'Usuario Existente',
          senhaUsuario: 'senhaErrada',
          ativo: 'S',
          codEmpresa: 1,
          nomeEmpresa: 'Empresa Teste',
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

        // Mock login retornando 401 (credenciais inválidas)
        when(mockUserRepository.login('Usuario Existente', 'senhaErrada'))
            .thenThrow(UserApiException('Credenciais inválidas', statusCode: 401));

        // Mock createUser retornando 400 (usuário já existe — validação)
        when(
          mockUserRepository.createUser(
            nome: 'Usuario Existente',
            senha: 'senhaErrada',
            profileImage: null,
            codUsuario: 123,
          ),
        ).thenThrow(UserApiException('Usuário já cadastrado', statusCode: 400, isValidationError: true));

        final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((success) => fail('Deveria ter falhado, mas teve sucesso: $success'), (failure) {
          expect(failure, isA<RegisterViaQRCodeFailure>());
          expect((failure as RegisterViaQRCodeFailure).userMessage, contains('senha não confere'));
        });

        // Verificar que ambos foram chamados
        verify(mockUserRepository.login('Usuario Existente', 'senhaErrada')).called(1);
        verify(
          mockUserRepository.createUser(
            nome: 'Usuario Existente',
            senha: 'senhaErrada',
            profileImage: null,
            codUsuario: 123,
          ),
        ).called(1);
      });

      test('deve falhar com networkError quando login falha por motivo nao-credencial (Bug N)', () async {
        // Antes do Bug N: erros de rede (status != 401) caiam silenciosamente
        // no fluxo de createUser, gerando mensagem confusa.
        // Agora: detectamos statusCode != 401 e retornamos networkError sem
        // tentar criar usuario.
        const qrCodeData = SystemQRCodeData(
          codUsuario: 123,
          nomeUsuario: 'Usuario',
          senhaUsuario: '1234',
          ativo: 'S',
          codEmpresa: 1,
          nomeEmpresa: 'Empresa Teste',
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

        when(mockUserRepository.login(any, any))
            .thenThrow(UserApiException('Erro interno do servidor', statusCode: 500));

        final result = await useCase(RegisterViaQRCodeParams(qrCodeData: qrCodeData));

        result.fold((success) => fail('Deveria ter falhado, mas teve sucesso: $success'), (failure) {
          expect(failure, isA<RegisterViaQRCodeFailure>());
          expect((failure as RegisterViaQRCodeFailure).code, equals('NETWORK_ERROR'));
        });

        // Crucial: createUser NAO eh chamado quando o erro nao eh 401
        verifyNever(
          mockUserRepository.createUser(
            nome: anyNamed('nome'),
            senha: anyNamed('senha'),
            profileImage: anyNamed('profileImage'),
            codUsuario: anyNamed('codUsuario'),
          ),
        );
      });

      test('deve falhar quando QR Code tem dados inválidos', () async {
        // Arrange
        const qrCodeData = SystemQRCodeData(
          codUsuario: 123,
          nomeUsuario: '', // ← Nome vazio
          senhaUsuario: '1234',
          ativo: 'S',
          codEmpresa: 1,
          nomeEmpresa: 'Empresa Teste',
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

        final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((success) => fail('Deveria ter falhado, mas teve sucesso: $success'), (failure) {
          expect(failure, isA<RegisterViaQRCodeFailure>());
          expect((failure as RegisterViaQRCodeFailure).userMessage, contains('Nome de usuário é obrigatório'));
        });

        // Verificar que não foi chamado o createUser
        verifyNever(
          mockUserRepository.createUser(
            nome: anyNamed('nome'),
            senha: anyNamed('senha'),
            profileImage: anyNamed('profileImage'),
            codUsuario: anyNamed('codUsuario'),
          ),
        );
      });

      test('deve falhar quando createUser lanca erro 5xx (servidor)', () async {
        // Login retorna 401 → tenta criar → createUser falha com 5xx
        // (servidor) → retorna registrationFailed (nao wrongPassword
        // porque statusCode != 400).
        const qrCodeData = SystemQRCodeData(
          codUsuario: 123,
          nomeUsuario: 'Teste QR',
          senhaUsuario: '1234',
          ativo: 'S',
          codEmpresa: 1,
          nomeEmpresa: 'Empresa Teste',
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

        when(mockUserRepository.login('Teste QR', '1234'))
            .thenThrow(UserApiException('Credenciais inválidas', statusCode: 401));

        when(
          mockUserRepository.createUser(nome: 'Teste QR', senha: '1234', profileImage: null, codUsuario: 123),
        ).thenThrow(UserApiException('Erro interno do servidor', statusCode: 500));

        final result = await useCase(RegisterViaQRCodeParams(qrCodeData: qrCodeData));

        result.fold((success) => fail('Deveria ter falhado, mas teve sucesso: $success'), (failure) {
          expect(failure, isA<RegisterViaQRCodeFailure>());
          expect((failure as RegisterViaQRCodeFailure).code, equals('REGISTRATION_FAILED'));
          expect(failure.userMessage, contains('Erro interno do servidor'));
        });
      });
    });

    group('Validação de Parâmetros', () {
      test('deve validar se QRCodeData contém CodUsuario', () {
        // Arrange
        const qrCodeData = SystemQRCodeData(
          codUsuario: 123,
          nomeUsuario: 'Teste',
          senhaUsuario: '1234',
          ativo: 'S',
          codEmpresa: 1,
          nomeEmpresa: 'Empresa',
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

        final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);

        // Assert
        expect(params.isValid, isTrue);
        expect(params.validationErrors, isEmpty);
        expect(qrCodeData.codUsuario, equals(123));
      });
    });
  });
}
