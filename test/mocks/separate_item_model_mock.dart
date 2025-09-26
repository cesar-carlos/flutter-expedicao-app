import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';

SeparateItemModel createTestItem() {
  return SeparateItemModel(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    item: '00001',
    codSetorEstoque: 1,
    origem: ExpeditionOrigem.orcamentoBalcao,
    codOrigem: 1,
    itemOrigem: '00003',
    codLocalArmazenagem: 1,
    codProduto: 1,
    codUnidadeMedida: 'UN',
    quantidade: 40.0,
    quantidadeInterna: 40.0,
    quantidadeExterna: 0.0,
    quantidadeSeparacao: 0.0,
  );
}

SeparateItemModel createDefaultTestItem() {
  return createTestItem();
}

SeparateItemModel createUpdatedTestItem(SeparateItemModel originalItem) {
  return originalItem.copyWith(quantidadeSeparacao: 40.0, quantidadeInterna: 0.0, quantidadeExterna: 35.0);
}
