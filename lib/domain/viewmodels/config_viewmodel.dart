import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:exp/domain/models/api_config.dart';
import 'package:exp/data/datasources/config_service.dart';
import 'package:exp/core/constants/app_strings.dart';

/// ViewModel para gerenciar configurações da API
class ConfigViewModel extends ChangeNotifier {
  final ConfigService _configService;
  ApiConfig _currentConfig = ApiConfig.defaultConfig;

  bool _isLoading = false;
  bool _isTesting = false;
  bool _isSaving = false;
  bool _connectionTested = false;
  String _errorMessage = '';

  ConfigViewModel(this._configService);

  // Getters
  ApiConfig get currentConfig => _currentConfig;
  bool get isLoading => _isLoading;
  bool get isTesting => _isTesting;
  bool get isSaving => _isSaving;
  bool get connectionTested => _connectionTested;
  String get errorMessage => _errorMessage;
  bool get hasConfig => _configService.hasApiConfig();

  /// Verifica se o servidor está configurado e testado
  bool get isServerReady => hasConfig && _connectionTested;

  /// Carrega a configuração atual
  Future<void> loadConfig() async {
    try {
      _errorMessage = '';
      _currentConfig = _configService.getApiConfig();
      notifyListeners();
    } catch (e) {
      _errorMessage = '${AppStrings.loadConfigError}: $e';
      notifyListeners();
    }
  }

  /// Carrega a configuração sem notificar listeners (para inicialização)
  void loadConfigSilent() {
    try {
      _errorMessage = '';
      _currentConfig = _configService.getApiConfig();
    } catch (e) {
      _errorMessage = '${AppStrings.loadConfigError}: $e';
    }
  }

  /// Inicializa o ViewModel e testa conexão automaticamente se já configurado
  Future<void> initialize() async {
    try {
      _errorMessage = '';
      _currentConfig = _configService.getApiConfig();

      // Se já tem configuração salva, testa a conexão automaticamente
      if (hasConfig) {
        await testConnection();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = '${AppStrings.loadConfigError}: $e';
      notifyListeners();
    }
  }

  /// Salva uma nova configuração
  Future<void> saveConfig({
    required String apiUrl,
    required String apiPort,
    required bool useHttps,
  }) async {
    _setSaving(true);

    try {
      _errorMessage = '';

      // Valida os dados
      final port = int.tryParse(apiPort);
      if (port == null || port < 1 || port > 65535) {
        throw ArgumentError(AppStrings.portRangeError);
      }

      if (apiUrl.trim().isEmpty) {
        throw ArgumentError(AppStrings.apiUrlEmptyError);
      }

      // Cria nova configuração
      final newConfig = ApiConfig(
        apiUrl: apiUrl.trim(),
        apiPort: port,
        useHttps: useHttps,
        lastUpdated: DateTime.now(),
      );

      // Salva no Hive
      await _configService.saveApiConfig(newConfig);

      // Atualiza o estado
      _currentConfig = newConfig;

      // Reseta o status de conexão testada pois a configuração mudou
      _connectionTested = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setSaving(false);
    }
  }

  /// Reseta para configuração padrão
  Future<void> resetToDefault() async {
    _setLoading(true);

    try {
      _errorMessage = '';
      await _configService.clearConfig();
      _currentConfig = ApiConfig.defaultConfig;
    } catch (e) {
      _errorMessage = '${AppStrings.resetConfigError}: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Testa a conexão com a API
  Future<bool> testConnection({
    String? apiUrl,
    String? apiPort,
    bool? useHttps,
  }) async {
    _setTesting(true);

    try {
      _errorMessage = '';

      // Usa parâmetros fornecidos ou configuração atual
      final testUrl = apiUrl ?? _currentConfig.apiUrl;
      final testPort = apiPort != null
          ? int.tryParse(apiPort) ?? _currentConfig.apiPort
          : _currentConfig.apiPort;
      final testHttps = useHttps ?? _currentConfig.useHttps;

      if (testUrl.trim().isEmpty) {
        _errorMessage = AppStrings.apiUrlEmptyError;
        return false;
      }

      if (testPort < 1 || testPort > 65535) {
        _errorMessage = AppStrings.portRangeError;
        return false;
      }

      // Monta URL de teste
      final protocol = testHttps
          ? AppStrings.httpsProtocol
          : AppStrings.httpProtocol;
      final fullUrl = '$protocol://$testUrl:$testPort${AppStrings.apiEndpoint}';

      // Cria instância do Dio
      final dio = Dio();

      // Configura timeout
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      // Faz a requisição GET
      final response = await dio.get(fullUrl);

      // Verifica se o status é 200 e se a resposta contém a mensagem esperada
      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> &&
            data['message'] == AppStrings.expectedApiMessage) {
          // Marca a conexão como testada com sucesso
          _connectionTested = true;
          return true;
        } else {
          _connectionTested = false;
          _errorMessage = AppStrings.invalidServerResponse;
          return false;
        }
      } else {
        _connectionTested = false;
        _errorMessage =
            '${AppStrings.connectionFailedStatus} ${response.statusCode}';
        return false;
      }
    } on DioException catch (e) {
      // Trata diferentes tipos de erro do Dio
      _connectionTested = false;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          _errorMessage = AppStrings.connectionTimeout;
          break;
        case DioExceptionType.receiveTimeout:
          _errorMessage = AppStrings.receiveTimeout;
          break;
        case DioExceptionType.connectionError:
          _errorMessage = AppStrings.connectionCheckError;
          break;
        case DioExceptionType.badResponse:
          _errorMessage =
              '${AppStrings.badServerResponse} (${e.response?.statusCode})';
          break;
        default:
          _errorMessage = '${AppStrings.connectionFailurePrefix}: ${e.message}';
      }
      return false;
    } catch (e) {
      _connectionTested = false;
      _errorMessage = '${AppStrings.unexpectedError}: $e';
      return false;
    } finally {
      _setTesting(false);
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setTesting(bool testing) {
    _isTesting = testing;
    notifyListeners();
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }
}
