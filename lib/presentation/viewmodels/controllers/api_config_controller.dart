import 'package:dio/dio.dart';

import 'package:data7_expedicao/core/network/network_initializer.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/domain/services/i_app_config_service.dart';

class ApiConfigController {
  final IAppConfigService _configService;
  final void Function() _notify;
  final void Function(String message) _setError;

  ApiConfig _currentConfig = ApiConfig.defaultConfig;
  bool _isLoading = false;
  bool _isTesting = false;
  bool _isSaving = false;
  bool _connectionTested = false;

  ApiConfigController(
    this._configService, {
    required void Function() notify,
    required void Function(String message) setError,
  }) : _notify = notify,
       _setError = setError;

  ApiConfig get currentConfig => _currentConfig;
  bool get isLoading => _isLoading;
  bool get isTesting => _isTesting;
  bool get isSaving => _isSaving;
  bool get connectionTested => _connectionTested;
  bool get hasConfig => _configService.hasApiConfig();
  ScannerInputMode get scannerInputMode => _currentConfig.scannerInputMode;
  String get broadcastAction => _currentConfig.broadcastAction ?? '';
  String get broadcastExtraKey => _currentConfig.broadcastExtraKey ?? '';

  void refreshConfig() {
    _setError('');
    _currentConfig = _configService.getApiConfig();
  }

  void loadConfigSilent() {
    try {
      _setError('');
      _currentConfig = _configService.getApiConfig();
    } catch (e) {
      _setError('Erro ao carregar configuração: $e');
    }
  }

  Future<void> saveConfig({
    required String apiUrl,
    required String apiPort,
    required bool useHttps,
    required Future<bool> Function() runConnectionTest,
  }) async {
    setSaving(true);

    try {
      _setError('');

      final port = int.tryParse(apiPort);
      if (port == null || port < 1 || port > 65535) {
        throw ArgumentError('Porta deve ser um número entre 1 e 65535');
      }

      if (apiUrl.trim().isEmpty) {
        throw ArgumentError('URL da API não pode estar vazia');
      }

      final newConfig = ApiConfig(
        apiUrl: apiUrl.trim(),
        apiPort: port,
        useHttps: useHttps,
        lastUpdated: DateTime.now(),
        scannerInputMode: _currentConfig.scannerInputMode,
        broadcastAction: _currentConfig.broadcastAction,
        broadcastExtraKey: _currentConfig.broadcastExtraKey,
      );

      final configChanged =
          _currentConfig.apiUrl != newConfig.apiUrl ||
          _currentConfig.apiPort != newConfig.apiPort ||
          _currentConfig.useHttps != newConfig.useHttps;

      await _configService.saveApiConfig(newConfig);

      _currentConfig = newConfig;

      if (configChanged) {
        _connectionTested = false;

        NetworkInitializer.reinitializeDio();
        NetworkInitializer.reinitializeSocket();

        await runConnectionTest();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      setSaving(false);
    }
  }

  Future<void> clearConfigService() async {
    await _configService.clearConfig();
  }

  void resetConfigState() {
    _currentConfig = ApiConfig.defaultConfig;
    _connectionTested = false;
  }

  Future<void> resetServerConfig() async {
    setLoading(true);

    try {
      _setError('');
      await _configService.clearConfig();
      _currentConfig = ApiConfig.defaultConfig;
      _connectionTested = false;
    } catch (e) {
      _setError('Erro ao resetar configuração: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> saveScannerPreferences({required ScannerInputMode mode, String? action, String? extraKey}) async {
    setSaving(true);

    try {
      _setError('');
      final updated = _currentConfig.copyWith(
        scannerInputMode: mode,
        broadcastAction: action?.trim(),
        broadcastExtraKey: extraKey?.trim(),
        lastUpdated: DateTime.now(),
      );

      await _configService.saveApiConfig(updated);
      _currentConfig = updated;
    } catch (e) {
      _setError(e.toString());
    } finally {
      setSaving(false);
    }
  }

  Future<bool> testConnection({String? apiUrl, String? apiPort, bool? useHttps}) async {
    setTesting(true);

    try {
      _setError('');

      final testUrl = apiUrl ?? _currentConfig.apiUrl;
      final testPort = apiPort != null ? int.tryParse(apiPort) ?? _currentConfig.apiPort : _currentConfig.apiPort;
      final testHttps = useHttps ?? _currentConfig.useHttps;

      if (testUrl.trim().isEmpty) {
        _setError('URL da API não pode estar vazia');
        return false;
      }

      if (testPort < 1 || testPort > 65535) {
        _setError('Porta deve ser um número entre 1 e 65535');
        return false;
      }

      final protocol = testHttps ? 'https' : 'http';
      final fullUrl = '$protocol://$testUrl:$testPort/expedicao';
      AppLogger.debug('Testing connection to $fullUrl (https=$testHttps)', tag: 'Config');

      final dio = Dio();

      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get(fullUrl);
      AppLogger.debug('Response status: ${response.statusCode}, data: ${response.data}', tag: 'Config');

      if (response.statusCode == 200) {
        final data = response.data;
        if (_isExpectedConnectionResponse(data)) {
          _connectionTested = true;
          return true;
        } else {
          _connectionTested = false;
          _setError('Resposta inválida do servidor');
          AppLogger.debug('Unexpected server handshake payload: $data', tag: 'Config');
          return false;
        }
      } else {
        _connectionTested = false;
        _setError('Falha na conexão: Status ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      _connectionTested = false;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          _setError('Timeout de conexão');
          break;
        case DioExceptionType.receiveTimeout:
          _setError('Timeout de resposta');
          break;
        case DioExceptionType.connectionError:
          _setError('Erro de conexão - Verifique URL e porta');
          break;
        case DioExceptionType.badResponse:
          _setError('Resposta inválida do servidor (${e.response?.statusCode})');
          break;
        default:
          _setError('Erro na conexão: ${e.message}');
      }
      AppLogger.debug('DioException type=${e.type} code=${e.response?.statusCode} message=${e.message}', tag: 'Config');
      return false;
    } catch (e) {
      _connectionTested = false;
      _setError('Erro inesperado: $e');
      AppLogger.error('Unexpected error while testing connection: $e', tag: 'Config', error: e);
      return false;
    } finally {
      setTesting(false);
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    _notify();
  }

  void setTesting(bool testing) {
    _isTesting = testing;
    _notify();
  }

  void setSaving(bool saving) {
    _isSaving = saving;
    _notify();
  }

  bool _isExpectedConnectionResponse(dynamic data) {
    if (data == null) {
      return false;
    }

    if (data is Map<String, dynamic>) {
      final rawMessage = data['message'] ?? data['mensagem'];
      if (rawMessage is String) {
        return _isExpectedApiHandshake(rawMessage);
      }
      return false;
    }

    if (data is String) {
      return _isExpectedApiHandshake(data);
    }

    return false;
  }

  bool _isExpectedApiHandshake(String message) {
    final compactMessage = _normalizeForComparison(message).replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

    if (compactMessage.isEmpty) {
      return false;
    }

    return compactMessage.contains('expedicao api') || compactMessage.contains('expedition api');
  }

  String _normalizeForComparison(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }
}
