import 'package:get_it/get_it.dart';

import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/data/repositories/user_repository_impl.dart';
import 'package:exp/data/repositories/user_system_repository_impl.dart';
import 'package:exp/data/repositories/separate_repository_impl.dart';
import 'package:exp/domain/usecases/register_user_usecase.dart';
import 'package:exp/domain/usecases/login_user_usecase.dart';
import 'package:exp/domain/viewmodels/register_viewmodel.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/domain/viewmodels/config_viewmodel.dart';
import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'package:exp/domain/viewmodels/socket_viewmodel.dart';
import 'package:exp/domain/viewmodels/home_viewmodel.dart';
import 'package:exp/domain/viewmodels/separation_viewmodel.dart';
import 'package:exp/domain/viewmodels/separate_items_viewmodel.dart';
import 'package:exp/data/datasources/config_service.dart';
import 'package:exp/data/datasources/user_preferences_service.dart';
import 'package:exp/data/services/socket_service.dart';
import 'package:exp/data/services/filters_storage_service.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/domain/usecases/add_cart/add_cart_usecase.dart';
import 'package:exp/domain/repositories/expedition_cart_consultation_repository.dart';
import 'package:exp/domain/services/event_service.dart';
import 'package:exp/data/services/event_service_impl.dart';
import 'package:exp/domain/repositories/event_generic_repository.dart';
import 'package:exp/data/repositories/event_repository/event_generic_repository_impl.dart';
import 'package:exp/data/repositories/event_repository/separate_event_repository_impl.dart';
import 'package:exp/domain/models/separate_model.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/data/repositories/separate_consultation_repository_impl.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/data/repositories/expedition_cart_route_internship_gorup_consultation_repository_impl.dart'
    as group_consultation;
import 'package:exp/data/repositories/expedition_cart_route_internship_gorup__impl.dart';
import 'package:exp/data/repositories/expedition_cart_route_internship_consultation_repository_impl.dart'
    as consultation;
import 'package:exp/domain/models/expedition_cart_route_internship_group_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_group_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/data/repositories/separate_item_repository_impl.dart';
import 'package:exp/data/repositories/separate_item_consultation_repository_impl.dart';
import 'package:exp/data/repositories/separation_item_consultation_repository_impl.dart';
import 'package:exp/data/repositories/separation_item_summary_consultation_repository_impl.dart';
import 'package:exp/data/repositories/stock_product_consultation_repository_impl.dart';
import 'package:exp/data/repositories/expedition_cart_consultation_repository_impl.dart';
import 'package:exp/data/repositories/expedition_cart_repository_impl.dart';
import 'package:exp/data/repositories/expedition_cart_route_internship_repository_impl.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/models/separation_item_consultation_model.dart';
import 'package:exp/domain/models/separation_item_summary_consultation_model.dart';
import 'package:exp/domain/models/stock_product_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_model.dart';
import 'package:exp/data/repositories/expedition_cancellation_repository_impl.dart';
import 'package:exp/domain/models/expedition_cancellation_model.dart';
import 'package:exp/domain/models/separate_item_model.dart';

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
  locator.registerLazySingleton(() => ConfigViewModel(locator<ConfigService>()));

  // Registrar repositórios - usando a configuração global do Dio
  locator.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  locator.registerLazySingleton<UserSystemRepository>(() => UserSystemRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<SeparateModel>>(() => SeparateRepositoryImpl());

  locator.registerLazySingleton<BasicConsultationRepository<SeparateConsultationModel>>(
    () => SeparateConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<SeparationItemConsultationModel>>(
    () => SeparationItemConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<SeparationItemSummaryConsultationModel>>(
    () => SeparationItemSummaryConsultationRepositoryImpl(),
  );

  // Registrar repositórios ExpeditionCartRouteInternship
  locator.registerLazySingleton<BasicConsultationRepository<ExpeditionCartRouteInternshipGroupConsultationModel>>(
    () => group_consultation.ExpeditionCartRouteInternshipConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicRepository<ExpeditionCartRouteInternshipGroupModel>>(
    () => ExpeditionCartRouteInternshipGorupImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel>>(
    () => consultation.ExpeditionCartRouteInternshipConsultationRepositoryImpl(),
  );

  // Registrar repositórios adicionais
  locator.registerLazySingleton<BasicRepository<SeparateItemModel>>(() => SeparateItemRepositoryImpl());

  locator.registerLazySingleton<BasicConsultationRepository<SeparateItemConsultationModel>>(
    () => SeparateItemConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<StockProductConsultationModel>>(
    () => StockProductConsultationRepositoryImpl(),
  );

  // Registrar repositórios de carrinhos
  locator.registerLazySingleton<ExpeditionCartConsultationRepository>(() => ExpeditionCartConsultationRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<ExpeditionCartModel>>(() => ExpeditionCartRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<ExpeditionCartRouteInternshipModel>>(
    () => ExpeditionCartRouteInternshipRepositoryImpl(),
  );

  // Registrar ExpeditionCancellationRepository
  locator.registerLazySingleton<BasicRepository<ExpeditionCancellationModel>>(
    () => ExpeditionCancellationRepositoryImpl(),
  );

  // Registrar use cases
  locator.registerFactory(() => RegisterUserUseCase(locator<UserRepository>()));
  locator.registerFactory(() => LoginUserUseCase(locator<UserRepository>()));

  // Registrar view models - só inicializa quando realmente usado
  locator.registerFactory(() {
    // Verifica se o ConfigService foi inicializado
    final configService = locator<ConfigService>();
    if (!configService.isInitialized) {
      throw StateError('ConfigService deve ser inicializado antes de criar RegisterViewModel');
    }

    final viewModel = RegisterViewModel();
    viewModel.initialize(locator<RegisterUserUseCase>());
    return viewModel;
  });

  // Registrar AuthViewModel
  locator.registerFactory(() {
    final configService = locator<ConfigService>();
    if (!configService.isInitialized) {
      throw StateError('ConfigService deve ser inicializado antes de criar AuthViewModel');
    }

    final viewModel = AuthViewModel();
    viewModel.initialize(locator<LoginUserUseCase>());
    return viewModel;
  });

  // Registrar UserSelectionViewModel
  locator.registerFactory(() {
    return UserSelectionViewModel(locator<UserSystemRepository>(), locator<UserRepository>());
  });

  // Registrar ProfileViewModel
  locator.registerFactory(() {
    final configService = locator<ConfigService>();
    if (!configService.isInitialized) {
      throw StateError('ConfigService deve ser inicializado antes de criar ProfileViewModel');
    }

    // Precisamos obter o AuthViewModel do contexto em runtime
    // Por isso não passamos ele aqui, será injetado via Consumer
    return ProfileViewModel(locator<UserRepository>(), locator<AuthViewModel>());
  });

  // Registrar SocketViewModel
  locator.registerLazySingleton(() {
    final viewModel = SocketViewModel();
    viewModel.initialize();
    return viewModel;
  });

  // Registrar HomeViewModel
  locator.registerFactory(() => HomeViewModel());

  // Registrar SeparationViewModel
  locator.registerFactory(() => SeparationViewModel());

  // Registrar SeparateItemsViewModel
  locator.registerFactory(() => SeparateItemsViewModel());

  // Registrar serviços
  locator.registerLazySingleton<FiltersStorageService>(() => FiltersStorageService());
  locator.registerLazySingleton<UserSessionService>(() => UserSessionService());

  // Registrar UseCases
  locator.registerLazySingleton<AddCartUseCase>(
    () => AddCartUseCase(
      cartConsultationRepository: locator<ExpeditionCartConsultationRepository>(),
      cartRepository: locator<BasicRepository<ExpeditionCartModel>>(),
      cartRouteRepository: locator<BasicRepository<ExpeditionCartRouteInternshipModel>>(),
      userSessionService: locator<UserSessionService>(),
    ),
  );

  // Registrar EventService
  locator.registerLazySingleton<EventService>(() => EventServiceImpl());

  // Registrar GenericEventRepository para SeparateModel
  locator.registerLazySingleton<EventGenericRepositoryImpl<SeparateModel>>(
    () => EventGenericRepositoryImpl(locator(), 'separar'),
  );

  // Registrar SeparateEventRepository
  locator.registerLazySingleton<EventGenericRepository<SeparateModel>>(() => SeparateEventRepositoryImpl(locator()));
}
