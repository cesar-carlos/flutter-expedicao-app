import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/network/network_initializer.dart';
import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

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
  ScannerInputMode get scannerInputMode => _currentConfig.scannerInputMode;
  String get broadcastAction => _currentConfig.broadcastAction ?? '';
  String get broadcastExtraKey => _currentConfig.broadcastExtraKey ?? '';

  /// Verifica se o servidor está configurado e testado
  bool get isServerReady => hasConfig && _connectionTested;

  /// Carrega a configuração atual
  Future<void> loadConfig() async {
    try {
      _errorMessage = '';
      _currentConfig = _configService.getApiConfig();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar configuração: $e';
      notifyListeners();
    }
  }

  /// Carrega a configuração sem notificar listeners (para inicialização)
  void loadConfigSilent() {
    try {
      _errorMessage = '';
      _currentConfig = _configService.getApiConfig();
    } catch (e) {
      _errorMessage = 'Erro ao carregar configuração: $e';
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
      _errorMessage = 'Erro ao carregar configuração: $e';
      notifyListeners();
    }
  }

  /// Salva uma nova configuração
  Future<void> saveConfig({required String apiUrl, required String apiPort, required bool useHttps}) async {
    _setSaving(true);

    try {
      _errorMessage = '';

      // Valida os dados
      final port = int.tryParse(apiPort);
      if (port == null || port < 1 || port > 65535) {
        throw ArgumentError('Porta deve ser um número entre 1 e 65535');
      }

      if (apiUrl.trim().isEmpty) {
        throw ArgumentError('URL da API não pode estar vazia');
      }

      // Cria nova configuração
      final newConfig = ApiConfig(
        apiUrl: apiUrl.trim(),
        apiPort: port,
        useHttps: useHttps,
        lastUpdated: DateTime.now(),
        scannerInputMode: _currentConfig.scannerInputMode,
        broadcastAction: _currentConfig.broadcastAction,
        broadcastExtraKey: _currentConfig.broadcastExtraKey,
      );

      // Verifica se a configuração mudou
      final configChanged =
          _currentConfig.apiUrl != newConfig.apiUrl ||
          _currentConfig.apiPort != newConfig.apiPort ||
          _currentConfig.useHttps != newConfig.useHttps;

      // Salva no Hive
      await _configService.saveApiConfig(newConfig);

      // Atualiza o estado
      _currentConfig = newConfig;

      // Só reseta o status de conexão testada se a configuração mudou
      if (configChanged) {
        _connectionTested = false;

        // Reinicializa os serviços de rede com a nova configuração
        NetworkInitializer.reinitializeDio();
        NetworkInitializer.reinitializeSocket();

        // Testa automaticamente a conexão após salvar uma nova configuração
        await testConnection();
      }
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
      _errorMessage = 'Erro ao resetar configuração: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Salva preferências do scanner (modo e dados de broadcast)
  Future<void> saveScannerPreferences({required ScannerInputMode mode, String? action, String? extraKey}) async {
    _setSaving(true);

    try {
      _errorMessage = '';
      final updated = _currentConfig.copyWith(
        scannerInputMode: mode,
        broadcastAction: action?.trim(),
        broadcastExtraKey: extraKey?.trim(),
        lastUpdated: DateTime.now(),
      );

      await _configService.saveApiConfig(updated);
      _currentConfig = updated;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setSaving(false);
    }
  }

  /// Testa a conexão com a API
  Future<bool> testConnection({String? apiUrl, String? apiPort, bool? useHttps}) async {
    _setTesting(true);

    try {
      _errorMessage = '';

      // Usa parâmetros fornecidos ou configuração atual
      final testUrl = apiUrl ?? _currentConfig.apiUrl;
      final testPort = apiPort != null ? int.tryParse(apiPort) ?? _currentConfig.apiPort : _currentConfig.apiPort;
      final testHttps = useHttps ?? _currentConfig.useHttps;

      if (testUrl.trim().isEmpty) {
        _errorMessage = 'URL da API não pode estar vazia';
        return false;
      }

      if (testPort < 1 || testPort > 65535) {
        _errorMessage = 'Porta deve ser um número entre 1 e 65535';
        return false;
      }

      // Monta URL de teste
      final protocol = testHttps ? 'https' : 'http';
      final fullUrl = '$protocol://$testUrl:$testPort/expedicao';
      AppLogger.debug('Testing connection to $fullUrl (https=$testHttps)', tag: 'Config');

      // Cria instância do Dio
      final dio = Dio();

      // Configura timeout
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      // Faz a requisição GET
      final response = await dio.get(fullUrl);
      AppLogger.debug('Response status: ${response.statusCode}, data: ${response.data}', tag: 'Config');

      // Verifica se o status é 200 e se a resposta contém a mensagem esperada
      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['message'] == 'Expedição API') {
          // Marca a conexão como testada com sucesso
          _connectionTested = true;
          return true;
        } else {
          _connectionTested = false;
          _errorMessage = 'Resposta inválida do servidor';
          return false;
        }
      } else {
        _connectionTested = false;
        _errorMessage = 'Falha na conexão: Status ${response.statusCode}';
        return false;
      }
    } on DioException catch (e) {
      // Trata diferentes tipos de erro do Dio
      _connectionTested = false;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          _errorMessage = 'Timeout de conexão';
          break;
        case DioExceptionType.receiveTimeout:
          _errorMessage = 'Timeout de resposta';
          break;
        case DioExceptionType.connectionError:
          _errorMessage = 'Erro de conexão - Verifique URL e porta';
          break;
        case DioExceptionType.badResponse:
          _errorMessage = 'Resposta inválida do servidor (${e.response?.statusCode})';
          break;
        default:
          _errorMessage = 'Erro na conexão: ${e.message}';
      }
      AppLogger.debug('DioException type=${e.type} code=${e.response?.statusCode} message=${e.message}', tag: 'Config');
      return false;
    } catch (e) {
      _connectionTested = false;
      _errorMessage = 'Erro inesperado: $e';
      AppLogger.error('Unexpected error while testing connection: $e', tag: 'Config', error: e);
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
