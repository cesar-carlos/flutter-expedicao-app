import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';

/// Implementação em memória do ConfigService para testes
class ConfigServiceMock implements ConfigService {
  ApiConfig? _apiConfig;
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> saveApiConfig(ApiConfig config) async {
    _ensureInitialized();
    _apiConfig = config;
  }

  @override
  ApiConfig getApiConfig() {
    _ensureInitialized();
    return _apiConfig ?? ApiConfig.defaultConfig;
  }

  @override
  Future<void> clearConfig() async {
    _ensureInitialized();
    _apiConfig = null;
  }

  @override
  bool hasApiConfig() {
    _ensureInitialized();
    return _apiConfig != null;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
    _apiConfig = null;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('ConfigService não foi inicializado. Chame initialize() primeiro.');
    }
  }
}
