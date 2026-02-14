import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_link/check_separation_user_sector_link_params.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_link/check_separation_user_sector_link_usecase.dart';
import 'package:data7_expedicao/core/results/index.dart';

void main() {
  group('CheckSeparationUserSectorLinkUseCase', () {
    late _FakeRepository repository;
    late CheckSeparationUserSectorLinkUseCase useCase;

    setUp(() {
      repository = _FakeRepository();
      useCase = CheckSeparationUserSectorLinkUseCase(repository: repository);
      repository.reset();
    });

    group('Validação de parâmetros', () {
      test('deve retornar falha quando codUsuario for zero', () async {
        final params = CheckSeparationUserSectorLinkParams(
          codEmpresa: 1,
          codSepararEstoque: 100,
          codSetorEstoque: 10,
          codUsuario: 0,
        );

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<ValidationFailure>());
      });

      test('deve retornar falha quando codEmpresa for zero', () async {
        final params = CheckSeparationUserSectorLinkParams(
          codEmpresa: 0,
          codSepararEstoque: 100,
          codSetorEstoque: 10,
          codUsuario: 1,
        );

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<ValidationFailure>());
      });

      test('deve retornar falha quando codSepararEstoque for zero', () async {
        final params = CheckSeparationUserSectorLinkParams(
          codEmpresa: 1,
          codSepararEstoque: 0,
          codSetorEstoque: 10,
          codUsuario: 1,
        );

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<ValidationFailure>());
      });

      test('deve retornar falha quando codSetorEstoque for zero', () async {
        final params = CheckSeparationUserSectorLinkParams(
          codEmpresa: 1,
          codSepararEstoque: 100,
          codSetorEstoque: 0,
          codUsuario: 1,
        );

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<ValidationFailure>());
      });
    });

    group('Consulta de vínculo', () {
      test('deve retornar true quando repositório retorna lista não vazia', () async {
        repository.setResult([_createMockRecord()]);

        final params = CheckSeparationUserSectorLinkParams(
          codEmpresa: 1,
          codSepararEstoque: 100,
          codSetorEstoque: 10,
          codUsuario: 1,
        );

        final result = await useCase.call(params);

        expect(result.isSuccess(), isTrue);
        expect(result.getOrNull(), isTrue);
      });

      test('deve retornar false quando repositório retorna lista vazia', () async {
        repository.setResult([]);

        final params = CheckSeparationUserSectorLinkParams(
          codEmpresa: 1,
          codSepararEstoque: 100,
          codSetorEstoque: 10,
          codUsuario: 1,
        );

        final result = await useCase.call(params);

        expect(result.isSuccess(), isTrue);
        expect(result.getOrNull(), isFalse);
      });
    });

    group('Tratamento de erros', () {
      test('deve retornar falha quando repositório lança DataError', () async {
        repository.setError(DataError(message: 'Erro de conexão'));

        final params = CheckSeparationUserSectorLinkParams(
          codEmpresa: 1,
          codSepararEstoque: 100,
          codSetorEstoque: 10,
          codUsuario: 1,
        );

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<NetworkFailure>());
      });

      test('deve retornar falha quando repositório lança exceção genérica', () async {
        repository.setError(Exception('Erro inesperado'));

        final params = CheckSeparationUserSectorLinkParams(
          codEmpresa: 1,
          codSepararEstoque: 100,
          codSetorEstoque: 10,
          codUsuario: 1,
        );

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<UnknownFailure>());
      });
    });
  });
}

SeparationUserSectorConsultationModel _createMockRecord() {
  return SeparationUserSectorConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    separarEstoqueSituacao: ExpeditionSituation.separando,
    codSetorEstoque: 10,
    descricaoSetorEstoque: 'Setor',
    codPrioridade: 1,
    descricaoPrioridade: 'Normal',
    prioridade: 1,
    quantidadeItens: 10.0,
    quantidadeItensSeparacao: 5.0,
    quantidadeItensSetor: 10.0,
    quantidadeItensSeparacaoSetor: 5.0,
    carrinhosAbertosUsuario: 'N',
    codUsuario: 1,
    nomeUsuario: 'User',
    estacaoSeparacao: null,
  );
}

class _FakeRepository implements BasicConsultationRepository<SeparationUserSectorConsultationModel> {
  List<SeparationUserSectorConsultationModel> _result = [];
  Object? _error;

  void setResult(List<SeparationUserSectorConsultationModel> result) {
    _result = List.from(result);
  }

  void setError(Object error) {
    _error = error;
  }

  void reset() {
    _result = [];
    _error = null;
  }

  @override
  Future<List<SeparationUserSectorConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    if (_error != null) {
      throw _error!;
    }
    return List.from(_result);
  }
}
