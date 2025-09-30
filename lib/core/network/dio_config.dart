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
    return _currentApiConfig!.fullUrl;
  }

  /// Atualiza as configurações da API
  static void updateConfig(ApiConfig newApiConfig) {
    _currentApiConfig = newApiConfig;
    _dioInstance = _createDioInstance(newApiConfig);
  }

  /// Cria uma nova instância do Dio com as configurações
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

    // Adicionar interceptors para logging e tratamento de erros
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log da requisição
          print('🌐 ${options.method} ${options.uri}');
          if (options.data != null) {
            print('📦 Request Data: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log da resposta
          print('✅ ${response.statusCode} ${response.requestOptions.uri}');
          print('📦 Response Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          // Log de erro
          print('❌ ${error.type} ${error.message}');
          if (error.response != null) {
            print('📦 Error Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );

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
