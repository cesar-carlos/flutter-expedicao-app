import 'package:result_dart/result_dart.dart';

/// Interface base para casos de uso (use cases)
///
/// Todos os casos de uso devem estender esta classe
/// e implementar o método call()
///
/// Usa `Result<T>` para representar operações que podem falhar
abstract class UseCase<T extends Object, Params> {
  /// Executa o caso de uso
  Future<Result<T>> call(Params params);
}

/// UseCase síncrono para operações que não precisam ser assíncronas
abstract class SyncUseCase<T extends Object, Params> {
  /// Executa o caso de uso de forma síncrona
  Result<T> call(Params params);
}

/// Classe para usar quando um caso de uso não precisa de parâmetros
class NoParams {
  const NoParams();
}
