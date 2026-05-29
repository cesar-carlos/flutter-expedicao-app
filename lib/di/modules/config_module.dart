import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_discovery_service.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_preferences_repository.dart';
import 'package:data7_expedicao/domain/repositories/i_thermal_printer_repository.dart';
import 'package:data7_expedicao/domain/services/i_app_config_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';

void registerConfigModule(GetIt locator) {
  locator.registerLazySingleton(() => ConfigService());
  locator.registerLazySingleton<IAppConfigService>(() => locator<ConfigService>());

  locator.registerLazySingleton(
    () => ConfigViewModel(
      locator<ConfigService>(),
      locator<IPrinterPreferencesRepository>(),
      locator<IPrinterDiscoveryService>(),
      locator<IThermalPrinterRepository>(),
    ),
  );
}
