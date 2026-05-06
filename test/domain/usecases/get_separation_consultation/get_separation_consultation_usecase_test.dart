import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_params.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_usecase.dart';

void main() {
  group('GetSeparationConsultationUseCase', () {
    late _FakeSeparateConsultationRepository repo;
    late GetSeparationConsultationUseCase useCase;

    SeparateConsultationModel row() {
      return SeparateConsultationModel(
        codEmpresa: 1,
        codSepararEstoque: 100,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        codTipoOperacaoExpedicao: 10,
        nomeTipoOperacaoExpedicao: 'X',
        situacao: ExpeditionSituation.aguardando,
        tipoEntidade: EntityType.cliente,
        dataEmissao: DateTime(2026, 1, 1),
        horaEmissao: '10:00:00',
        codEntidade: 1,
        nomeEntidade: 'E',
        codPrioridade: 1,
        nomePrioridade: 'P',
        codSetoresEstoque: const [7],
        codUsuariosSeparacao: const [],
      );
    }

    setUp(() {
      repo = _FakeSeparateConsultationRepository();
      useCase = GetSeparationConsultationUseCase(repository: repo);
    });

    test('retorna ValidationFailure quando params invalidos', () async {
      final result = await useCase.call(
        const GetSeparationConsultationParams(codEmpresa: 0, codSepararEstoque: 100),
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<ValidationFailure>());
    });

    test('retorna DataFailure notFound quando lista vazia', () async {
      final result = await useCase.call(
        const GetSeparationConsultationParams(codEmpresa: 1, codSepararEstoque: 100),
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<DataFailure>());
    });

    test('sucesso retorna primeiro registro', () async {
      repo.rows = [row()];

      final result = await useCase.call(
        const GetSeparationConsultationParams(codEmpresa: 1, codSepararEstoque: 100),
      );

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull()?.codSepararEstoque, equals(100));
    });

    test('DataError do repositorio vira NetworkFailure', () async {
      repo.throwDataError = true;

      final result = await useCase.call(
        const GetSeparationConsultationParams(codEmpresa: 1, codSepararEstoque: 100),
      );

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull();
      expect(failure, isA<NetworkFailure>());
      expect((failure as NetworkFailure).code, equals('NETWORK_ERROR'));
    });
  });
}

class _FakeSeparateConsultationRepository implements BasicConsultationRepository<SeparateConsultationModel> {
  List<SeparateConsultationModel> rows = [];
  bool throwDataError = false;

  @override
  Future<List<SeparateConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    if (throwDataError) {
      throw DataError(message: 'timeout');
    }
    return List<SeparateConsultationModel>.from(rows);
  }
}
