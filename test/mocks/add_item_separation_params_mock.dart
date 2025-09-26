import 'package:exp/domain/usecases/add_item_separation/add_item_separation_params.dart';

/// Cria parâmetros padrão para teste do AddItemSeparation com sessionId específico
AddItemSeparationParams createTestAddItemSeparationParams(String sessionId) {
  if (sessionId.isEmpty) {
    throw StateError('Socket não conectado. SessionId não disponível para teste.');
  }

  // Gerar itemCarrinhoPercurso único respeitando varchar(5)
  return AddItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    sessionId: sessionId,
    codCarrinhoPercurso: 1,
    itemCarrinhoPercurso: '00001', // varchar(5) - 5 caracteres
    codSeparador: 1,
    nomeSeparador: 'TESTE SEPARADOR',
    codProduto: 1,
    codUnidadeMedida: 'UN',
    quantidade: 5.0,
  );
}

/// Cria parâmetros padrão para teste
AddItemSeparationParams createDefaultTestAddItemSeparationParams(String sessionId) {
  return createTestAddItemSeparationParams(sessionId);
}

/// Cria parâmetros com sessionId específico
AddItemSeparationParams createTestAddItemSeparationParamsWithSessionId(String sessionId) {
  return AddItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    sessionId: sessionId,
    codCarrinhoPercurso: 1,
    itemCarrinhoPercurso: '00005',
    codSeparador: 1,
    nomeSeparador: 'TESTE SEPARADOR',
    codProduto: 1,
    codUnidadeMedida: 'UN',
    quantidade: 1.0,
  );
}

/// Cria parâmetros com quantidade insuficiente
AddItemSeparationParams createTestAddItemSeparationParamsWithExcessiveQuantity(String sessionId) {
  if (sessionId.isEmpty) {
    throw StateError('Socket não conectado. SessionId não disponível para teste.');
  }

  return AddItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    sessionId: sessionId,
    codCarrinhoPercurso: 1,
    itemCarrinhoPercurso: '00010',
    codSeparador: 1,
    nomeSeparador: 'TESTE SEPARADOR',
    codProduto: 1,
    codUnidadeMedida: 'UN',
    quantidade: 999.0,
  );
}

/// Cria parâmetros para produto não existente
AddItemSeparationParams createTestAddItemSeparationParamsWithNonExistentProduct(String sessionId) {
  if (sessionId.isEmpty) {
    throw StateError('Socket não conectado. SessionId não disponível para teste.');
  }

  // Gerar itemCarrinhoPercurso único respeitando varchar(5)
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final uniqueItemId = (timestamp % 99999 + 1).toString().padLeft(5, '0');

  return AddItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    sessionId: sessionId,
    codCarrinhoPercurso: 1,
    itemCarrinhoPercurso: uniqueItemId, // varchar(5) - 5 caracteres
    codSeparador: 1,
    nomeSeparador: 'TESTE SEPARADOR',
    codProduto: 999999, // Produto que não existe
    codUnidadeMedida: 'UN',
    quantidade: 1.0,
  );
}

/// Cria parâmetros para primeira separação em testes múltiplos
AddItemSeparationParams createTestAddItemSeparationParamsForMultiple1(String sessionId) {
  return AddItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    sessionId: sessionId,
    codCarrinhoPercurso: 1,
    itemCarrinhoPercurso: '00011',
    codSeparador: 1,
    nomeSeparador: 'TESTE SEPARADOR',
    codProduto: 1,
    codUnidadeMedida: 'UN',
    quantidade: 0.3,
  );
}

/// Cria parâmetros para segunda separação em testes múltiplos
AddItemSeparationParams createTestAddItemSeparationParamsForMultiple2(String sessionId) {
  return AddItemSeparationParams(
    codEmpresa: 1,
    codSepararEstoque: 999999,
    sessionId: sessionId,
    codCarrinhoPercurso: 1,
    itemCarrinhoPercurso: '00012',
    codSeparador: 1,
    nomeSeparador: 'TESTE SEPARADOR',
    codProduto: 1,
    codUnidadeMedida: 'UN',
    quantidade: 0.4,
  );
}
