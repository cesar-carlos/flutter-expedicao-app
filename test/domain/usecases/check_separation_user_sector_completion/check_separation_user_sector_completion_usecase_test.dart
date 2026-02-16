import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_params.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_usecase.dart';

void main() {
  group('CheckSeparationUserSectorCompletionUseCase', () {
    late _FakeRepository repository;
    late CheckSeparationUserSectorCompletionUseCase useCase;

    setUp(() {
      repository = _FakeRepository();
      useCase = CheckSeparationUserSectorCompletionUseCase(repository: repository);
      repository.reset();
    });

    test('deve retornar falha de validacao quando parametros forem invalidos', () async {
      final params = CheckSeparationUserSectorCompletionParams(
        codEmpresa: 1,
        codSepararEstoque: 100,
        codSetorEstoque: 10,
        codUsuario: 0,
      );

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<ValidationFailure>());
    });

    test('deve retornar false quando nao houver registros do usuario/setor', () async {
      repository.setResult([]);
      final params = _validParams();

      final result = await useCase.call(params);

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull(), isFalse);
    });

    test('deve retornar true quando setor estiver concluido e sem carrinhos abertos', () async {
      repository.setResult([
        _createRecord(quantidadeItensSetor: 10, quantidadeItensSeparacaoSetor: 10, carrinhosAbertosUsuario: 'N'),
      ]);
      final params = _validParams();

      final result = await useCase.call(params);

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull(), isTrue);
    });

    test('deve retornar false quando houver itens pendentes no setor', () async {
      repository.setResult([
        _createRecord(quantidadeItensSetor: 10, quantidadeItensSeparacaoSetor: 8, carrinhosAbertosUsuario: 'N'),
      ]);
      final params = _validParams();

      final result = await useCase.call(params);

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull(), isFalse);
    });

    test('deve retornar false quando houver carrinhos abertos no setor', () async {
      repository.setResult([
        _createRecord(quantidadeItensSetor: 10, quantidadeItensSeparacaoSetor: 10, carrinhosAbertosUsuario: 'S'),
      ]);
      final params = _validParams();

      final result = await useCase.call(params);

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull(), isFalse);
    });

    test('deve retornar falha de rede quando repositorio lancar DataError', () async {
      repository.setError(DataError(message: 'Erro de conexao'));
      final params = _validParams();

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<NetworkFailure>());
    });

    test('deve retornar falha desconhecida quando repositorio lancar excecao generica', () async {
      repository.setError(Exception('Erro inesperado'));
      final params = _validParams();

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<UnknownFailure>());
    });
  });
}

CheckSeparationUserSectorCompletionParams _validParams() {
  return const CheckSeparationUserSectorCompletionParams(
    codEmpresa: 1,
    codSepararEstoque: 100,
    codSetorEstoque: 10,
    codUsuario: 1,
  );
}

SeparationUserSectorConsultationModel _createRecord({
  required double quantidadeItensSetor,
  required double quantidadeItensSeparacaoSetor,
  required String carrinhosAbertosUsuario,
}) {
  return SeparationUserSectorConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    separarEstoqueSituacao: ExpeditionSituation.separando,
    codSetorEstoque: 10,
    descricaoSetorEstoque: 'Setor',
    codPrioridade: 1,
    descricaoPrioridade: 'Normal',
    prioridade: 1,
    quantidadeItens: 10,
    quantidadeItensSeparacao: 8,
    quantidadeItensSetor: quantidadeItensSetor,
    quantidadeItensSeparacaoSetor: quantidadeItensSeparacaoSetor,
    carrinhosAbertosUsuario: carrinhosAbertosUsuario,
    codUsuario: 1,
    nomeUsuario: 'Usuario',
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
