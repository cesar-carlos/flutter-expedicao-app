import 'package:dio/dio.dart';

import 'package:data7_expedicao/domain/models/api_config.dart';

class DioConfig {
  static Dio? _dioInstance;
  static ApiConfig? _currentApiConfig;

  static void initialize(ApiConfig apiConfig) {
    _currentApiConfig = apiConfig;
    _dioInstance = _createDioInstance(apiConfig);
  }

  static Dio get instance {
    if (_dioInstance == null) {
      throw StateError('DioConfig não foi inicializado. Chame DioConfig.initialize() primeiro.');
    }
    return _dioInstance!;
  }

  static String get baseUrl {
    if (_currentApiConfig == null) {
      throw StateError('DioConfig não foi inicializado.');
    }
    return _currentApiConfig!.fullUrl;
  }

  static void updateConfig(ApiConfig newApiConfig) {
    _currentApiConfig = newApiConfig;
    _dioInstance = _createDioInstance(newApiConfig);
  }

  static Dio _createDioInstance(ApiConfig apiConfig) {
    final dio = Dio(
      BaseOptions(
        baseUrl: apiConfig.fullUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        validateStatus: (status) {
          return status != null && status >= 200 && status < 300;
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.data != null) {}
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          if (error.response != null) {}
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  static bool get isInitialized => _dioInstance != null;

  static void reset() {
    _dioInstance?.close();
    _dioInstance = null;
    _currentApiConfig = null;
  }
}
