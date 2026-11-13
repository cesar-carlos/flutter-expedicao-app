class UserApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final List<String> validationMessages;
  final bool isValidationError;
  final dynamic originalException;

  UserApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.validationMessages = const [],
    this.isValidationError = false,
    this.originalException,
  });

  @override
  String toString() {
    return 'UserApiException: $message (Status: $statusCode)';
  }
}
