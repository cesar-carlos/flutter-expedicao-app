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
    // Bug TTTTT: a versao anterior apenas reatribuia `_dioInstance =
    // _createDioInstance(...)`, descartando a Dio antiga SEM chamar
    // `.close()`. Cada updateConfig vazava: pool de conexoes HTTP
    // ainda aberto, interceptors retidos, sockets em CLOSE_WAIT.
    // Em sessoes longas com varios updateConfig (mudanca de IP do
    // servidor durante operacao), o leak crescia ate exaurir
    // file descriptors em dispositivos modestos.
    _currentApiConfig = newApiConfig;
    final previous = _dioInstance;
    _dioInstance = _createDioInstance(newApiConfig);
    // Fecha a instancia antiga DEPOIS de criar a nova, para que
    // qualquer requisicao em curso falhe com erro claro de cancel
    // em vez de NPE.
    previous?.close(force: false);
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

    // Bug UUUUU: o InterceptorsWrapper antigo tinha BLOCOS VAZIOS
    // (`if (options.data != null) {}` e `if (error.response != null) {}`)
    // que so chamavam handler.next sem nenhum efeito util — codigo morto
    // que dava falsa impressao de que havia logging/observabilidade.
    // Removido para evitar overhead de chamadas de interceptor sem
    // proposito (ainda que pequeno, multiplica por toda requisicao).
    // Quando precisarmos de logs ou tracing, adicionamos um interceptor
    // real (LogInterceptor do dio, ou customizado).

    return dio;
  }

  static bool get isInitialized => _dioInstance != null;

  static void reset() {
    _dioInstance?.close();
    _dioInstance = null;
    _currentApiConfig = null;
  }
}
