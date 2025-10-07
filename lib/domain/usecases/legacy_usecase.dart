/// Interface base para casos de uso legados
///
/// Esta interface é para UseCases que ainda não foram migrados
/// para o sistema de `Result<T>`. Use apenas temporariamente.
abstract class LegacyUseCase<T, Params> {
  /// Executa o caso de uso (versão legada)
  Future<T> call(Params params);
}
