import 'package:dio/dio.dart';

import 'package:exp/domain/models/api_config.dart';

/// Configuração global do cliente HTTP Dio
class DioConfig {
  static Dio? _dioInstance;
  static ApiConfig? _currentApiConfig;

  /// Inicializa o Dio com configurações globais
  static void initialize(ApiConfig apiConfig) {
    _currentApiConfig = apiConfig;
    _dioInstance = _createDioInstance(apiConfig);
  }

  /// Obtém a instância global do Dio
  static Dio get instance {
    if (_dioInstance == null) {
      throw StateError('DioConfig não foi inicializado. Chame DioConfig.initialize() primeiro.');
    }
    return _dioInstance!;
  }

  /// Obtém a URL base atual
  static String get baseUrl {
    if (_currentApiConfig == null) {
      throw StateError('DioConfig não foi inicializado.');
    }

    final protocol = _currentApiConfig!.useHttps ? 'https' : 'http';
    return '$protocol://${_currentApiConfig!.apiUrl}:${_currentApiConfig!.apiPort}';
  }

  /// Atualiza as configurações da API
  static void updateConfig(ApiConfig newApiConfig) {
    _currentApiConfig = newApiConfig;
    _dioInstance = _createDioInstance(newApiConfig);
  }

  /// Cria uma nova instância do Dio com as configurações
  static Dio _createDioInstance(ApiConfig apiConfig) {
    final protocol = apiConfig.useHttps ? 'https' : 'http';
    final baseUrl = '$protocol://${apiConfig.apiUrl}:${apiConfig.apiPort}';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        validateStatus: (status) {
          return status != null && status >= 200 && status < 300;
        },
      ),
    );

    // Adicionar interceptors para logging e tratamento de erros
    dio.interceptors.add(_createLoggingInterceptor());
    dio.interceptors.add(_createErrorInterceptor());

    return dio;
  }

  /// Interceptor para logging das requisições
  static Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🔵 [REQUEST] ${options.method} ${options.path}');
        if (options.queryParameters.isNotEmpty) {
          print('🔵 [QUERY] ${options.queryParameters}');
        }
        if (options.data != null) {
          print('🔵 [BODY] ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('🟢 [RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('🔴 [ERROR] ${error.response?.statusCode} ${error.requestOptions.path}');
        print('🔴 [ERROR] ${error.message}');
        handler.next(error);
      },
    );
  }

  /// Interceptor para tratamento padronizado de erros
  static Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Aqui você pode adicionar tratamentos globais de erro
        // Por exemplo, refresh de token, logout automático, etc.

        if (error.response?.statusCode == 401) {
          print('🔴 [AUTH ERROR] Token expirado ou inválido');
          // Implementar refresh de token ou logout
        }

        if (error.response?.statusCode == 500) {
          print('🔴 [SERVER ERROR] Erro interno do servidor');
        }

        handler.next(error);
      },
    );
  }

  /// Cria uma instância temporária do Dio para casos específicos
  static Dio createCustomInstance({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? customHeaders,
    bool enableLogging = true,
  }) {
    final baseConfig = _currentApiConfig;
    if (baseConfig == null) {
      throw StateError('DioConfig não foi inicializado.');
    }

    final protocol = baseConfig.useHttps ? 'https' : 'http';
    final baseUrl = '$protocol://${baseConfig.apiUrl}:${baseConfig.apiPort}';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? const Duration(seconds: 10),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        sendTimeout: sendTimeout ?? const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', ...?customHeaders},
      ),
    );

    if (enableLogging) {
      dio.interceptors.add(_createLoggingInterceptor());
    }

    dio.interceptors.add(_createErrorInterceptor());

    return dio;
  }

  /// Verifica se o Dio está inicializado
  static bool get isInitialized => _dioInstance != null;

  /// Limpa a configuração (útil para testes)
  static void reset() {
    _dioInstance?.close();
    _dioInstance = null;
    _currentApiConfig = null;
  }
}
