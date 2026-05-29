import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/data/repositories/user_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/user_system_repository_impl.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/user/login_user_usecase.dart';
import 'package:data7_expedicao/domain/usecases/user/register_user_usecase.dart';
import 'package:data7_expedicao/domain/usecases/user/register_via_qrcode_usecase.dart';
import 'package:data7_expedicao/presentation/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/profile_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/register_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/user_selection_viewmodel.dart';

void registerAuthModule(GetIt locator) {
  locator.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  locator.registerLazySingleton<UserSystemRepository>(() => UserSystemRepositoryImpl());

  locator.registerLazySingleton<UserSessionService>(() => UserSessionService());
  locator.registerLazySingleton<IUserSessionService>(() => locator<UserSessionService>());

  locator.registerFactory(() => RegisterUserUseCase(locator<UserRepository>()));
  locator.registerFactory(() => LoginUserUseCase(locator<UserRepository>()));

  locator.registerLazySingleton<RegisterViaQRCodeUseCase>(
    () => RegisterViaQRCodeUseCase(
      userRepository: locator<UserRepository>(),
      userSystemRepository: locator<UserSystemRepository>(),
      userSessionService: locator<IUserSessionService>(),
    ),
  );

  locator.registerFactory(() {
    final configService = locator<ConfigService>();
    if (!configService.isInitialized) {
      throw StateError('ConfigService deve ser inicializado antes de criar RegisterViewModel');
    }

    final viewModel = RegisterViewModel();
    viewModel.initialize(locator<RegisterUserUseCase>());
    return viewModel;
  });

  locator.registerFactory(() {
    final configService = locator<ConfigService>();
    if (!configService.isInitialized) {
      throw StateError('ConfigService deve ser inicializado antes de criar AuthViewModel');
    }

    return AuthViewModel(loginUserUseCase: locator<LoginUserUseCase>());
  });

  locator.registerFactory(() {
    return UserSelectionViewModel(locator<UserSystemRepository>(), locator<UserRepository>());
  });

  locator.registerFactory(() {
    final configService = locator<ConfigService>();
    if (!configService.isInitialized) {
      throw StateError('ConfigService deve ser inicializado antes de criar ProfileViewModel');
    }

    return ProfileViewModel(locator<UserRepository>(), locator<AuthViewModel>());
  });
}
