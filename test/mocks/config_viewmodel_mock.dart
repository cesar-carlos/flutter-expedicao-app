import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';
import 'fake_printer_preferences_repository.dart';

/// Mock do ConfigViewModel para testes
class ConfigViewModelMock extends ConfigViewModel {
  ConfigViewModelMock(ConfigService configService)
      : super(configService, FakePrinterPreferencesRepository());

  @override
  bool get isServerReady => true;

  @override
  Future<bool> testConnection({String? apiUrl, String? apiPort, bool? useHttps}) async {
    return true;
  }

  @override
  Future<void> initialize() async {
    // Não faz nada
  }
}
