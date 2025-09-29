import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_params.dart';

/// Cria parâmetros padrão para teste do CancelItemSeparation com sessionId específico
CancelItemSeparationParams createTestCancelItemSeparationParams(String sessionId) {
  if (sessionId.isEmpty) {
    throw StateError('Socket não conectado. SessionId não disponível para teste.');
  }

  return CancelItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    item: '00001', // Item que será cancelado
    sessionId: sessionId,
  );
}

/// Cria parâmetros padrão para teste
CancelItemSeparationParams createDefaultTestCancelItemSeparationParams(String sessionId) {
  return createTestCancelItemSeparationParams(sessionId);
}

/// Cria parâmetros com item específico
CancelItemSeparationParams createTestCancelItemSeparationParamsWithItem(String sessionId, String item) {
  if (sessionId.isEmpty) {
    throw StateError('Socket não conectado. SessionId não disponível para teste.');
  }

  return CancelItemSeparationParams(codEmpresa: 1, codSepararEstoque: 999999, item: item, sessionId: sessionId);
}

/// Cria parâmetros para item não existente
CancelItemSeparationParams createTestCancelItemSeparationParamsWithNonExistentItem(String sessionId) {
  if (sessionId.isEmpty) {
    throw StateError('Socket não conectado. SessionId não disponível para teste.');
  }

  return CancelItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    item: '99999', // Item que não existe
    sessionId: sessionId,
  );
}

/// Cria parâmetros para separação não existente
CancelItemSeparationParams createTestCancelItemSeparationParamsWithNonExistentSeparation(String sessionId) {
  if (sessionId.isEmpty) {
    throw StateError('Socket não conectado. SessionId não disponível para teste.');
  }

  return CancelItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999998, // Separação que não existe
    item: '00001',
    sessionId: sessionId,
  );
}

/// Cria parâmetros inválidos para teste de validação
CancelItemSeparationParams createTestCancelItemSeparationParamsInvalid() {
  return CancelItemSeparationParams(
    codEmpresa: 0, // Inválido
    codSepararEstoque: 0, // Inválido
    item: '', // Inválido
    sessionId: '', // Inválido
  );
}
