import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:exp/domain/usecases/user/register_via_qrcode_usecase.dart';
import 'package:exp/domain/models/user/system_qrcode_data.dart';
import 'package:exp/domain/models/user/user_models.dart';
import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/domain/models/situation/situation_model.dart';

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

        // Mock login falhando (usuário não existe)
        when(mockUserRepository.login('Teste QR', '1234')).thenThrow(Exception('Usuário não encontrado'));

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

        // Mock login falhando (usuário não existe)
        when(mockUserRepository.login('Admin Sistema', 'admin123')).thenThrow(Exception('Usuário não encontrado'));

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
        // Arrange
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

        // Mock login falhando com erro de senha
        when(mockUserRepository.login('Usuario Existente', 'senhaErrada')).thenThrow(Exception('Senha incorreta'));

        final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((success) => fail('Deveria ter falhado, mas teve sucesso: $success'), (failure) {
          expect(failure, isA<RegisterViaQRCodeFailure>());
          expect((failure as RegisterViaQRCodeFailure).userMessage, contains('senha não confere'));
        });

        // Verificar que login foi chamado
        verify(mockUserRepository.login('Usuario Existente', 'senhaErrada')).called(1);

        // Verificar que createUser NÃO foi chamado
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

      test('deve falhar quando repositório lança exceção durante criação', () async {
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

        // Mock login falhando (usuário não existe)
        when(mockUserRepository.login('Teste QR', '1234')).thenThrow(Exception('Usuário não encontrado'));

        // Mock createUser também falhando
        when(
          mockUserRepository.createUser(nome: 'Teste QR', senha: '1234', profileImage: null, codUsuario: 123),
        ).thenThrow(Exception('Erro de conexão'));

        final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);

        // Act
        final result = await useCase(params);

        // Assert
        result.fold((success) => fail('Deveria ter falhado, mas teve sucesso: $success'), (failure) {
          expect(failure, isA<RegisterViaQRCodeFailure>());
          expect((failure as RegisterViaQRCodeFailure).userMessage, contains('Erro inesperado'));
          expect((failure).userMessage, contains('Erro de conexão'));
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
