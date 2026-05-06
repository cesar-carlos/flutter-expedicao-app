import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_link/check_separation_user_sector_link_usecase.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_params.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_usecase.dart';

void main() {
  group('ResolveSeparationUserLinkUseCase', () {
    late _FakeSectorLinkRepository repo;
    late CheckSeparationUserSectorLinkUseCase checkLink;
    late ResolveSeparationUserLinkUseCase useCase;

    SeparateConsultationModel separation({List<int> usuarios = const []}) {
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
        codUsuariosSeparacao: usuarios,
      );
    }

    SeparationUserSectorConsultationModel linkRow({required int codUsuario}) {
      return SeparationUserSectorConsultationModel(
        codEmpresa: 1,
        codSepararEstoque: 100,
        separarEstoqueSituacao: ExpeditionSituation.separando,
        codSetorEstoque: 7,
        descricaoSetorEstoque: 'Setor',
        codPrioridade: 1,
        descricaoPrioridade: 'Pr',
        prioridade: 1,
        quantidadeItens: 1,
        quantidadeItensSeparacao: 0,
        quantidadeItensSetor: 1,
        quantidadeItensSeparacaoSetor: 0,
        carrinhosAbertosUsuario: '',
        codUsuario: codUsuario,
      );
    }

    setUp(() {
      repo = _FakeSectorLinkRepository();
      checkLink = CheckSeparationUserSectorLinkUseCase(repository: repo);
      useCase = ResolveSeparationUserLinkUseCase(checkLinkUseCase: checkLink);
    });

    test('retorna ValidationFailure quando params invalidos', () async {
      final result = await useCase.call(
        ResolveSeparationUserLinkParams(
          separation: separation(),
          codUsuario: 0,
          codSetorEstoque: 7,
        ),
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<ValidationFailure>());
    });

    test('quando lista codUsuariosSeparacao preenchida retorna contains usuario', () async {
      final result = await useCase.call(
        ResolveSeparationUserLinkParams(
          separation: separation(usuarios: [5, 9]),
          codUsuario: 5,
          codSetorEstoque: 7,
        ),
      );

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull(), isTrue);
    });

    test('quando lista codUsuariosSeparacao preenchida retorna false se nao contem', () async {
      final result = await useCase.call(
        ResolveSeparationUserLinkParams(
          separation: separation(usuarios: [9]),
          codUsuario: 5,
          codSetorEstoque: 7,
        ),
      );

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull(), isFalse);
    });

    test('quando lista vazia delega para CheckSeparationUserSectorLinkUseCase', () async {
      repo.rows = [linkRow(codUsuario: 5)];

      final result = await useCase.call(
        ResolveSeparationUserLinkParams(
          separation: separation(usuarios: const []),
          codUsuario: 5,
          codSetorEstoque: 7,
        ),
      );

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull(), isTrue);
    });

    test('delegacao retorna false quando link nao existe', () async {
      repo.rows = [];

      final result = await useCase.call(
        ResolveSeparationUserLinkParams(
          separation: separation(usuarios: const []),
          codUsuario: 5,
          codSetorEstoque: 7,
        ),
      );

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull(), isFalse);
    });
  });
}

class _FakeSectorLinkRepository implements BasicConsultationRepository<SeparationUserSectorConsultationModel> {
  List<SeparationUserSectorConsultationModel> rows = [];

  @override
  Future<List<SeparationUserSectorConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    return List<SeparationUserSectorConsultationModel>.from(rows);
  }
}
