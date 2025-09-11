import 'package:hive_flutter/hive_flutter.dart';

import 'package:exp/domain/models/api_config.dart';

class ConfigService {
  static const String _boxName = 'config';
  static const String _apiConfigKey = 'api_config';

  late Box _configBox;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ApiConfigAdapter());
    }

    _configBox = await Hive.openBox(_boxName);
    _initialized = true;
  }

  Future<void> saveApiConfig(ApiConfig config) async {
    _ensureInitialized();
    config.lastUpdated = DateTime.now();
    await _configBox.put(_apiConfigKey, config);
  }

  ApiConfig getApiConfig() {
    _ensureInitialized();
    final config = _configBox.get(_apiConfigKey);

    if (config is ApiConfig) {
      return config;
    }

    return ApiConfig.defaultConfig;
  }

  Future<void> clearConfig() async {
    _ensureInitialized();
    await _configBox.clear();
  }

  bool hasApiConfig() {
    _ensureInitialized();
    return _configBox.containsKey(_apiConfigKey);
  }

  Future<void> dispose() async {
    if (_initialized) {
      await _configBox.close();
      _initialized = false;
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'ConfigService não foi inicializado. Chame initialize() primeiro.',
      );
    }
  }
}
