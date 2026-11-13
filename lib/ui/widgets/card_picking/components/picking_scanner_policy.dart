/// Política de ativação do scanner na tela de picking.
///
/// [PickingCardScan] só entra na árvore depois do load (ou deveria).
/// Lista vazia é estado terminal — carrinho sem itens, setor sem pendência
/// ou já finalizado — e não “ainda carregando”.
bool shouldActivatePickingScanner({required bool isCartInSeparation, required bool hasNextItem}) {
  return isCartInSeparation && hasNextItem;
}
