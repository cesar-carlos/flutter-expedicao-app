import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data7_expedicao/core/network/base_api_service.dart';

class _Api extends BaseApiService {}

void main() {
  for (final status in [400, 401, 404, 500]) {
    test('should preserve the server message and status for HTTP $status', () {
      final request = RequestOptions(path: '/usuarios');
      final cause = DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: request,
          statusCode: status,
          data: {
            'message': '[INVALID_PAYLOAD] Parametro invalido',
            'code': 'INVALID_PAYLOAD',
            'errors': [
              {'message': 'CodUsuario deve ser positivo'},
              null,
            ],
          },
        ),
      );
      final error = _Api().handleDioError(cause);
      expect(error.message, '[INVALID_PAYLOAD] Parametro invalido');
      expect(error.statusCode, status);
      expect(error.code, 'INVALID_PAYLOAD');
      expect(error.validationMessages, ['CodUsuario deve ser positivo']);
      expect(error.originalException, same(cause));
    });
  }
  test('should use a safe fallback for malformed or non JSON error bodies', () {
    for (final body in [
      '<html>private proxy error</html>',
      {'message': 123},
      null,
    ]) {
      final request = RequestOptions(path: '/usuarios');
      final error = _Api().handleDioError(
        DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: request, statusCode: 502, data: body),
        ),
      );
      expect(error.message, 'Resposta inválida do servidor');
    }
  });
  test('should preserve transport timeout feedback without a response', () {
    final error = _Api().handleDioError(
      DioException(
        requestOptions: RequestOptions(path: '/usuarios'),
        type: DioExceptionType.receiveTimeout,
      ),
    );
    expect(error.message, 'Tempo limite de resposta excedido');
  });
}
