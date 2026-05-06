import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_failure.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_usecase.dart';

import '../../support/fake_user_session_service.dart';
import '../../support/in_memory_separate_model_repository.dart';
import '../../support/in_memory_separation_item_repositories.dart';

void main() {
  const params = CancelItemSeparationParams(codEmpresa: 1, codSepararEstoque: 100, item: '00001');

  group('CancelItemSeparationUseCase', () {
    test('retorna invalidParams quando parametros invalidos', () async {
      final uc = CancelItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([]),
        separateRepository: InMemorySeparateModelRepository([]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(const CancelItemSeparationParams(codEmpresa: 0, codSepararEstoque: 100, item: '1'));

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
      expect(failure?.type, CancelItemSeparationFailureType.invalidParams);
    });

    test('retorna userNotFound quando sessao sem UserSystem', () async {
      final uc = CancelItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([]),
        separateRepository: InMemorySeparateModelRepository([]),
        userSessionService: FakeUserSessionService(loggedOut: true),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
      expect(failure?.type, CancelItemSeparationFailureType.userNotFound);
    });

    test('retorna separationItemNotFound quando nao ha separation_item', () async {
      final uc = CancelItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([]),
        separateRepository: InMemorySeparateModelRepository([_separateSeparando()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
      expect(failure?.type, CancelItemSeparationFailureType.separationItemNotFound);
    });

    test('retorna itemAlreadyCancelled quando situacao ja cancelado', () async {
      final uc = CancelItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateItemBase()]),
        separationItemRepository: InMemorySeparationItemRepository([
          _sepItem(situacao: ExpeditionItemSituation.cancelado),
        ]),
        separateRepository: InMemorySeparateModelRepository([_separateSeparando()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
      expect(failure?.type, CancelItemSeparationFailureType.itemAlreadyCancelled);
    });

    test('retorna separateItemNotFound quando nao ha separate_item', () async {
      final uc = CancelItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([_sepItem()]),
        separateRepository: InMemorySeparateModelRepository([_separateSeparando()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
      expect(failure?.type, CancelItemSeparationFailureType.separateItemNotFound);
    });

    test('retorna separateNotFound quando cabecalho separate ausente', () async {
      final uc = CancelItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateItemBase()]),
        separationItemRepository: InMemorySeparationItemRepository([_sepItem()]),
        separateRepository: InMemorySeparateModelRepository([]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
      expect(failure?.type, CancelItemSeparationFailureType.separateNotFound);
    });

    test('retorna separateNotInSeparatingState quando separacao nao esta SEPARANDO', () async {
      final uc = CancelItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateItemBase()]),
        separationItemRepository: InMemorySeparationItemRepository([_sepItem()]),
        separateRepository: InMemorySeparateModelRepository([
          _separateSeparando().copyWith(situacao: ExpeditionSituation.separado),
        ]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
      expect(failure?.type, CancelItemSeparationFailureType.separateNotInSeparatingState);
    });

    test('cancela separation_item e reduz quantidadeSeparacao no separate_item', () async {
      final sepItemRow = _sepItem();
      final sepRow = _separateItemBase();
      final uc = CancelItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([sepRow]),
        separationItemRepository: InMemorySeparationItemRepository([sepItemRow]),
        separateRepository: InMemorySeparateModelRepository([_separateSeparando()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isSuccess(), isTrue);
      result.fold((success) {
        expect(success.cancelledSeparationItem.situacao, ExpeditionItemSituation.cancelado);
        expect(success.updatedSeparateItem.quantidadeSeparacao, 4.0);
      }, (_) => fail('expected success'));
    });

    test('rollback do separation_item quando update do separate_item retorna vazio', () async {
      final originalSepItem = _sepItem();
      final separationRepo = InMemorySeparationItemRepository([originalSepItem]);
      final uc = CancelItemSeparationUseCase(
        separateItemRepository: FailingSeparateItemUpdateRepository([_separateItemBase()]),
        separationItemRepository: separationRepo,
        separateRepository: InMemorySeparateModelRepository([_separateSeparando()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelItemSeparationFailure?;
      expect(failure?.type, CancelItemSeparationFailureType.updateSeparateItemFailed);

      expect(separationRepo.rows.single.situacao, ExpeditionItemSituation.separado);
    });
  });
}

SeparationItemModel _sepItem({ExpeditionItemSituation situacao = ExpeditionItemSituation.separado}) {
  return SeparationItemModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: '00001',
    sessionId: 'abcd12345678',
    situacao: situacao,
    codCarrinhoPercurso: 200,
    itemCarrinhoPercurso: '0001',
    codSeparador: 1,
    nomeSeparador: 'Op',
    dataSeparacao: DateTime(2026, 1, 1),
    horaSeparacao: '10:00:00',
    codProduto: 42,
    codUnidadeMedida: 'UN',
    quantidade: 2.0,
  );
}

SeparateItemModel _separateItemBase() {
  return SeparateItemModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: '00001',
    codSetorEstoque: 1,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codLocalArmazenagem: 1,
    codProduto: 42,
    codUnidadeMedida: 'UN',
    quantidade: 10,
    quantidadeInterna: 10,
    quantidadeExterna: 0,
    quantidadeSeparacao: 6,
  );
}

SeparateModel _separateSeparando() {
  return SeparateModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codTipoOperacaoExpedicao: 1,
    tipoEntidade: EntityType.cliente,
    codEntidade: 1,
    nomeEntidade: 'Cliente',
    situacao: ExpeditionSituation.separando,
    data: DateTime(2026, 1, 1),
    hora: '08:00:00',
    codPrioridade: 1,
  );
}
