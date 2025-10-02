import 'package:exp/domain/models/separation_item_model.dart';
import 'package:exp/domain/models/situation/expedition_item_situation_model.dart';

SeparationItemModel createTestSeparationItem() {
  return SeparationItemModel(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    item: '00001',
    sessionId: 'PjY13kD8ZRRZJ7APAAAD',
    situacao: ExpeditionItemSituation.pendente,
    codCarrinhoPercurso: 1,
    itemCarrinhoPercurso: '00001',
    codSeparador: 1,
    nomeSeparador: 'TESTE SEPARADOR',
    dataSeparacao: DateTime.now(),
    horaSeparacao: '10:00:00',
    codProduto: 1,
    codUnidadeMedida: 'UN',
    quantidade: 1.0,
  );
}

SeparationItemModel createDefaultTestSeparationItem() {
  return createTestSeparationItem();
}

SeparationItemModel createUpdatedTestSeparationItem(SeparationItemModel originalItem) {
  return originalItem.copyWith(
    situacao: ExpeditionItemSituation.separado,
    nomeSeparador: 'SEPARADOR ATUALIZADO',
    dataSeparacao: DateTime.now(),
    horaSeparacao: '11:30:00',
  );
}
