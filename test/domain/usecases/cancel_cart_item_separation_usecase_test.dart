import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_failure.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_usecase.dart';

import '../../support/fake_user_session_service.dart';
import '../../support/in_memory_separation_item_repositories.dart';

void main() {
  const params = CancelCardItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 100,
    codCarrinhoPercurso: 200,
    itemCarrinhoPercurso: '0001',
  );

  const invalidParams = CancelCardItemSeparationParams(
    codEmpresa: 0,
    codSepararEstoque: 100,
    codCarrinhoPercurso: 200,
    itemCarrinhoPercurso: '1',
  );

  group('CancelCardItemSeparationUseCase', () {
    test('retorna invalidParams quando parametros invalidos', () async {
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(invalidParams);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelCardItemSeparationFailure?;
      expect(failure?.type, CancelCardItemSeparationFailureType.invalidParams);
    });

    test('retorna userNotFound quando sessao sem UserSystem', () async {
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([]),
        userSessionService: FakeUserSessionService(loggedOut: true),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelCardItemSeparationFailure?;
      expect(failure?.type, CancelCardItemSeparationFailureType.userNotFound);
    });

    test('retorna itemsNotFound quando nao ha separation_item para o carrinho', () async {
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateRow()]),
        separationItemRepository: InMemorySeparationItemRepository([]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelCardItemSeparationFailure?;
      expect(failure?.type, CancelCardItemSeparationFailureType.itemsNotFound);
    });

    test('retorna updateSeparateItemFailed quando nao ha separate_item para o produto', () async {
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([]),
        separationItemRepository: InMemorySeparationItemRepository([_separationRow()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelCardItemSeparationFailure?;
      expect(failure?.type, CancelCardItemSeparationFailureType.updateSeparateItemFailed);
    });

    test('retorna updateSeparationItemFailed quando update de cancelamento retorna vazio', () async {
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateRow()]),
        separationItemRepository: EmptyUpdateSeparationItemRepository([_separationRow()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull() as CancelCardItemSeparationFailure?;
      expect(failure?.type, CancelCardItemSeparationFailureType.updateSeparationItemFailed);
    });

    test('cancela itens e reduz quantidadeSeparacao nos separate_item', () async {
      final sepRow = _separateRow();
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([sepRow]),
        separationItemRepository: InMemorySeparationItemRepository([_separationRow()]),
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);

      expect(result.isSuccess(), isTrue);
      result.fold((success) {
        expect(success.cancelledSeparationItems.every((e) => e.situacao == ExpeditionItemSituation.cancelado), isTrue);
        expect(success.updatedSeparateItems.single.quantidadeSeparacao, 4.0);
      }, (_) => fail('expected success'));
    });

    test('rollbackCancellation restaura separate_item e separation_item originais', () async {
      final separateRepo = InMemorySeparateItemRepository([_separateRow()]);
      final separationRepo = InMemorySeparationItemRepository([_separationRow()]);
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: separateRepo,
        separationItemRepository: separationRepo,
        userSessionService: FakeUserSessionService(),
      );

      final result = await uc.call(params);
      expect(result.isSuccess(), isTrue);

      expect(separateRepo.rows.single.quantidadeSeparacao, 4.0);
      expect(separationRepo.rows.single.situacao, ExpeditionItemSituation.cancelado);

      final success = result.fold((s) => s, (_) => throw StateError('expected success'));
      expect(await uc.rollbackCancellation(success), isTrue);

      expect(separateRepo.rows.single.quantidadeSeparacao, 6.0);
      expect(separationRepo.rows.single.situacao, ExpeditionItemSituation.separado);
    });

    test('canCancelItems retorna true quando ha itens', () async {
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateRow()]),
        separationItemRepository: InMemorySeparationItemRepository([_separationRow()]),
        userSessionService: FakeUserSessionService(),
      );

      expect(await uc.canCancelItems(params), isTrue);
    });

    test('canCancelItems retorna false quando parametros invalidos', () async {
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateRow()]),
        separationItemRepository: InMemorySeparationItemRepository([_separationRow()]),
        userSessionService: FakeUserSessionService(),
      );

      expect(await uc.canCancelItems(invalidParams), isFalse);
    });

    test('getItemsToBeCancelled retorna quantidades por produto', () async {
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateRow()]),
        separationItemRepository: InMemorySeparationItemRepository([_separationRow()]),
        userSessionService: FakeUserSessionService(),
      );

      final map = await uc.getItemsToBeCancelled(params);

      expect(map[42], 2.0);
    });

    test('getItemsToBeCancelled retorna vazio quando parametros invalidos', () async {
      final uc = CancelCardItemSeparationUseCase(
        separateItemRepository: InMemorySeparateItemRepository([_separateRow()]),
        separationItemRepository: InMemorySeparationItemRepository([_separationRow()]),
        userSessionService: FakeUserSessionService(),
      );

      expect(await uc.getItemsToBeCancelled(invalidParams), isEmpty);
    });
  });
}

SeparationItemModel _separationRow() {
  return SeparationItemModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: '00001',
    sessionId: 'abcd12345678',
    situacao: ExpeditionItemSituation.separado,
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

SeparateItemModel _separateRow() {
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
