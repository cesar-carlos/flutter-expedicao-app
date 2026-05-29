/// Contrato de dominio para o cache de verificacao de atualizacoes.
///
/// Expoe apenas as operacoes consumidas pela camada de apresentacao.
abstract interface class IUpdateCacheService {
  bool shouldCheckForUpdates();

  Future<void> markAsChecked();
}
