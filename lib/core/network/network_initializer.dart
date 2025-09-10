import 'package:exp/core/network/dio_config.dart';
import 'package:exp/core/network/socket_config.dart';
import 'package:exp/di/locator.dart';
import 'package:exp/domain/viewmodels/config_viewmodel.dart';
import 'package:exp/data/datasources/config_service.dart';
import 'package:exp/data/services/socket_service.dart';

class NetworkInitializer {
  static void ensureDioInitialized() {
    if (!DioConfig.isInitialized) {
      final configService = locator<ConfigService>();
      if (!configService.isInitialized) {
        throw StateError(
          'ConfigService deve ser inicializado antes de usar serviços de rede',
        );
      }

      final configViewModel = locator<ConfigViewModel>();
      DioConfig.initialize(configViewModel.currentConfig);
    }
  }

  static void ensureSocketInitialized() {
    if (!SocketConfig.isInitialized) {
      final configService = locator<ConfigService>();
      if (!configService.isInitialized) {
        throw StateError(
          'ConfigService deve ser inicializado antes de usar serviços de rede',
        );
      }

      final configViewModel = locator<ConfigViewModel>();
      SocketConfig.initialize(configViewModel.currentConfig);
    }
  }

  static Future<void> initializeSocketService() async {
    final configViewModel = locator<ConfigViewModel>();
    final socketService = locator<SocketService>();

    await socketService.initialize(configViewModel.currentConfig);
  }

  static void reinitializeDio() {
    final configViewModel = locator<ConfigViewModel>();
    DioConfig.updateConfig(configViewModel.currentConfig);
  }

  static void reinitializeSocket() {
    final configViewModel = locator<ConfigViewModel>();
    SocketConfig.updateConfig(configViewModel.currentConfig);
  }

  static bool get isNetworkReady {
    try {
      final configService = locator<ConfigService>();
      return configService.isInitialized && DioConfig.isInitialized;
    } catch (e) {
      return false;
    }
  }

  static bool get isSocketReady {
    try {
      final configService = locator<ConfigService>();
      return configService.isInitialized && SocketConfig.isInitialized;
    } catch (e) {
      return false;
    }
  }
}
