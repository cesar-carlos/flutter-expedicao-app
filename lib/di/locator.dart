import 'package:get_it/get_it.dart';

import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/data/repositories/user_repository_impl.dart';
import 'package:exp/data/repositories/user_system_repository_impl.dart';
import 'package:exp/domain/usecases/register_user_usecase.dart';
import 'package:exp/domain/usecases/login_user_usecase.dart';
import 'package:exp/domain/viewmodels/register_viewmodel.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/domain/viewmodels/config_viewmodel.dart';
import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'package:exp/domain/viewmodels/socket_viewmodel.dart';
import 'package:exp/data/datasources/config_service.dart';
import 'package:exp/data/datasources/user_preferences_service.dart';
import 'package:exp/data/services/socket_service.dart';

/// Instância global do Service Locator para Injeção de Dependências
final GetIt locator = GetIt.instance;

/// Configuração das dependências da aplicação
///
/// Esta função deve ser chamada antes de executar o app,
/// tipicamente em main() antes de runApp()
void setupLocator() {
  // Registrar serviços de baixo nível
  locator.registerLazySingleton(() => ConfigService());
  locator.registerLazySingleton(() => UserPreferencesService());
  locator.registerLazySingleton(() => SocketService());

  // Registrar ConfigViewModel como singleton
  locator.registerLazySingleton(
    () => ConfigViewModel(locator<ConfigService>()),
  );

  // Registrar repositórios - usando a configuração global do Dio
  locator.registerFactory<UserRepository>(() {
    return UserRepositoryImpl();
  });

  locator.registerFactory<UserSystemRepository>(() {
    return UserSystemRepositoryImpl();
  });

  // Registrar use cases
  locator.registerFactory(() => RegisterUserUseCase(locator<UserRepository>()));
  locator.registerFactory(() => LoginUserUseCase(locator<UserRepository>()));

  // Registrar view models - só inicializa quando realmente usado
  locator.registerFactory(() {
    // Verifica se o ConfigService foi inicializado
    final configService = locator<ConfigService>();
    if (!configService.isInitialized) {
      throw StateError(
        'ConfigService deve ser inicializado antes de criar RegisterViewModel',
      );
    }

    final viewModel = RegisterViewModel();
    viewModel.initialize(locator<RegisterUserUseCase>());
    return viewModel;
  });

  // Registrar AuthViewModel
  locator.registerFactory(() {
    final configService = locator<ConfigService>();
    if (!configService.isInitialized) {
      throw StateError(
        'ConfigService deve ser inicializado antes de criar AuthViewModel',
      );
    }

    final viewModel = AuthViewModel();
    viewModel.initialize(locator<LoginUserUseCase>());
    return viewModel;
  });

  // Registrar UserSelectionViewModel
  locator.registerFactory(() {
    return UserSelectionViewModel(
      locator<UserSystemRepository>(),
      locator<UserRepository>(),
    );
  });

  // Registrar ProfileViewModel
  locator.registerFactory(() {
    final configService = locator<ConfigService>();
    if (!configService.isInitialized) {
      throw StateError(
        'ConfigService deve ser inicializado antes de criar ProfileViewModel',
      );
    }

    // Precisamos obter o AuthViewModel do contexto em runtime
    // Por isso não passamos ele aqui, será injetado via Consumer
    return ProfileViewModel(
      locator<UserRepository>(),
      locator<AuthViewModel>(),
    );
  });

  // Registrar SocketViewModel
  locator.registerLazySingleton(() {
    final viewModel = SocketViewModel();
    viewModel.initialize();
    return viewModel;
  });
}
