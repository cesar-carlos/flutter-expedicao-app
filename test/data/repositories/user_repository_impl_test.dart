import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/data/repositories/user_repository_impl.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';

void main() {
  group('UserRepositoryImpl', () {
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
                  'data': <String, dynamic>{
                    'CodLoginApp': 9,
                    'Ativo': 'S',
                    'Nome': 'Joao',
                  },
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
