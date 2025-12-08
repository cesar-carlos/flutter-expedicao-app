import 'package:result_dart/result_dart.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';

/// Tipo unitário para representar operações sem retorno
class Unit {
  const Unit._();
  static const Unit instance = Unit._();
}

/// Função helper para criar um sucesso
Result<T> success<T extends Object>(T value) => Success(value);

/// Função helper para criar uma falha
Result<T> failure<T extends Object>(AppFailure failure) => Failure(failure);

/// Função helper para criar uma falha de validação
Result<T> validationFailure<T extends Object>(List<String> errors) => Failure(ValidationFailure.fromErrors(errors));

/// Função helper para criar uma falha de rede
Result<T> networkFailure<T extends Object>(String message, {int? statusCode}) =>
    Failure(NetworkFailure(message: message, statusCode: statusCode));

/// Função helper para criar uma falha de dados
Result<T> dataFailure<T extends Object>(String message, {dynamic exception}) =>
    Failure(DataFailure(message: message, exception: exception));

/// Função helper para criar uma falha de negócio
Result<T> businessFailure<T extends Object>(String message) => Failure(BusinessFailure(message: message));

/// Função helper para criar uma falha de autenticação
Result<T> authFailure<T extends Object>(String message) => Failure(AuthFailure(message: message));

/// Função helper para criar uma falha desconhecida
Result<T> unknownFailure<T extends Object>(dynamic exception) => Failure(UnknownFailure.fromException(exception));

/// Função helper para criar um sucesso void
Result<void> successVoid() {
  return Success<Unit, AppFailure>(Unit.instance) as Result<void>;
}

/// Função helper para executar uma operação que pode falhar
/// e converter exceções em AppFailure
Future<Result<T>> safeCall<T extends Object>(Future<T> Function() operation) async {
  try {
    final result = await operation();
    return success(result);
  } catch (e) {
    return unknownFailure(e);
  }
}

/// Função helper para executar uma operação síncrona que pode falhar
Result<T> safeCallSync<T extends Object>(T Function() operation) {
  try {
    final result = operation();
    return success(result);
  } catch (e) {
    return unknownFailure(e);
  }
}
