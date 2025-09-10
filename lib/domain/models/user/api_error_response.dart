/// Modelo para resposta de erro da API
class ApiErrorResponse {
  final String message;

  ApiErrorResponse({required this.message});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(message: json['message'] ?? 'Erro desconhecido');
  }

  @override
  String toString() {
    return 'ApiErrorResponse(message: $message)';
  }
}
