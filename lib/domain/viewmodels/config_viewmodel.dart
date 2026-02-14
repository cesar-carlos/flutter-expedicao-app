import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/network/network_initializer.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_preferences_repository.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/domain/repositories/i_thermal_printer_repository.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_discovery_service.dart';
import 'package:data7_expedicao/domain/services/no_op_printer_discovery_service.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class ConfigViewModel extends ChangeNotifier {
  final ConfigService _configService;
  final IPrinterPreferencesRepository _printerPreferencesRepository;
  final IPrinterDiscoveryService _printerDiscoveryService;
  final IThermalPrinterRepository? _thermalPrinterRepository;
  final Uuid _uuid = const Uuid();
  ApiConfig _currentConfig = ApiConfig.defaultConfig;
  List<PrinterConfig> _printers = const [];
  String? _defaultPrinterId;

  bool _isLoading = false;
  bool _isTesting = false;
  bool _isSaving = false;
  bool _isLoadingPrinters = false;
  bool _isDiscoveringPrinters = false;
  bool _isTestingPrinter = false;
  String? _testingPrinterId;
  bool _connectionTested = false;
  String _errorMessage = '';

  ConfigViewModel(
    this._configService,
    this._printerPreferencesRepository, [
    IPrinterDiscoveryService? printerDiscoveryService,
    IThermalPrinterRepository? thermalPrinterRepository,
  ]) : _printerDiscoveryService = printerDiscoveryService ?? const NoOpPrinterDiscoveryService(),
       _thermalPrinterRepository = thermalPrinterRepository;

  ApiConfig get currentConfig => _currentConfig;
  bool get isLoading => _isLoading;
  bool get isTesting => _isTesting;
  bool get isSaving => _isSaving;
  bool get isLoadingPrinters => _isLoadingPrinters;
  bool get isDiscoveringPrinters => _isDiscoveringPrinters;
  bool get isTestingPrinter => _isTestingPrinter;
  String? get testingPrinterId => _testingPrinterId;
  bool get connectionTested => _connectionTested;
  String get errorMessage => _errorMessage;
  bool get hasConfig => _configService.hasApiConfig();
  ScannerInputMode get scannerInputMode => _currentConfig.scannerInputMode;
  String get broadcastAction => _currentConfig.broadcastAction ?? '';
  String get broadcastExtraKey => _currentConfig.broadcastExtraKey ?? '';
  List<PrinterConfig> get printers => List.unmodifiable(_printers);
  String? get defaultPrinterId => _defaultPrinterId;
  PrinterConfig? get defaultPrinter {
    if (_defaultPrinterId == null) return null;
    for (final printer in _printers) {
      if (printer.id == _defaultPrinterId) {
        return printer;
      }
    }
    return null;
  }

  bool get isServerReady => hasConfig && _connectionTested;

  Future<void> loadConfig() async {
    try {
      _errorMessage = '';
      _currentConfig = _configService.getApiConfig();
      await _loadPrintersInternal();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar configuração: $e';
      notifyListeners();
    }
  }

  void loadConfigSilent() {
    try {
      _errorMessage = '';
      _currentConfig = _configService.getApiConfig();
    } catch (e) {
      _errorMessage = 'Erro ao carregar configuração: $e';
    }
  }

  Future<void> initialize() async {
    try {
      _errorMessage = '';
      _currentConfig = _configService.getApiConfig();
      await _loadPrintersInternal();

      if (hasConfig) {
        await testConnection();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar configuração: $e';
      notifyListeners();
    }
  }

  Future<void> saveConfig({required String apiUrl, required String apiPort, required bool useHttps}) async {
    _setSaving(true);

    try {
      _errorMessage = '';

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

        await testConnection();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setSaving(false);
    }
  }

  Future<void> resetToDefault() async {
    _setLoading(true);

    try {
      _errorMessage = '';
      await _configService.clearConfig();
      await _printerPreferencesRepository.clear();
      _currentConfig = ApiConfig.defaultConfig;
      _printers = const [];
      _defaultPrinterId = null;
      _connectionTested = false;
    } catch (e) {
      _errorMessage = 'Erro ao resetar configuração: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetServerConfig() async {
    _setLoading(true);

    try {
      _errorMessage = '';
      await _configService.clearConfig();
      _currentConfig = ApiConfig.defaultConfig;
      _connectionTested = false;
    } catch (e) {
      _errorMessage = 'Erro ao resetar configuração: $e';
    } finally {
      _setLoading(false);
    }
  }

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

  Future<void> loadPrinters() async {
    _setLoadingPrinters(true);
    try {
      await _loadPrintersInternal();
    } catch (e) {
      _errorMessage = 'Erro ao carregar impressoras: $e';
    } finally {
      _setLoadingPrinters(false);
      notifyListeners();
    }
  }

  Future<void> addPrinter({required String name, required String ip, required int port}) async {
    final normalizedName = name.trim();
    final normalizedIp = ip.trim();

    if (normalizedName.isEmpty) {
      _errorMessage = 'Nome da impressora e obrigatorio';
      notifyListeners();
      return;
    }

    if (normalizedIp.isEmpty) {
      _errorMessage = 'IP ou host da impressora e obrigatorio';
      notifyListeners();
      return;
    }

    if (port < 1 || port > 65535) {
      _errorMessage = 'Porta da impressora deve estar entre 1 e 65535';
      notifyListeners();
      return;
    }

    final endpointKey = _buildEndpointKey(normalizedIp, port);
    final hasDuplicateEndpoint = _printers.any((item) => _buildEndpointKey(item.ip, item.port) == endpointKey);
    if (hasDuplicateEndpoint) {
      _errorMessage = 'Ja existe uma impressora cadastrada para $normalizedIp:$port.';
      notifyListeners();
      return;
    }

    _errorMessage = '';
    final newPrinter = PrinterConfig(id: _uuid.v4(), name: normalizedName, ip: normalizedIp, port: port);

    _printers = [..._printers, newPrinter];
    _defaultPrinterId ??= newPrinter.id;
    await _persistPrinters();
    notifyListeners();
  }

  Future<void> updatePrinter(PrinterConfig printer) async {
    final normalizedName = printer.name.trim();
    final normalizedIp = printer.ip.trim();

    if (normalizedName.isEmpty) {
      _errorMessage = 'Nome da impressora e obrigatorio';
      notifyListeners();
      return;
    }

    if (normalizedIp.isEmpty) {
      _errorMessage = 'IP ou host da impressora e obrigatorio';
      notifyListeners();
      return;
    }

    if (printer.port < 1 || printer.port > 65535) {
      _errorMessage = 'Porta da impressora deve estar entre 1 e 65535';
      notifyListeners();
      return;
    }

    final index = _printers.indexWhere((item) => item.id == printer.id);
    if (index == -1) {
      _errorMessage = 'Impressora nao encontrada para atualizacao';
      notifyListeners();
      return;
    }

    final endpointKey = _buildEndpointKey(normalizedIp, printer.port);
    final hasDuplicateEndpoint = _printers.any(
      (item) => item.id != printer.id && _buildEndpointKey(item.ip, item.port) == endpointKey,
    );
    if (hasDuplicateEndpoint) {
      _errorMessage = 'Ja existe outra impressora cadastrada para $normalizedIp:${printer.port}.';
      notifyListeners();
      return;
    }

    _errorMessage = '';
    final updated = [..._printers];
    updated[index] = printer.copyWith(name: normalizedName, ip: normalizedIp);
    _printers = updated;
    await _persistPrinters();
    notifyListeners();
  }

  Future<void> removePrinter(String printerId) async {
    _errorMessage = '';
    _printers = _printers.where((item) => item.id != printerId).toList();

    if (_defaultPrinterId == printerId) {
      _defaultPrinterId = _printers.isNotEmpty ? _printers.first.id : null;
    }

    await _persistPrinters();
    notifyListeners();
  }

  Future<void> setDefaultPrinter(String printerId) async {
    final exists = _printers.any((item) => item.id == printerId);
    if (!exists) {
      _errorMessage = 'Impressora não encontrada para definir padrão';
      notifyListeners();
      return;
    }

    _errorMessage = '';
    _defaultPrinterId = printerId;
    await _persistPrinters();
    notifyListeners();
  }

  Future<PrinterDiscoveryUiResult> discoverPrintersInNetwork({int port = 9100}) async {
    if (_isDiscoveringPrinters) {
      return const PrinterDiscoveryUiResult(
        isSuccess: false,
        foundCount: 0,
        addedCount: 0,
        subnet: null,
        message: 'Ja existe uma busca em andamento.',
      );
    }

    _setDiscoveringPrinters(true);

    try {
      _errorMessage = '';
      final report = await _printerDiscoveryService.discover(port: port);

      final existingKeys = _printers.map((item) => '${item.ip}:${item.port}').toSet();

      var addedCount = 0;
      final updatedPrinters = [..._printers];

      for (final endpoint in report.endpoints) {
        final key = '${endpoint.ip}:${endpoint.port}';
        if (existingKeys.contains(key)) {
          continue;
        }

        updatedPrinters.add(
          PrinterConfig(id: _uuid.v4(), name: 'Impressora ${endpoint.ip}', ip: endpoint.ip, port: endpoint.port),
        );
        existingKeys.add(key);
        addedCount++;
      }

      _printers = updatedPrinters;
      _defaultPrinterId ??= _printers.isNotEmpty ? _printers.first.id : null;

      if (addedCount > 0) {
        await _persistPrinters();
      }

      notifyListeners();

      if (report.endpoints.isEmpty) {
        return PrinterDiscoveryUiResult(
          isSuccess: true,
          foundCount: 0,
          addedCount: 0,
          subnet: report.subnet,
          message: 'Nenhum dispositivo respondeu na porta $port em ${report.subnet}.',
        );
      }

      if (addedCount == 0) {
        return PrinterDiscoveryUiResult(
          isSuccess: true,
          foundCount: report.endpoints.length,
          addedCount: 0,
          subnet: report.subnet,
          message: '${report.endpoints.length} dispositivo(s) encontrado(s), mas todos ja estavam cadastrados.',
        );
      }

      return PrinterDiscoveryUiResult(
        isSuccess: true,
        foundCount: report.endpoints.length,
        addedCount: addedCount,
        subnet: report.subnet,
        message: '$addedCount nova(s) impressora(s) adicionada(s) em ${report.subnet}.',
      );
    } on StateError catch (e) {
      final message = e.message;
      _errorMessage = message;
      notifyListeners();
      return PrinterDiscoveryUiResult(isSuccess: false, foundCount: 0, addedCount: 0, subnet: null, message: message);
    } catch (e) {
      final message = 'Erro ao buscar impressoras: $e';
      _errorMessage = message;
      notifyListeners();
      return PrinterDiscoveryUiResult(isSuccess: false, foundCount: 0, addedCount: 0, subnet: null, message: message);
    } finally {
      _setDiscoveringPrinters(false);
    }
  }

  Future<PrinterDiscoveryUiResult> discoverPrintersInRange({
    required String subnetPrefix,
    required int startHost,
    required int endHost,
    int port = 9100,
  }) async {
    if (_isDiscoveringPrinters) {
      return const PrinterDiscoveryUiResult(
        isSuccess: false,
        foundCount: 0,
        addedCount: 0,
        subnet: null,
        message: 'Ja existe uma busca em andamento.',
      );
    }

    _setDiscoveringPrinters(true);

    try {
      _errorMessage = '';
      final report = await _printerDiscoveryService.discover(
        port: port,
        subnetPrefix: subnetPrefix,
        startHost: startHost,
        endHost: endHost,
      );

      final existingKeys = _printers.map((item) => '${item.ip}:${item.port}').toSet();

      var addedCount = 0;
      final updatedPrinters = [..._printers];

      for (final endpoint in report.endpoints) {
        final key = '${endpoint.ip}:${endpoint.port}';
        if (existingKeys.contains(key)) {
          continue;
        }

        updatedPrinters.add(
          PrinterConfig(id: _uuid.v4(), name: 'Impressora ${endpoint.ip}', ip: endpoint.ip, port: endpoint.port),
        );
        existingKeys.add(key);
        addedCount++;
      }

      _printers = updatedPrinters;
      _defaultPrinterId ??= _printers.isNotEmpty ? _printers.first.id : null;

      if (addedCount > 0) {
        await _persistPrinters();
      }

      notifyListeners();

      if (report.endpoints.isEmpty) {
        return PrinterDiscoveryUiResult(
          isSuccess: true,
          foundCount: 0,
          addedCount: 0,
          subnet: report.subnet,
          message: 'Nenhum dispositivo respondeu na porta $port em ${report.subnet}.',
        );
      }

      if (addedCount == 0) {
        return PrinterDiscoveryUiResult(
          isSuccess: true,
          foundCount: report.endpoints.length,
          addedCount: 0,
          subnet: report.subnet,
          message: '${report.endpoints.length} dispositivo(s) encontrado(s), mas todos ja estavam cadastrados.',
        );
      }

      return PrinterDiscoveryUiResult(
        isSuccess: true,
        foundCount: report.endpoints.length,
        addedCount: addedCount,
        subnet: report.subnet,
        message: '$addedCount nova(s) impressora(s) adicionada(s) em ${report.subnet}.',
      );
    } on StateError catch (e) {
      final message = e.message;
      _errorMessage = message;
      notifyListeners();
      return PrinterDiscoveryUiResult(isSuccess: false, foundCount: 0, addedCount: 0, subnet: null, message: message);
    } catch (e) {
      final message = 'Erro ao buscar impressoras: $e';
      _errorMessage = message;
      notifyListeners();
      return PrinterDiscoveryUiResult(isSuccess: false, foundCount: 0, addedCount: 0, subnet: null, message: message);
    } finally {
      _setDiscoveringPrinters(false);
    }
  }

  Future<String?> getSuggestedSubnetPrefix() async {
    return _printerDiscoveryService.detectLocalSubnetPrefix();
  }

  Future<PrinterTestUiResult> testPrinter(PrinterConfig printer) async {
    if (_isTestingPrinter) {
      return const PrinterTestUiResult(isSuccess: false, message: 'Ja existe um teste de impressora em andamento.');
    }

    _setTestingPrinter(true, printer.id);
    _errorMessage = '';
    notifyListeners();

    try {
      final thermalPrinterRepository = _thermalPrinterRepository;
      if (thermalPrinterRepository == null) {
        const message = 'Servico de impressao nao esta disponivel.';
        _errorMessage = message;
        notifyListeners();
        return const PrinterTestUiResult(isSuccess: false, message: message);
      }

      final result = await thermalPrinterRepository.printTestTicket(printer: printer);
      final success = result.getOrNull();

      if (success != null) {
        return PrinterTestUiResult(
          isSuccess: true,
          message: 'Teste enviado para ${printer.name} (${printer.ip}:${printer.port}).',
          elapsed: success.elapsed,
        );
      }

      final failure = result.exceptionOrNull();
      final message = _extractPrinterFailureMessage(failure);
      _errorMessage = message;
      notifyListeners();
      return PrinterTestUiResult(isSuccess: false, message: message);
    } catch (e) {
      final message = 'Erro ao testar impressora: $e';
      _errorMessage = message;
      notifyListeners();
      return PrinterTestUiResult(isSuccess: false, message: message);
    } finally {
      _setTestingPrinter(false);
    }
  }

  Future<void> _loadPrintersInternal() async {
    final loadedPrinters = await _printerPreferencesRepository.loadPrinters();
    var loadedDefaultId = await _printerPreferencesRepository.loadDefaultPrinterId();

    if (loadedDefaultId != null && !loadedPrinters.any((item) => item.id == loadedDefaultId)) {
      loadedDefaultId = null;
    }

    _printers = loadedPrinters;
    _defaultPrinterId = loadedDefaultId ?? (loadedPrinters.isNotEmpty ? loadedPrinters.first.id : null);
  }

  Future<void> _persistPrinters() async {
    await _printerPreferencesRepository.savePrinters(_printers);
    await _printerPreferencesRepository.saveDefaultPrinterId(_defaultPrinterId);
  }

  Future<bool> testConnection({String? apiUrl, String? apiPort, bool? useHttps}) async {
    _setTesting(true);

    try {
      _errorMessage = '';

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
          _errorMessage = 'Resposta inválida do servidor';
          AppLogger.debug('Unexpected server handshake payload: $data', tag: 'Config');
          return false;
        }
      } else {
        _connectionTested = false;
        _errorMessage = 'Falha na conexão: Status ${response.statusCode}';
        return false;
      }
    } on DioException catch (e) {
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

  void _setLoadingPrinters(bool loading) {
    _isLoadingPrinters = loading;
    notifyListeners();
  }

  void _setDiscoveringPrinters(bool discovering) {
    _isDiscoveringPrinters = discovering;
    notifyListeners();
  }

  void _setTestingPrinter(bool testing, [String? printerId]) {
    _isTestingPrinter = testing;
    _testingPrinterId = testing ? printerId : null;
    notifyListeners();
  }

  String _extractPrinterFailureMessage(Object? failure) {
    if (failure is AppFailure) {
      return failure.message;
    }

    if (failure != null) {
      return failure.toString();
    }

    return 'Falha ao testar impressora.';
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

  String _buildEndpointKey(String ip, int port) {
    return '${ip.trim().toLowerCase()}:$port';
  }
}

class PrinterDiscoveryUiResult {
  final bool isSuccess;
  final int foundCount;
  final int addedCount;
  final String? subnet;
  final String message;

  const PrinterDiscoveryUiResult({
    required this.isSuccess,
    required this.foundCount,
    required this.addedCount,
    required this.subnet,
    required this.message,
  });
}

class PrinterTestUiResult {
  final bool isSuccess;
  final String message;
  final Duration? elapsed;

  const PrinterTestUiResult({required this.isSuccess, required this.message, this.elapsed});
}
