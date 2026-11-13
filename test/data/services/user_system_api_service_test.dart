import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/data/services/user_system_api_service.dart';
import 'package:data7_expedicao/data/repositories/user_system_repository_impl.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/user_api_exception.dart';
import '../../mocks/user_system_model_mock.dart';

class _Api extends UserSystemApiService {
  Object body = {'data': <Object>[]};
  Map<String, dynamic>? query;
  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    expect(path, '/usuarios');
    query = queryParameters;
    return Response(
      requestOptions: RequestOptions(path: path),
      data: body,
    );
  }
}

void main() {
  test('should send the documented name without changing other filters or pagination', () async {
    final api = _Api();
    await api.searchUsersByName(
      'Joao',
      codEmpresa: 7,
      apenasAtivos: Situation.inativo,
      pagination: Pagination.create(limit: 20, offset: 40, page: 3),
    );
    expect(api.query, {'NomeUsuario': 'Joao', 'CodEmpresa': 7, 'Ativo': 'N', 'Limit': 20, 'Offset': 40, 'Page': 3});
  });

  test('should preserve valid users and report partial data through the repository', () async {
    final user = createTestUserSystem();
    final api = _Api()
      ..body = {
        'data': [user.toMap(), null],
        'total': 2,
      };
    final page = await UserSystemRepositoryImpl(apiService: api).getUsers();
    expect(page.users.single.codUsuario, user.codUsuario);
    expect(page.invalidItemCount, 1);
    expect(page.isPartial, isTrue);
    expect(page.total, 2);
  });

  test('should fail clearly when every received user is invalid', () async {
    final api = _Api()
      ..body = {
        'data': [null, 'invalid'],
      };
    await expectLater(
      api.getUsers(),
      throwsA(isA<UserApiException>().having((e) => e.message, 'message', contains('registros inválidos'))),
    );
  });

  test('should treat an empty valid list as success', () async {
    final page = await _Api().getUsers();
    expect(page.success, isTrue);
    expect(page.isPartial, isFalse);
    expect(page.users, isEmpty);
  });
}
