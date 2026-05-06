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
  });
}
