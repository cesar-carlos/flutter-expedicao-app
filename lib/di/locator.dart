import 'package:get_it/get_it.dart';

import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/data/repositories/user_repository_impl.dart';
import 'package:exp/data/repositories/user_system_repository_impl.dart';
import 'package:exp/data/repositories/separate_repository_impl.dart';
import 'package:exp/domain/usecases/user/register_user_usecase.dart';
import 'package:exp/domain/usecases/user/login_user_usecase.dart';
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
import 'package:exp/data/repositories/expedition_cart_consultation_repository_impl.dart';
import 'package:exp/domain/models/expedition_cart_consultation_model.dart';
import 'package:exp/domain/services/event_service.dart';
import 'package:exp/data/services/event_service_impl.dart';
import 'package:exp/domain/repositories/event_generic_repository.dart';
import 'package:exp/data/repositories/event_repository/event_generic_repository_impl.dart';
import 'package:exp/domain/usecases/cancel_cart/cancel_cart_usecase.dart';
import 'package:exp/data/repositories/expedition_cancellation_repository_impl.dart';
import 'package:exp/domain/repositories/expedition_cart_route_internship_repository.dart';
import 'package:exp/data/repositories/expedition_cart_route_internship_repository_impl.dart';
import 'package:exp/domain/models/expedition_cancellation_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_model.dart';
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
import 'package:exp/data/repositories/expedition_cart_repository_impl.dart';
import 'package:exp/data/repositories/expedition_cart_route_repository_impl.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/models/separation_item_consultation_model.dart';
import 'package:exp/domain/models/separation_item_summary_consultation_model.dart';
import 'package:exp/domain/models/stock_product_consultation_model.dart';
import 'package:exp/data/repositories/expedition_internship_repository_impl.dart';
import 'package:exp/domain/models/expedition_internship_model.dart';
import 'package:exp/domain/models/expedition_cart_route_model.dart';
import 'package:exp/domain/models/expedition_cart_model.dart';
import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/separation_item_model.dart';
import 'package:exp/domain/models/expedition_sector_stock_model.dart';
import 'package:exp/data/repositories/separation_item_repository_impl.dart';
import 'package:exp/data/repositories/expedition_sector_stock_repository_impl.dart';
import 'package:exp/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_usecase.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_usecase.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => ConfigService());
  locator.registerLazySingleton(() => UserPreferencesService());
  locator.registerLazySingleton(() => SocketService());

  locator.registerLazySingleton(() => ConfigViewModel(locator<ConfigService>()));

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

  locator.registerLazySingleton<BasicConsultationRepository<ExpeditionCartRouteInternshipGroupConsultationModel>>(
    () => group_consultation.ExpeditionCartRouteInternshipConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicRepository<ExpeditionCartRouteInternshipGroupModel>>(
    () => ExpeditionCartRouteInternshipGorupImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel>>(
    () => consultation.ExpeditionCartRouteInternshipConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicRepository<SeparateItemModel>>(() => SeparateItemRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<SeparationItemModel>>(() => SeparationItemRepositoryImpl());

  locator.registerLazySingleton<BasicConsultationRepository<SeparateItemConsultationModel>>(
    () => SeparateItemConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<ExpeditionCartRouteInternshipRepository>(
    () => ExpeditionCartRouteInternshipRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<StockProductConsultationModel>>(
    () => StockProductConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<ExpeditionCartConsultationModel>>(
    () => ExpeditionCartConsultationRepositoryImpl(),
  );
  locator.registerLazySingleton<ExpeditionCartConsultationRepositoryImpl>(
    () => ExpeditionCartConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicRepository<ExpeditionCartModel>>(() => ExpeditionCartRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<ExpeditionCartRouteModel>>(() => ExpeditionCartRouteRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<ExpeditionCartRouteInternshipModel>>(
    () => ExpeditionCartRouteInternshipRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicRepository<ExpeditionInternshipModel>>(() => ExpeditionInternshipRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<ExpeditionSectorStockModel>>(
    () => ExpeditionSectorStockRepositoryImpl(),
  );

  locator.registerFactory(() => RegisterUserUseCase(locator<UserRepository>()));
  locator.registerFactory(() => LoginUserUseCase(locator<UserRepository>()));

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

    final viewModel = AuthViewModel();
    viewModel.initialize(locator<LoginUserUseCase>());
    return viewModel;
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

  locator.registerLazySingleton(() {
    final viewModel = SocketViewModel();
    viewModel.initialize();
    return viewModel;
  });

  locator.registerFactory(() => HomeViewModel());

  locator.registerFactory(() => SeparationViewModel());

  locator.registerFactory(() => SeparateItemsViewModel());

  locator.registerLazySingleton<FiltersStorageService>(() => FiltersStorageService());
  locator.registerLazySingleton<UserSessionService>(() => UserSessionService());

  locator.registerLazySingleton<AddCartUseCase>(
    () => AddCartUseCase(
      cartRepository: locator<BasicRepository<ExpeditionCartModel>>(),
      cartRouteRepository: locator<BasicRepository<ExpeditionCartRouteModel>>(),
      cartRouteInternshipRepository: locator<BasicRepository<ExpeditionCartRouteInternshipModel>>(),
      cartConsultationRepository: locator<BasicConsultationRepository<ExpeditionCartConsultationModel>>(),
      expeditionInternshipRepository: locator<BasicRepository<ExpeditionInternshipModel>>(),
      userSystemRepository: locator<UserSystemRepository>(),
      userSessionService: locator<UserSessionService>(),
    ),
  );

  // Registrar repositórios para cancelamento de carrinho
  locator.registerLazySingleton<BasicRepository<ExpeditionCancellationModel>>(
    () => ExpeditionCancellationRepositoryImpl(),
  );

  locator.registerLazySingleton<CancelCartUseCase>(
    () => CancelCartUseCase(
      cartRepository: locator<BasicRepository<ExpeditionCartModel>>(),
      cancellationRepository: locator<BasicRepository<ExpeditionCancellationModel>>(),
      cartInternshipRouteRepository: locator<BasicRepository<ExpeditionCartRouteInternshipModel>>(),
      userSessionService: locator<UserSessionService>(),
    ),
  );

  locator.registerLazySingleton<CancelCardItemSeparationUseCase>(
    () => CancelCardItemSeparationUseCase(
      separateItemRepository: locator<BasicRepository<SeparateItemModel>>(),
      separationItemRepository: locator<BasicRepository<SeparationItemModel>>(),
      userSessionService: locator<UserSessionService>(),
    ),
  );

  locator.registerLazySingleton<AddItemSeparationUseCase>(
    () => AddItemSeparationUseCase(
      separateItemRepository: locator<BasicRepository<SeparateItemModel>>(),
      separationItemRepository: locator<BasicRepository<SeparationItemModel>>(),
      userSessionService: locator<UserSessionService>(),
    ),
  );

  locator.registerLazySingleton<CancelItemSeparationUseCase>(
    () => CancelItemSeparationUseCase(
      separateItemRepository: locator<BasicRepository<SeparateItemModel>>(),
      separationItemRepository: locator<BasicRepository<SeparationItemModel>>(),
      separateRepository: locator<BasicRepository<SeparateModel>>(),
      userSessionService: locator<UserSessionService>(),
    ),
  );

  locator.registerLazySingleton<EventService>(() => EventServiceImpl());

  locator.registerLazySingleton<EventGenericRepositoryImpl<SeparateModel>>(
    () => EventGenericRepositoryImpl(locator(), 'separar'),
  );

  locator.registerLazySingleton<EventGenericRepository<SeparateModel>>(() => SeparateEventRepositoryImpl(locator()));
}
