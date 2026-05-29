import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_discovery_service.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_preferences_repository.dart';
import 'package:data7_expedicao/domain/repositories/i_thermal_printer_repository.dart';
import 'package:data7_expedicao/domain/services/i_app_config_service.dart';
import 'package:data7_expedicao/domain/services/no_op_printer_discovery_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/api_config_controller.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/printer_discovery_controller.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/printer_preferences_controller.dart';

export 'package:data7_expedicao/presentation/viewmodels/controllers/printer_discovery_controller.dart'
    show PrinterDiscoveryUiResult;
export 'package:data7_expedicao/presentation/viewmodels/controllers/printer_preferences_controller.dart'
    show PrinterTestUiResult;

class ConfigViewModel extends ChangeNotifier {
  late final ApiConfigController _apiController;
  late final PrinterPreferencesController _printerController;
  late final PrinterDiscoveryController _discoveryController;

  String _errorMessage = '';

  ConfigViewModel(
    IAppConfigService configService,
    IPrinterPreferencesRepository printerPreferencesRepository, [
    IPrinterDiscoveryService? printerDiscoveryService,
    IThermalPrinterRepository? thermalPrinterRepository,
  ]) {
    _apiController = ApiConfigController(configService, notify: _notify, setError: _setError);
    _printerController = PrinterPreferencesController(
      printerPreferencesRepository,
      thermalPrinterRepository,
      notify: _notify,
      setError: _setError,
    );
    _discoveryController = PrinterDiscoveryController(
      printerDiscoveryService ?? const NoOpPrinterDiscoveryService(),
      _printerController,
      notify: _notify,
      setError: _setError,
    );
  }

  ApiConfig get currentConfig => _apiController.currentConfig;
  bool get isLoading => _apiController.isLoading;
  bool get isTesting => _apiController.isTesting;
  bool get isSaving => _apiController.isSaving;
  bool get isLoadingPrinters => _printerController.isLoadingPrinters;
  bool get isDiscoveringPrinters => _discoveryController.isDiscoveringPrinters;
  bool get isTestingPrinter => _printerController.isTestingPrinter;
  String? get testingPrinterId => _printerController.testingPrinterId;
  bool get connectionTested => _apiController.connectionTested;
  String get errorMessage => _errorMessage;
  bool get hasConfig => _apiController.hasConfig;
  ScannerInputMode get scannerInputMode => _apiController.scannerInputMode;
  String get broadcastAction => _apiController.broadcastAction;
  String get broadcastExtraKey => _apiController.broadcastExtraKey;
  List<PrinterConfig> get printers => _printerController.printers;
  String? get defaultPrinterId => _printerController.defaultPrinterId;
  PrinterConfig? get defaultPrinter => _printerController.defaultPrinter;
  bool get isServerReady => hasConfig && _apiController.connectionTested;

  Future<void> loadConfig() async {
    try {
      _apiController.refreshConfig();
      await _printerController.loadPrintersInternal();
      _notify();
    } catch (e) {
      _setError('Erro ao carregar configuração: $e');
      _notify();
    }
  }

  void loadConfigSilent() {
    _apiController.loadConfigSilent();
  }

  Future<void> initialize() async {
    try {
      _apiController.refreshConfig();
      await _printerController.loadPrintersInternal();

      if (hasConfig) {
        await testConnection();
      }

      _notify();
    } catch (e) {
      _setError('Erro ao carregar configuração: $e');
      _notify();
    }
  }

  Future<void> saveConfig({required String apiUrl, required String apiPort, required bool useHttps}) {
    return _apiController.saveConfig(
      apiUrl: apiUrl,
      apiPort: apiPort,
      useHttps: useHttps,
      runConnectionTest: () => testConnection(),
    );
  }

  Future<void> resetToDefault() async {
    _apiController.setLoading(true);

    try {
      _setError('');
      await _apiController.clearConfigService();
      await _printerController.clearPreferencesRepo();
      _apiController.resetConfigState();
      _printerController.resetPrinterState();
    } catch (e) {
      _setError('Erro ao resetar configuração: $e');
    } finally {
      _apiController.setLoading(false);
    }
  }

  Future<void> resetServerConfig() {
    return _apiController.resetServerConfig();
  }

  Future<void> saveScannerPreferences({required ScannerInputMode mode, String? action, String? extraKey}) {
    return _apiController.saveScannerPreferences(mode: mode, action: action, extraKey: extraKey);
  }

  Future<void> loadPrinters() {
    return _printerController.loadPrinters();
  }

  Future<void> addPrinter({required String name, required String ip, required int port}) {
    return _printerController.addPrinter(name: name, ip: ip, port: port);
  }

  Future<void> updatePrinter(PrinterConfig printer) {
    return _printerController.updatePrinter(printer);
  }

  Future<void> removePrinter(String printerId) {
    return _printerController.removePrinter(printerId);
  }

  Future<void> setDefaultPrinter(String printerId) {
    return _printerController.setDefaultPrinter(printerId);
  }

  Future<PrinterDiscoveryUiResult> discoverPrintersInNetwork({int port = 9100}) {
    return _discoveryController.discoverInNetwork(port: port);
  }

  Future<PrinterDiscoveryUiResult> discoverPrintersInRange({
    required String subnetPrefix,
    required int startHost,
    required int endHost,
    int port = 9100,
  }) {
    return _discoveryController.discoverInRange(
      subnetPrefix: subnetPrefix,
      startHost: startHost,
      endHost: endHost,
      port: port,
    );
  }

  Future<String?> getSuggestedSubnetPrefix() {
    return _discoveryController.getSuggestedSubnetPrefix();
  }

  Future<PrinterTestUiResult> testPrinter(PrinterConfig printer) {
    return _printerController.testPrinter(printer);
  }

  Future<bool> testConnection({String? apiUrl, String? apiPort, bool? useHttps}) {
    return _apiController.testConnection(apiUrl: apiUrl, apiPort: apiPort, useHttps: useHttps);
  }

  void clearError() {
    _errorMessage = '';
    _notify();
  }

  void _notify() {
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
  }
}
