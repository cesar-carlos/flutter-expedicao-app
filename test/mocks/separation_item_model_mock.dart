import 'package:exp/domain/models/separation_item_model.dart';

SeparationItemModel createTestSeparationItem() {
  return SeparationItemModel(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    item: '00003',
    sessionId: 'NCZhu4LDIC5RIsNYAAAp',
    situacao: 'PE',
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

SeparationItemModel createUpdatedTestSeparationItem(
  SeparationItemModel originalItem,
) {
  return originalItem.copyWith(
    situacao: 'SP',
    nomeSeparador: 'SEPARADOR ATUALIZADO',
    dataSeparacao: DateTime.now(),
    horaSeparacao: '11:30:00',
  );
}
