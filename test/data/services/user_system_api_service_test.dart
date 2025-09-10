import 'package:flutter_test/flutter_test.dart';
import 'package:exp/data/services/user_system_api_service.dart';
import 'package:exp/data/dtos/user_system_dto.dart';
import 'package:exp/domain/models/user_system_models.dart';
import '../../mocks/user_system_api_mocks.dart';

void main() {
  group('UserSystemApiService Tests', () {
    late UserSystemApiService service;

    setUp(() {
      service = UserSystemApiService();
    });

    group('_processUserListResponse Tests', () {
      test('deve processar resposta com estrutura completa da API', () {
        // Arrange
        final mockApiResponse = UserSystemApiMocks.userListApiResponse;

        // Act
        final result = service.processUserListResponseForTesting(
          mockApiResponse,
        );

        // Assert
        expect(result, isA<UserSystemListResponse>());
        expect(result.success, isTrue);
        expect(result.users, hasLength(2));
        expect(result.total, equals(2));
        expect(result.page, equals(1));
        expect(result.limit, equals(100));
        expect(result.totalPages, equals(1));
        expect(result.message, equals("2 usuário(s) encontrado(s)"));

        // Verificar primeiro usuário
        final firstUser = result.users[0];
        expect(firstUser.codUsuario, equals(1));
        expect(firstUser.nomeUsuario, equals("Administrador"));
        expect(firstUser.ativo, isTrue);
        expect(firstUser.codEmpresa, equals(1));
        expect(firstUser.permiteSepararForaSequencia, isTrue);

        // Verificar segundo usuário
        final secondUser = result.users[1];
        expect(secondUser.codUsuario, equals(35));
        expect(secondUser.nomeUsuario, equals("Administradores"));
        expect(secondUser.ativo, isTrue);
        expect(secondUser.codEmpresa, isNull); // Campo não presente na API
        expect(secondUser.permiteSepararForaSequencia, isFalse);
      });

      test('deve processar resposta de usuário único', () {
        // Arrange
        final mockSingleUserResponse = UserSystemApiMocks.singleUserApiResponse;

        // Act
        final result = service.processUserListResponseForTesting(
          mockSingleUserResponse,
        );

        // Assert
        expect(result, isA<UserSystemListResponse>());
        expect(result.success, isTrue);
        expect(result.users, hasLength(1));
        expect(result.message, equals('Usuário encontrado'));

        final user = result.users[0];
        expect(user.codUsuario, equals(1));
        expect(user.nomeUsuario, equals("Administrador"));
        expect(user.ativo, isTrue);
      });

      test('deve processar lista direta (sem metadados)', () {
        // Arrange
        final mockDirectListResponse = UserSystemApiMocks.directListApiResponse;

        // Act
        final result = service.processUserListResponseForTesting(
          mockDirectListResponse,
        );

        // Assert
        expect(result, isA<UserSystemListResponse>());
        expect(result.success, isTrue);
        expect(result.users, hasLength(2));
        expect(result.message, equals('Lista de usuários obtida com sucesso'));

        final firstUser = result.users[0];
        expect(firstUser.codUsuario, equals(1));
        expect(firstUser.nomeUsuario, equals("Usuario 1"));
        expect(firstUser.ativo, isTrue);

        final secondUser = result.users[1];
        expect(secondUser.codUsuario, equals(2));
        expect(secondUser.nomeUsuario, equals("Usuario 2"));
        expect(secondUser.ativo, isFalse);
      });

      test('deve lançar exceção para formato inválido', () {
        // Arrange
        final invalidResponse = "string inválida";

        // Act & Assert
        expect(
          () => service.processUserListResponseForTesting(invalidResponse),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('UserSystemDto Tests', () {
      test('deve criar DTO a partir de JSON da API', () {
        // Arrange
        final json = UserSystemApiMocks.singleUserApiResponse;

        // Act
        final dto = UserSystemDto.fromApiResponse(json);

        // Assert
        expect(dto.codEmpresa, equals(1));
        expect(dto.codUsuario, equals(1));
        expect(dto.nomeUsuario, equals("Administrador"));
        expect(dto.ativo, equals("S"));
        expect(dto.isAtivo, isTrue);
        expect(dto.canSepararForaSequencia, isTrue);
      });

      test('deve lidar com campos opcionais ausentes', () {
        // Arrange
        final json = UserSystemApiMocks.basicUserApiResponse;

        // Act
        final dto = UserSystemDto.fromApiResponse(json);

        // Assert
        expect(dto.codEmpresa, isNull);
        expect(dto.codUsuario, equals(35));
        expect(dto.nomeUsuario, equals("Usuario Basico"));
        expect(dto.ativo, equals("S"));
        expect(dto.codContaFinanceira, isNull);
        expect(dto.isAtivo, isTrue);
        expect(dto.canSepararForaSequencia, isFalse);
      });

      test('deve converter para domínio corretamente', () {
        // Arrange
        final dto = UserSystemDto(
          codEmpresa: 1,
          codUsuario: 1,
          nomeUsuario: "Teste",
          ativo: "S",
          codContaFinanceira: "CXG",
          nomeContaFinanceira: "CAIXA",
          nomeCaixaOperador: "OPERADOR",
          permiteSepararForaSequencia: "S",
          visualizaTodasSeparacoes: "N",
          permiteConferirForaSequencia: "S",
          visualizaTodasConferencias: "N",
          salvaCarrinhoOutroUsuario: "S",
          editaCarrinhoOutroUsuario: "N",
          excluiCarrinhoOutroUsuario: "S",
        );

        // Act
        final domain = dto.toDomain();

        // Assert
        expect(domain['codEmpresa'], equals(1));
        expect(domain['codUsuario'], equals(1));
        expect(domain['nomeUsuario'], equals("Teste"));
        expect(domain['ativo'], isTrue); // Convertido de "S" para true
        expect(domain['permiteSepararForaSequencia'], isTrue);
        expect(domain['visualizaTodasSeparacoes'], isFalse);
      });
    });

    group('UserSystemData Tests', () {
      test('deve criar modelo de domínio a partir de mapa', () {
        // Arrange
        final map = {
          'codEmpresa': 1,
          'codUsuario': 1,
          'nomeUsuario': 'Teste',
          'ativo': true,
          'codContaFinanceira': 'CXG',
          'nomeContaFinanceira': 'CAIXA',
          'nomeCaixaOperador': 'OPERADOR',
          'permiteSepararForaSequencia': true,
          'visualizaTodasSeparacoes': false,
          'permiteConferirForaSequencia': true,
          'visualizaTodasConferencias': false,
          'salvaCarrinhoOutroUsuario': true,
          'editaCarrinhoOutroUsuario': false,
          'excluiCarrinhoOutroUsuario': true,
        };

        // Act
        final userData = UserSystemData.fromMap(map);

        // Assert
        expect(userData.codEmpresa, equals(1));
        expect(userData.codUsuario, equals(1));
        expect(userData.nomeUsuario, equals('Teste'));
        expect(userData.ativo, isTrue);
        expect(userData.hasBasicPermissions, isTrue);
        expect(userData.canWorkWithSeparations, isTrue);
        expect(userData.canWorkWithConferences, isTrue);
        expect(userData.canManageOtherCarts, isTrue);
      });

      test('deve lidar com campos opcionais nulos', () {
        // Arrange
        final map = {
          'codEmpresa': null,
          'codUsuario': 35,
          'nomeUsuario': 'Teste',
          'ativo': true,
          'codContaFinanceira': null,
          'nomeContaFinanceira': null,
          'nomeCaixaOperador': null,
          'permiteSepararForaSequencia': false,
          'visualizaTodasSeparacoes': false,
          'permiteConferirForaSequencia': false,
          'visualizaTodasConferencias': false,
          'salvaCarrinhoOutroUsuario': false,
          'editaCarrinhoOutroUsuario': false,
          'excluiCarrinhoOutroUsuario': false,
        };

        // Act
        final userData = UserSystemData.fromMap(map);

        // Assert
        expect(userData.codEmpresa, isNull);
        expect(userData.codUsuario, equals(35));
        expect(userData.nomeUsuario, equals('Teste'));
        expect(userData.ativo, isTrue);
        expect(userData.hasBasicPermissions, isFalse); // Sem conta financeira
        expect(userData.canWorkWithSeparations, isFalse);
        expect(userData.canWorkWithConferences, isFalse);
        expect(userData.canManageOtherCarts, isFalse);
      });
    });
  });
}
