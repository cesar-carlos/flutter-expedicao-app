import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_failure.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_params.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_usecase.dart';

void main() {
  group('RegisterSeparationUserSectorUseCase', () {
    test('DataError no insert vira RegisterSeparationUserSectorFailure.networkError', () async {
      final repository = _ThrowingSeparationUserSectorRepository();
      final useCase = RegisterSeparationUserSectorUseCase(repository: repository);

      final result = await useCase.call(
        const RegisterSeparationUserSectorParams(
          codEmpresa: 1,
          codSepararEstoque: 100,
          codSetorEstoque: 7,
          codUsuario: 5,
          nomeUsuario: 'Teste',
        ),
      );

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull();
      expect(failure, isA<RegisterSeparationUserSectorFailure>());
      expect(
        (failure as RegisterSeparationUserSectorFailure).type,
        RegisterSeparationUserSectorFailureType.networkError,
      );
    });
  });
}

class _ThrowingSeparationUserSectorRepository implements BasicRepository<SeparationUserSectorModel> {
  @override
  Future<List<SeparationUserSectorModel>> delete(SeparationUserSectorModel entity) async => [entity];

  @override
  Future<List<SeparationUserSectorModel>> insert(SeparationUserSectorModel entity) async {
    throw DataError(message: 'sem rede');
  }

  @override
  Future<List<SeparationUserSectorModel>> select(QueryBuilder queryBuilder) async => [];

  @override
  Future<List<SeparationUserSectorModel>> update(SeparationUserSectorModel entity) async => [entity];
}
