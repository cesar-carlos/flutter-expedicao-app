import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:data7_expedicao/data/datasources/update_cache_service.dart';
import 'package:data7_expedicao/data/repositories/app_update_repository_impl.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/domain/services/i_update_cache_service.dart';
import 'package:data7_expedicao/domain/usecases/check_app_update/check_app_update_usecase.dart';
import 'package:data7_expedicao/domain/usecases/download_app_update/download_app_update_usecase.dart';
import 'package:data7_expedicao/domain/usecases/install_app_update/install_app_update_usecase.dart';
import 'package:data7_expedicao/presentation/viewmodels/app_update_viewmodel.dart';

void registerAppUpdateModule(GetIt locator) {
  locator.registerLazySingletonAsync<UpdateCacheService>(() async {
    final prefs = await SharedPreferences.getInstance();
    return UpdateCacheService(prefs: prefs);
  });
  locator.registerLazySingletonAsync<IUpdateCacheService>(() => locator.getAsync<UpdateCacheService>());

  // Registro do App Update
  locator.registerLazySingleton<IAppUpdateRepository>(() => AppUpdateRepositoryImpl());

  locator.registerLazySingleton<CheckAppUpdateUseCase>(() => CheckAppUpdateUseCase(locator<IAppUpdateRepository>()));

  locator.registerLazySingleton<DownloadAppUpdateUseCase>(
    () => DownloadAppUpdateUseCase(locator<IAppUpdateRepository>()),
  );

  locator.registerLazySingleton<InstallAppUpdateUseCase>(
    () => InstallAppUpdateUseCase(locator<IAppUpdateRepository>()),
  );

  locator.registerLazySingletonAsync<AppUpdateViewModel>(() async {
    final cacheService = await locator.getAsync<UpdateCacheService>();
    return AppUpdateViewModel(
      checkAppUpdateUseCase: locator<CheckAppUpdateUseCase>(),
      downloadAppUpdateUseCase: locator<DownloadAppUpdateUseCase>(),
      installAppUpdateUseCase: locator<InstallAppUpdateUseCase>(),
      updateCacheService: cacheService,
    );
  });
}
