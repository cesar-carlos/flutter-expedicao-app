/// Exceção personalizada para erros da API de usuário
class UserApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isValidationError;
  final dynamic originalException;

  UserApiException(this.message, {this.statusCode, this.isValidationError = false, this.originalException});

  @override
  String toString() {
    return 'UserApiException: $message (Status: $statusCode)';
  }
}
