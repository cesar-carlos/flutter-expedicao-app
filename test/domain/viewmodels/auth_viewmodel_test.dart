import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/data/dtos/user_system_list_response_dto.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/user/login_user_usecase.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';

void main() {
  group('AuthViewModel.checkAuthStatus', () {
    test('mantem autenticado quando sessao completa falha no refresh', () async {
      final existingSystemUser = _userSystemModel(codUsuario: 1, nomeUsuario: 'Maria');
      final sessionService = _FakeUserSessionService(
        session: AppUser(
          codLoginApp: 10,
          ativo: Situation.ativo,
          nome: 'Maria',
          codUsuario: 1,
          userSystemModel: existingSystemUser,
        ),
      );
      final repository = _FakeUserSystemRepository(error: UserApiException('offline', statusCode: 503));
      final viewModel = AuthViewModel(
        loginUserUseCase: LoginUserUseCase(_FakeUserRepository()),
        userSessionService: sessionService,
        userSystemRepository: repository,
      );

      await viewModel.checkAuthStatus();

      expect(viewModel.status, equals(AuthStatus.authenticated));
      expect(viewModel.currentUser?.userSystemModel, equals(existingSystemUser));
      expect(sessionService.clearCount, equals(0));
      expect(sessionService.savedSessions, isEmpty);
    });

    test('nao autentica quando sessao incompleta falha no carregamento autoritativo', () async {
      final sessionService = _FakeUserSessionService(
        session: AppUser(codLoginApp: 10, ativo: Situation.ativo, nome: 'Maria', codUsuario: 1),
      );
      final repository = _FakeUserSystemRepository(error: UserApiException('offline', statusCode: 503));
      final viewModel = AuthViewModel(
        loginUserUseCase: LoginUserUseCase(_FakeUserRepository()),
        userSessionService: sessionService,
        userSystemRepository: repository,
      );

      await viewModel.checkAuthStatus();

      expect(viewModel.status, equals(AuthStatus.unauthenticated));
      expect(viewModel.currentUser, isNull);
      expect(viewModel.username, isEmpty);
      expect(sessionService.clearCount, equals(1));
      expect(sessionService.savedSessions, isEmpty);
    });

    test('autentica e regrava sessao quando sessao incompleta carrega dados autoritativos', () async {
      final authoritativeUser = _userSystemModel(codUsuario: 1, nomeUsuario: 'Maria');
      final sessionService = _FakeUserSessionService(
        session: AppUser(codLoginApp: 10, ativo: Situation.ativo, nome: 'Maria', codUsuario: 1),
      );
      final repository = _FakeUserSystemRepository(user: authoritativeUser);
      final viewModel = AuthViewModel(
        loginUserUseCase: LoginUserUseCase(_FakeUserRepository()),
        userSessionService: sessionService,
        userSystemRepository: repository,
      );

      await viewModel.checkAuthStatus();

      expect(viewModel.status, equals(AuthStatus.authenticated));
      expect(viewModel.currentUser?.userSystemModel, equals(authoritativeUser));
      expect(sessionService.clearCount, equals(0));
      expect(sessionService.savedSessions, hasLength(1));
      expect(sessionService.savedSessions.single.userSystemModel, equals(authoritativeUser));
    });

    test('mantem needsUserSelection quando a sessao salva ainda nao tem codUsuario', () async {
      final sessionService = _FakeUserSessionService(
        session: AppUser(codLoginApp: 10, ativo: Situation.ativo, nome: 'Maria'),
      );
      final repository = _FakeUserSystemRepository(user: _userSystemModel(codUsuario: 1, nomeUsuario: 'Maria'));
      final viewModel = AuthViewModel(
        loginUserUseCase: LoginUserUseCase(_FakeUserRepository()),
        userSessionService: sessionService,
        userSystemRepository: repository,
      );

      await viewModel.checkAuthStatus();

      expect(viewModel.status, equals(AuthStatus.needsUserSelection));
      expect(viewModel.currentUser?.codUsuario, isNull);
      expect(sessionService.savedSessions, isEmpty);
      expect(sessionService.clearCount, equals(0));
    });
  });
}

class _FakeUserSessionService implements IUserSessionService {
  _FakeUserSessionService({this.session});

  AppUser? session;
  final List<AppUser> savedSessions = <AppUser>[];
  int clearCount = 0;

  @override
  Future<void> clearUserSession() async {
    clearCount++;
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
    savedSessions.add(appUser);
    session = appUser;
  }

  @override
  Future<void> updateUserSession(AppUser appUser) async {
    session = appUser;
  }
}

class _FakeUserSystemRepository implements UserSystemRepository {
  _FakeUserSystemRepository({this.user, this.error});

  final UserSystemModel? user;
  final Object? error;

  @override
  Future<UserSystemModel?> getUserById(int codUsuario) async {
    if (error != null) {
      throw error!;
    }
    return user;
  }

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
