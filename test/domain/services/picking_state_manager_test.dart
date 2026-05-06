import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/services/picking_state_manager.dart';

void main() {
  group('PickingStateManager', () {
    SeparateItemConsultationModel buildItem({required String itemId, double qty = 10}) {
      return SeparateItemConsultationModel(
        codEmpresa: 1,
        codSepararEstoque: 100,
        item: itemId,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        codProduto: 1,
        nomeProduto: 'P',
        ativo: Situation.ativo,
        codTipoProduto: '1',
        codUnidadeMedida: 'UN',
        nomeUnidadeMedida: 'UN',
        codGrupoProduto: 1,
        nomeGrupoProduto: 'G',
        codLocalArmazenagem: 1,
        nomeLocaArmazenagem: 'L',
        quantidade: qty,
        quantidadeInterna: qty,
        quantidadeExterna: 0,
        quantidadeSeparacao: 0,
        unidadeMedidas: const [],
      );
    }

    test('initial define totais e progresso', () {
      final manager = PickingStateManager();
      manager.initial([buildItem(itemId: 'A', qty: 5)]);

      expect(manager.totalItems, equals(1));
      expect(manager.completedItems, equals(0));
      expect(manager.progress, equals(0));
      expect(manager.isComplete, isFalse);
    });

    test('updateItemQuantity marca completo quando atinge total', () {
      final manager = PickingStateManager();
      manager.initial([buildItem(itemId: 'A', qty: 3)]);
      manager.updateItemQuantity('A', 3);

      expect(manager.isItemCompleted('A'), isTrue);
      expect(manager.completedItems, equals(1));
      expect(manager.isComplete, isTrue);
    });

    test('revertQuantityAndMarkOperationFailed reduz quantidade', () {
      final manager = PickingStateManager();
      manager.initial([buildItem(itemId: 'A', qty: 10)]);
      final ts = DateTime(2026, 1, 1);
      manager.updateItemQuantityAndAddPending('A', 4, ts);

      manager.revertQuantityAndMarkOperationFailed('A', 4, ts, 'erro');

      expect(manager.getPickedQuantity('A'), equals(0));
    });
  });
}
