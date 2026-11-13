import 'package:dio/dio.dart';

import 'package:data7_expedicao/core/network/dio_config.dart';
import 'package:data7_expedicao/core/network/network_initializer.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';

abstract class BaseApiService {
  Dio get dio {
    NetworkInitializer.ensureDioInitialized();
    return DioConfig.instance;
  }

  String get baseUrl => DioConfig.baseUrl;

  UserApiException handleDioError(DioException e) {
    final body = e.response?.data;
    final message = body is Map ? body['message'] : null;
    final code = body is Map ? body['code'] : null;
    final errors = body is Map ? body['errors'] : null;
    final validationMessages = <String>[];
    if (errors is List) {
      for (final error in errors) {
        final detail = error is Map ? error['message'] : error;
        if (detail is String && detail.trim().isNotEmpty) {
          validationMessages.add(detail.trim());
        }
      }
    }
    return UserApiException(
      message is String && message.trim().isNotEmpty ? message.trim() : _getErrorMessage(e),
      statusCode: e.response?.statusCode,
      code: code is String ? code : null,
      validationMessages: List.unmodifiable(validationMessages),
      isValidationError: code == 'INVALID_PAYLOAD' || validationMessages.isNotEmpty,
      originalException: e,
    );
  }

  UserApiException handleGenericError(Object e) {
    return UserApiException('Erro interno: $e', statusCode: 500, originalException: e);
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tempo limite de conexão excedido';
      case DioExceptionType.sendTimeout:
        return 'Tempo limite de envio excedido';
      case DioExceptionType.receiveTimeout:
        return 'Tempo limite de resposta excedido';
      case DioExceptionType.transformTimeout:
        return 'Tempo limite ao transformar a resposta excedido';
      case DioExceptionType.connectionError:
        return 'Erro de conexão - Verifique URL e porta';
      case DioExceptionType.cancel:
        return 'Operação cancelada';
      case DioExceptionType.badResponse:
        return 'Resposta inválida do servidor';
      case DioExceptionType.badCertificate:
        return 'Erro de certificado SSL';
      case DioExceptionType.unknown:
        return 'Erro de comunicação: ${e.message}';
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw handleGenericError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw handleGenericError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.put(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw handleGenericError(e);
    }
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw handleGenericError(e);
    }
  }
}
