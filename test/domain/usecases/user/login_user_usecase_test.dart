import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/usecases/user/login_user_usecase.dart';

void main() {
  group('LoginUserUseCase', () {
    LoginResponse activeResponse() {
      return LoginResponse(
        message: 'ok',
        user: AppUser(codLoginApp: 1, ativo: Situation.ativo, nome: 'Maria', codUsuario: 10),
      );
    }

    test('lanca UserApiException quando nome vazio apos trim', () async {
      final uc = LoginUserUseCase(_StubRepo(loginResult: activeResponse()));

      await expectLater(
        uc.call(LoginUserParams(nome: '   ', senha: '1234')),
        throwsA(isA<UserApiException>().having((e) => e.isValidationError, 'validation', isTrue)),
      );
    });

    test('lanca UserApiException quando senha curta', () async {
      final uc = LoginUserUseCase(_StubRepo(loginResult: activeResponse()));

      await expectLater(uc.call(LoginUserParams(nome: 'user', senha: '123')), throwsA(isA<UserApiException>()));
    });

    test('retorna LoginResponse quando credenciais ok e usuario ativo', () async {
      final expected = activeResponse();
      final uc = LoginUserUseCase(_StubRepo(loginResult: expected));

      final result = await uc.call(LoginUserParams(nome: '  Maria  ', senha: '1234'));

      expect(result.user.nome, 'Maria');
      expect(result.message, 'ok');
    });

    test('lanca quando usuario inativo', () async {
      final inactive = LoginResponse(
        message: 'ok',
        user: AppUser(codLoginApp: 1, ativo: Situation.inativo, nome: 'X', codUsuario: 1),
      );
      final uc = LoginUserUseCase(_StubRepo(loginResult: inactive));

      await expectLater(
        uc.call(LoginUserParams(nome: 'X', senha: '1234')),
        throwsA(isA<UserApiException>().having((e) => e.message, 'message', contains('ativo'))),
      );
    });
  });
}

class _StubRepo implements UserRepository {
  _StubRepo({required this.loginResult});

  final LoginResponse loginResult;

  @override
  Future<bool> changePassword({required String nome, required String currentPassword, required String newPassword}) =>
      throw UnimplementedError();

  @override
  Future<CreateUserResponse> createUser({
    required String nome,
    required String senha,
    File? profileImage,
    int? codUsuario,
  }) => throw UnimplementedError();

  @override
  Future<AppUserConsultation> getAppUser(int codLoginApp) => throw UnimplementedError();

  @override
  Future<LoginResponse> login(String nome, String senha) async => loginResult;

  @override
  Future<AppUserConsultation> putAppUser(AppUser appUser) => throw UnimplementedError();

  @override
  Future<bool> validateCurrentPassword({required String nome, required String currentPassword}) =>
      throw UnimplementedError();
}
