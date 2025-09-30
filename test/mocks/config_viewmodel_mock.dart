import 'package:exp/domain/viewmodels/config_viewmodel.dart';

/// Mock do ConfigViewModel para testes
class ConfigViewModelMock extends ConfigViewModel {
  ConfigViewModelMock(super.configService);

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
