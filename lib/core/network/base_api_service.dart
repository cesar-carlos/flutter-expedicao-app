import 'package:dio/dio.dart';
import 'package:exp/core/network/dio_config.dart';
import 'package:exp/core/network/network_initializer.dart';
import 'package:exp/domain/models/user/user_models.dart';
import 'package:exp/data/dtos/api_error_dto.dart';

abstract class BaseApiService {
  Dio get dio {
    NetworkInitializer.ensureDioInitialized();
    return DioConfig.instance;
  }

  String get baseUrl => DioConfig.baseUrl;

  UserApiException handleDioError(DioException e) {
    final errorDto = ApiErrorDto.connectionError(_getErrorMessage(e));
    return UserApiException(
      errorDto.message,
      statusCode: e.response?.statusCode,
      originalException: e,
    );
  }

  UserApiException handleGenericError(Object e) {
    return UserApiException(
      'Erro interno: $e',
      statusCode: 500,
      originalException: e,
    );
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tempo limite de conexão excedido';
      case DioExceptionType.sendTimeout:
        return 'Tempo limite de envio excedido';
      case DioExceptionType.receiveTimeout:
        return 'Tempo limite de resposta excedido';
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

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw handleGenericError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw handleGenericError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw handleGenericError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw handleGenericError(e);
    }
  }
}
