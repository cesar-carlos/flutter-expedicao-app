import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/core/metrics/metrics_storage.dart';
import 'package:data7_expedicao/core/network/network_service.dart';
import 'package:data7_expedicao/core/network/retry_policy.dart';
import 'package:data7_expedicao/core/network/socket_connection_manager.dart';
import 'package:data7_expedicao/core/network/socket_operation_retry.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/barcode_broadcast_service.dart';
import 'package:data7_expedicao/core/services/barcode_scanner_service.dart';
import 'package:data7_expedicao/core/services/i_user_preferences_repository.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/core/utils/i_logger.dart';
import 'package:data7_expedicao/data/datasources/user_preferences_service.dart';
import 'package:data7_expedicao/infrastructure/network/internet_address_network_service.dart';
import 'package:data7_expedicao/infrastructure/services/logger_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/home_viewmodel.dart';
import 'package:data7_expedicao/ui/services/camera_barcode_scan_service.dart';

void registerCoreModule(GetIt locator) {
  if (!locator.isRegistered<ILogger>()) {
    locator.registerLazySingleton<ILogger>(() => LoggerService());
  }
  locator.registerLazySingleton(() => UserPreferencesService());
  locator.registerLazySingleton<IUserPreferencesRepository>(() => locator<UserPreferencesService>());
  locator.registerLazySingleton(() => AudioService());
  locator.registerLazySingleton(() => BarcodeBroadcastService());
  locator.registerLazySingleton<MetricsStorage>(() => MetricsStorage());
  locator.registerLazySingleton<MetricsCollector>(() => MetricsCollector(locator<MetricsStorage>()));
  locator.registerLazySingleton<NetworkService>(() => InternetAddressNetworkService());
  // Bug R: usa RetryPolicy.withJitter em producao para evitar
  // "thundering herd" quando muitos clientes falham simultaneamente
  // (ex.: servidor cai e reconecta — todos retentam ao mesmo tempo).
  locator.registerLazySingleton<RetryPolicy>(
    () => RetryPolicy.withJitter(
      maxAttempts: 3,
      initialDelay: const Duration(seconds: 1),
      backoffMultiplier: 2.0,
      maxDelay: const Duration(seconds: 10),
    ),
  );
  locator.registerLazySingleton<SocketConnectionManager>(
    () => SocketConnectionManager(retryPolicy: locator<RetryPolicy>()),
  );
  locator.registerLazySingleton<SocketOperationRetry>(() => SocketOperationRetry(retryPolicy: locator<RetryPolicy>()));
  locator.registerLazySingleton(() => BarcodeScannerService());
  locator.registerLazySingleton(() => ShelfScanningService());
  locator.registerLazySingleton<CameraBarcodeScanService>(() => const CameraBarcodeScanService());
  locator.registerFactory(() => HomeViewModel());
}
