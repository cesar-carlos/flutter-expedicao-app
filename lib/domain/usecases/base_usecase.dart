/// Interface base para casos de uso (use cases)
///
/// Todos os casos de uso devem estender esta classe
/// e implementar o método call()
abstract class UseCase<Type, Params> {
  /// Executa o caso de uso
  Future<Type> call(Params params);
}

/// Classe para usar quando um caso de uso não precisa de parâmetros
class NoParams {
  const NoParams();
}
