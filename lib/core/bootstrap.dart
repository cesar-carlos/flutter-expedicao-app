import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/core/network/dio_config.dart';
import 'package:data7_expedicao/core/network/network_initializer.dart';
import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/data/datasources/user_preferences_service.dart';
import 'package:data7_expedicao/domain/viewmodels/app_update_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/theme_viewmodel.dart';
import 'package:data7_expedicao/infrastructure/services/logger_service.dart';

class BootstrapResult {
  const BootstrapResult({
    required this.configViewModel,
    required this.themeViewModel,
    required this.socketViewModel,
    required this.appUpdateViewModel,
  });

  final ConfigViewModel configViewModel;
  final ThemeViewModel themeViewModel;
  final SocketViewModel socketViewModel;
  final AppUpdateViewModel appUpdateViewModel;
}

Future<BootstrapResult> bootstrap() async {
  const isIntegrationTest = bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false);
  await dotenv.load(fileName: isIntegrationTest ? 'integration_test/.env' : '.env');

  setupLocator();

  LoggerService.initialize(level: kDebugMode ? Level.ALL : Level.INFO);

  await locator<MetricsCollector>().init();

  final configService = locator<ConfigService>();
  await configService.initialize();

  final configViewModel = locator<ConfigViewModel>();
  await configViewModel.initialize();

  DioConfig.initialize(configViewModel.currentConfig);

  if (!isIntegrationTest) {
    await NetworkInitializer.initializeSocketService();
  }

  final socketViewModel = locator<SocketViewModel>();
  if (!isIntegrationTest) {
    socketViewModel.initialize();
  }

  final userPreferencesService = locator<UserPreferencesService>();
  final themeViewModel = ThemeViewModel(userPreferencesService);
  await themeViewModel.initialize();

  final appUpdateViewModel = await locator.getAsync<AppUpdateViewModel>();

  return BootstrapResult(
    configViewModel: configViewModel,
    themeViewModel: themeViewModel,
    socketViewModel: socketViewModel,
    appUpdateViewModel: appUpdateViewModel,
  );
}
