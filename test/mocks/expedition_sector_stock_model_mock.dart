import 'package:exp/domain/models/expedition_sector_stock_model.dart';
import 'package:exp/domain/models/situation_model.dart';

ExpeditionSectorStockModel createTestSectorStock() {
  return ExpeditionSectorStockModel(
    codSetorEstoque: 999999,
    descricao: 'SETOR TESTE ${DateTime.now().millisecondsSinceEpoch}',
    ativo: Situation.ativo,
  );
}

ExpeditionSectorStockModel createDefaultTestSectorStock() {
  return createTestSectorStock();
}

ExpeditionSectorStockModel createUpdatedTestSectorStock(ExpeditionSectorStockModel originalSector) {
  return originalSector.copyWith(descricao: 'SETOR ATUALIZADO', ativo: Situation.inativo);
}

ExpeditionSectorStockModel createInactiveSectorStock(ExpeditionSectorStockModel originalSector) {
  return originalSector.copyWith(ativo: Situation.inativo);
}
