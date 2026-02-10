import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_params.dart';

/// Cria parâmetros padrão para teste do CancelItemSeparation
CancelItemSeparationParams createTestCancelItemSeparationParams() {
  return CancelItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    item: '00001', // Item que será cancelado
  );
}

/// Cria parâmetros padrão para teste
CancelItemSeparationParams createDefaultTestCancelItemSeparationParams() {
  return createTestCancelItemSeparationParams();
}

/// Cria parâmetros com item específico
CancelItemSeparationParams createTestCancelItemSeparationParamsWithItem(String item) {
  return CancelItemSeparationParams(codEmpresa: 1, codSepararEstoque: 999999, item: item);
}

/// Cria parâmetros para item não existente
CancelItemSeparationParams createTestCancelItemSeparationParamsWithNonExistentItem() {
  return CancelItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    item: '99999', // Item que não existe
  );
}

/// Cria parâmetros para separação não existente
CancelItemSeparationParams createTestCancelItemSeparationParamsWithNonExistentSeparation() {
  return CancelItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999998, // Separação que não existe
    item: '00001',
  );
}

/// Cria parâmetros inválidos para teste de validação
CancelItemSeparationParams createTestCancelItemSeparationParamsInvalid() {
  return CancelItemSeparationParams(
    codEmpresa: 0, // Inválido
    codSepararEstoque: 0, // Inválido
    item: '', // Inválido
  );
}
