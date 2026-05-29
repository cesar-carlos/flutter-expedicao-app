import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/services/i_app_config_service.dart';
import 'package:data7_expedicao/data/models/api_config_entity.dart';

class ConfigService implements IAppConfigService {
  static const String _boxName = 'config';
  static const String _apiConfigKey = 'api_config';

  /// Evita chamar [Hive.init] mais de uma vez no mesmo isolate (testes).
  static bool _hiveInitedWithTestPath = false;

  late Box _configBox;
  bool _initialized = false;

  /// Bug CCCCC: guard anti-race para evitar 2 chamadas simultaneas
  /// de initialize() — antes, ambas podiam passar pelo check
  /// `if (_initialized) return` e tentar Hive.openBox(boxName) duas
  /// vezes (causando "Box already open" ou estado corrompido).
  Completer<void>? _initCompleter;

  bool get isInitialized => _initialized;

  /// [hivePathForTests] usa [Hive.init] em disco temporário (sem path_provider).
  /// Não use em produção; apenas em testes de integração que precisam de HTTP real.
  Future<void> initialize({String? hivePathForTests}) async {
    if (_initialized) return;
    if (_initCompleter != null) {
      // Inicializacao em curso por outro caller — apenas aguarda.
      return _initCompleter!.future;
    }

    final completer = Completer<void>();
    _initCompleter = completer;

    try {
      if (hivePathForTests != null) {
        if (!_hiveInitedWithTestPath) {
          Hive.init(hivePathForTests);
          _hiveInitedWithTestPath = true;
        }
      } else {
        await Hive.initFlutter();
      }

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ApiConfigEntityAdapter());
      }

      _configBox = await Hive.openBox(_boxName);
      _initialized = true;
      completer.complete();
    } catch (e, s) {
      completer.completeError(e, s);
      // Permite nova tentativa apos falha (nao trava o servico para sempre).
      _initCompleter = null;
      rethrow;
    }
  }

  @override
  Future<void> saveApiConfig(ApiConfig config) async {
    _ensureInitialized();
    final entity = ApiConfigEntity.fromDomain(config);
    await _configBox.put(_apiConfigKey, entity);
  }

  @override
  ApiConfig getApiConfig() {
    _ensureInitialized();
    final entity = _configBox.get(_apiConfigKey);

    if (entity is ApiConfigEntity) {
      return entity.toDomain();
    }

    return ApiConfig.defaultConfig;
  }

  @override
  Future<void> clearConfig() async {
    _ensureInitialized();
    await _configBox.clear();
  }

  @override
  bool hasApiConfig() {
    _ensureInitialized();
    return _configBox.containsKey(_apiConfigKey);
  }

  Future<void> dispose() async {
    if (_initialized) {
      await _configBox.close();
      _initialized = false;
      // Permite re-initializacao apos dispose().
      _initCompleter = null;
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('ConfigService não foi inicializado. Chame initialize() primeiro.');
    }
  }
}
