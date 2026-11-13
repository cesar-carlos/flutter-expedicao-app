import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/data/repositories/user_repository_impl.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';

void main() {
  group('UserRepositoryImpl', () {
    test('should preserve historical lowercase passwords in login, creation and updates', () async {
      final sentPasswords = <String>[];
      final dio = Dio(BaseOptions(baseUrl: 'http://stub.test'));
      addTearDown(dio.close);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sentPasswords.add((options.data as Map)['Senha'] as String);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: options.path.endsWith('create-login-app') ? 201 : 200,
                data: {
                  'message': 'ok',
                  'user': {'CodLoginApp': 1, 'Nome': 'user', 'Ativo': 'S'},
                },
              ),
            );
          },
        ),
      );
      final repo = UserRepositoryImpl(dio: dio);
      await repo.login('user', 'AnTiGa123');
      await repo.createUser(nome: 'user', senha: 'AnTiGa123');
      final user = (await repo.login('user', 'AnTiGa123')).user;
      await repo.putAppUser(user.copyWith(senha: 'NoVa123'));
      await repo.changePassword(nome: 'user', currentPassword: 'AnTiGa123', newPassword: 'NoVa123');
      expect(sentPasswords, ['antiga123', 'antiga123', 'antiga123', 'nova123', 'antiga123', 'nova123']);
    });

    test('should reject passwords over 20 characters before issuing requests', () async {
      var requests = 0;
      final dio = Dio(BaseOptions(baseUrl: 'http://stub.test'));
      addTearDown(dio.close);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests++;
            handler.reject(DioException(requestOptions: options));
          },
        ),
      );
      final repo = UserRepositoryImpl(dio: dio);
      final failure = throwsA(isA<UserApiException>().having((e) => e.message, 'message', contains('20 caracteres')));
      await expectLater(repo.login('user', 'a' * 21), failure);
      await expectLater(repo.createUser(nome: 'user', senha: 'a' * 21), failure);
      await expectLater(repo.changePassword(nome: 'user', currentPassword: 'old1', newPassword: 'a' * 21), failure);
      await expectLater(
        repo.putAppUser(AppUser.fromJson({'CodLoginApp': 1, 'Nome': 'user', 'Ativo': 'S', 'Senha': 'a' * 21})),
        failure,
      );
      expect(requests, 0);
    });

    test('should preserve a registration validation error without dumping its payload', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://stub.test'));
      addTearDown(dio.close);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 400,
                  data: {
                    'message': 'Nome indisponivel',
                    'code': 'INVALID_PAYLOAD',
                    'errors': [
                      {'message': 'Escolha outro nome', 'received': 'sensitive-value'},
                    ],
                  },
                ),
              ),
            );
          },
        ),
      );
      await expectLater(
        UserRepositoryImpl(dio: dio).createUser(nome: 'user', senha: 'AbCd'),
        throwsA(
          isA<UserApiException>()
              .having((e) => e.message, 'message', 'Nome indisponivel')
              .having((e) => e.validationMessages, 'details', ['Escolha outro nome'])
              .having((e) => e.code, 'code', 'INVALID_PAYLOAD')
              .having((e) => e.statusCode, 'status', 400)
              .having((e) => e.originalException, 'cause', isA<DioException>()),
        ),
      );
    });

    test('should use a safe fallback for malformed registration error bodies', () async {
      for (final body in [
        null,
        '<html>private error</html>',
        {'message': 123},
      ]) {
        final dio = Dio(BaseOptions(baseUrl: 'http://stub.test'));
        addTearDown(dio.close);
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response(requestOptions: options, statusCode: 400, data: body),
                ),
              );
            },
          ),
        );
        await expectLater(
          UserRepositoryImpl(dio: dio).createUser(nome: 'user', senha: 'AbCd'),
          throwsA(
            isA<UserApiException>().having(
              (e) => e.message,
              'message',
              'Erro de validação no cadastro. Verifique os dados informados.',
            ),
          ),
        );
      }
    });

    test('login mapeia DioException de conexao para UserApiException', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://stub.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(requestOptions: options, type: DioExceptionType.connectionError, message: 'simulated'),
            );
          },
        ),
      );

      final repo = UserRepositoryImpl(dio: dio);

      await expectLater(
        repo.login('user', 'secret'),
        throwsA(isA<UserApiException>().having((UserApiException e) => e.message, 'message', contains('conexão'))),
      );
    });

    test('getAppUser consulta GET /expedicao/login-app', () async {
      String? requestedPath;
      final dio = Dio(BaseOptions(baseUrl: 'http://stub.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'message': 'Usuário encontrado',
                  'data': <String, dynamic>{'CodLoginApp': 9, 'Ativo': 'S', 'Nome': 'Joao'},
                  'total': 1,
                },
              ),
            );
          },
        ),
      );

      final repo = UserRepositoryImpl(dio: dio);
      final user = await repo.getAppUser(9);

      expect(requestedPath, contains('/expedicao/login-app'));
      expect(requestedPath, isNot(contains('consult-login-app')));
      expect(user.codLoginApp, 9);
      expect(user.nome, 'Joao');
    });
  });
}
