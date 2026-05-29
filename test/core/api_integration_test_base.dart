import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_preferences_repository.dart';
import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';

/// Classe base para testes de integração que usam API
abstract class ApiIntegrationTestBase {
  /// Diretório Hive por isolate; mantido entre setup/tearDown para não chamar [Hive.init] duas vezes.
  static Directory? _hiveTestDir;

  /// Configuração padrão para testes
  static ApiConfig get testConfig =>
      ApiConfig(apiUrl: 'localhost', apiPort: 3001, useHttps: false, lastUpdated: DateTime.now());

  /// Inicializa o ambiente de teste com API
  static Future<void> setupApi() async {
    _hiveTestDir ??= await Directory.systemTemp.createTemp('exp_api_integration_');

    // Registra o serviço de configuração
    if (!GetIt.I.isRegistered<ConfigService>()) {
      final configService = ConfigService();
      GetIt.I.registerSingleton<ConfigService>(configService);
      GetIt.I.registerSingleton<IPrinterPreferencesRepository>(_FakePrinterPreferencesRepository());
      GetIt.I.registerSingleton<ConfigViewModel>(
        ConfigViewModel(configService, GetIt.I<IPrinterPreferencesRepository>()),
      );
    }

    // Configura a API
    final configService = GetIt.I<ConfigService>();
    await configService.initialize(hivePathForTests: _hiveTestDir!.path);
    await configService.saveApiConfig(testConfig);

    // Aguarda um pouco para garantir que tudo está configurado
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Limpa recursos da API após os testes
  static Future<void> tearDownApi() async {
    // Limpa a configuração e reseta o GetIt
    final configService = GetIt.I<ConfigService>();
    await configService.clearConfig();
    await configService.dispose();
    await GetIt.I.reset();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Aguarda a conclusão de uma operação
  static Future<void> waitForOperation() async {
    await Future.delayed(const Duration(seconds: 3));
  }
}

class _FakePrinterPreferencesRepository implements IPrinterPreferencesRepository {
  @override
  Future<List<PrinterConfig>> loadPrinters() async => [];

  @override
  Future<void> savePrinters(List<PrinterConfig> printers) async {}

  @override
  Future<String?> loadDefaultPrinterId() async => null;

  @override
  Future<void> saveDefaultPrinterId(String? printerId) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<PrinterConfig?> getDefaultPrinter() async => null;
}
