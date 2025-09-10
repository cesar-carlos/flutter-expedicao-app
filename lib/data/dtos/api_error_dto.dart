import 'package:exp/domain/models/user/user_models.dart';

class ApiErrorDto {
  final String message;
  final int? statusCode;
  final bool isValidationError;

  ApiErrorDto({
    required this.message,
    this.statusCode,
    this.isValidationError = false,
  });

  factory ApiErrorDto.fromApiResponse(
    Map<String, dynamic> json,
    int? statusCode,
  ) {
    return ApiErrorDto(
      message: json['message'] ?? json['error'] ?? 'Erro desconhecido',
      statusCode: statusCode,
      isValidationError: statusCode == 400,
    );
  }

  factory ApiErrorDto.validationError(String message, [dynamic responseData]) {
    final errorMessage = responseData != null
        ? 'Erro de validação: $responseData'
        : message;

    return ApiErrorDto(
      message: errorMessage,
      statusCode: 400,
      isValidationError: true,
    );
  }

  factory ApiErrorDto.connectionError(String message) {
    return ApiErrorDto(
      message: message,
      statusCode: null,
      isValidationError: false,
    );
  }

  UserApiException toException() {
    return UserApiException(
      message,
      statusCode: statusCode,
      isValidationError: isValidationError,
    );
  }

  @override
  String toString() {
    return 'ApiErrorDto(message: $message, statusCode: $statusCode, isValidation: $isValidationError)';
  }
}
