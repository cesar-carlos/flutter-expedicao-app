import 'package:exp/domain/models/separate_item_model.dart';

SeparateItemModel createTestItem() {
  return SeparateItemModel(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    item: '00001',
    codSetorEstoque: 1,
    origem: 'OB',
    codOrigem: 1,
    itemOrigem: '00003',
    codLocalArmazenagem: 1,
    codProduto: 1,
    codUnidadeMedida: 'UN',
    quantidade: 1.0,
    quantidadeInterna: 1.0,
    quantidadeExterna: 0.0,
    quantidadeSeparacao: 0.0,
  );
}

SeparateItemModel createDefaultTestItem() {
  return createTestItem();
}

SeparateItemModel createUpdatedTestItem(SeparateItemModel originalItem) {
  return originalItem.copyWith(
    quantidadeSeparacao: 0.5,
    quantidadeInterna: 0.5,
    quantidadeExterna: 0.5,
  );
}
