import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/data/repositories/user_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/user_system_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_repository_impl.dart';
import 'package:data7_expedicao/domain/usecases/user/register_user_usecase.dart';
import 'package:data7_expedicao/domain/usecases/user/login_user_usecase.dart';
import 'package:data7_expedicao/domain/viewmodels/register_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/profile_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/home_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/separation_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/separation_items_viewmodel.dart';
import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/data/datasources/user_preferences_service.dart';
import 'package:data7_expedicao/data/services/socket_service.dart';
import 'package:data7_expedicao/data/services/filters_storage_service.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/barcode_scanner_service.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_usecase.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_consultation_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/services/event_service.dart';
import 'package:data7_expedicao/data/services/event_service_impl.dart';
import 'package:data7_expedicao/data/repositories/event_repository/event_generic_repository_impl.dart';
import 'package:data7_expedicao/domain/repositories/separate_event_repository.dart';
import 'package:data7_expedicao/data/repositories/event_repository/separate_event_repository_impl.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/data/repositories/event_repository/separate_cart_internship_event_repository_impl.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_usecase.dart';
import 'package:data7_expedicao/data/repositories/expedition_cancellation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_route_internship_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_cancellation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_model.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/data/repositories/separate_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separation_user_sector_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separation_user_sector_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_progress_consultation_repository_impl.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_progress_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_route_internship_gorup_consultation_repository_impl.dart'
    as group_consultation;
import 'package:data7_expedicao/data/repositories/expedition_cart_route_internship_gorup__impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_route_internship_consultation_repository_impl.dart'
    as consultation;
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_group_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_group_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/data/repositories/separate_item_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_item_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separation_item_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separation_item_summary_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_item_unidade_medida_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/stock_product_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_route_repository_impl.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_summary_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/stock_product_consultation_model.dart';
import 'package:data7_expedicao/data/repositories/expedition_internship_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/data/repositories/separation_item_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_sector_stock_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_check.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_check_consultation_model.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_consultation_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_check_cart_consultation_model.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_cart_consultation_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_check_item_model.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_item_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_check_item_consultation_model.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_item_consultation_repository_impl.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/delete_item_separation/delete_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation/save_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_usecase.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_usecase.dart';
import 'package:data7_expedicao/domain/repositories/barcode_scanner_repository.dart';
import 'package:data7_expedicao/data/repositories/barcode_scanner_repository_mobile_impl.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_usecase.dart';
import 'package:data7_expedicao/domain/usecases/user/register_via_qrcode_usecase.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => ConfigService());
  locator.registerLazySingleton(() => UserPreferencesService());
  locator.registerLazySingleton(() => SocketService());
  locator.registerLazySingleton(() => AudioService());
  locator.registerLazySingleton(() => BarcodeScannerService());

  locator.registerLazySingleton(() => ConfigViewModel(locator<ConfigService>()));

  locator.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  locator.registerLazySingleton<UserSystemRepository>(() => UserSystemRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<SeparateModel>>(() => SeparateRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<SeparationUserSectorModel>>(() => SeparationUserSectorRepositoryImpl());

  locator.registerLazySingleton<BasicConsultationRepository<SeparationUserSectorConsultationModel>>(
    () => SeparationUserSectorConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<SeparateConsultationModel>>(
    () => SeparateConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<SeparateProgressConsultationModel>>(
    () => SeparateProgressConsultationRepositoryImpl(),
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

  locator.registerLazySingleton<BasicConsultationRepository<SeparateItemUnidadeMedidaConsultationModel>>(
    () => SeparateItemUnidadeMedidaRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicRepository<ExpeditionCartRouteInternshipModel>>(
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

  locator.registerLazySingleton<BasicRepository<ExpeditionInternshipModel>>(() => ExpeditionInternshipRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<ExpeditionSectorStockModel>>(
    () => ExpeditionSectorStockRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicRepository<ExpeditionCheckModel>>(() => ExpeditionCheckRepositoryImpl());

  locator.registerLazySingleton<BasicConsultationRepository<ExpeditionCheckConsultationModel>>(
    () => ExpeditionCheckConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<ExpeditionCheckCartConsultationModel>>(
    () => ExpeditionCheckCartConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicRepository<ExpeditionCheckItemModel>>(() => ExpeditionCheckItemRepositoryImpl());

  locator.registerLazySingleton<BasicConsultationRepository<ExpeditionCheckItemConsultationModel>>(
    () => ExpeditionCheckItemConsultationRepositoryImpl(),
  );

  locator.registerFactory(() => RegisterUserUseCase(locator<UserRepository>()));
  locator.registerFactory(() => LoginUserUseCase(locator<UserRepository>()));

  locator.registerLazySingleton<RegisterViaQRCodeUseCase>(
    () => RegisterViaQRCodeUseCase(
      userRepository: locator<UserRepository>(),
      userSystemRepository: locator<UserSystemRepository>(),
      userSessionService: locator<UserSessionService>(),
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

  locator.registerLazySingleton<DeleteItemSeparationUseCase>(
    () => DeleteItemSeparationUseCase(
      separateItemRepository: locator<BasicRepository<SeparateItemModel>>(),
      separationItemRepository: locator<BasicRepository<SeparationItemModel>>(),
      separateRepository: locator<BasicRepository<SeparateModel>>(),
      userSessionService: locator<UserSessionService>(),
    ),
  );

  locator.registerLazySingleton<SaveSeparationCartUseCase>(
    () => SaveSeparationCartUseCase(
      cartRouteInternshipRepository: locator<BasicRepository<ExpeditionCartRouteInternshipModel>>(),
      separationItemConsultationRepository: locator<BasicConsultationRepository<SeparationItemConsultationModel>>(),
      cartRepository: locator<BasicRepository<ExpeditionCartModel>>(),
      separateProgressRepository: locator<BasicConsultationRepository<SeparateProgressConsultationModel>>(),
      separationItemModelRepository: locator<BasicRepository<SeparationItemModel>>(),
      userSessionService: locator<UserSessionService>(),
    ),
  );

  locator.registerLazySingleton<SaveSeparationUseCase>(
    () => SaveSeparationUseCase(
      separateProgressRepository: locator<BasicConsultationRepository<SeparateProgressConsultationModel>>(),
      separateRepository: locator<BasicRepository<SeparateModel>>(),
      cartRouteRepository: locator<BasicRepository<ExpeditionCartRouteModel>>(),
    ),
  );

  locator.registerLazySingleton<StartSeparationUseCase>(
    () => StartSeparationUseCase(
      separateRepository: locator<BasicRepository<SeparateModel>>(),
      cartRouteRepository: locator<BasicRepository<ExpeditionCartRouteModel>>(),
      userSessionService: locator<UserSessionService>(),
    ),
  );

  locator.registerLazySingleton<RegisterSeparationUserSectorUseCase>(
    () => RegisterSeparationUserSectorUseCase(repository: locator<BasicRepository<SeparationUserSectorModel>>()),
  );

  locator.registerLazySingleton<NextSeparationUserUseCase>(
    () => NextSeparationUserUseCase(
      separationUserSectorRepository: locator<BasicConsultationRepository<SeparationUserSectorConsultationModel>>(),
      getRegisterUseCase: () => locator<RegisterSeparationUserSectorUseCase>(),
    ),
  );

  locator.registerLazySingleton<EventService>(() => EventServiceImpl());

  locator.registerLazySingleton<EventGenericRepositoryImpl<SeparateConsultationModel>>(
    () => EventGenericRepositoryImpl(locator<EventService>(), 'separar'),
  );

  locator.registerLazySingleton<SeparateEventRepository>(
    () => SeparateEventRepositoryImpl(
      locator<EventGenericRepositoryImpl<SeparateConsultationModel>>(),
      locator<EventService>(), // Adicionar esta dependência
    ),
  );

  locator.registerLazySingleton<EventGenericRepositoryImpl<ExpeditionCartRouteInternshipConsultationModel>>(
    () => EventGenericRepositoryImpl(locator<EventService>(), 'carrinho.percurso.estagio'),
  );

  locator.registerLazySingleton<SeparateCartInternshipEventRepository>(
    () => SeparateCartInternshipEventRepositoryImpl(
      locator<EventGenericRepositoryImpl<ExpeditionCartRouteInternshipConsultationModel>>(),
    ),
  );

  // Registro do Barcode Scanner Repository e UseCase
  locator.registerLazySingleton<BarcodeScannerRepository>(() => BarcodeScannerRepositoryMobileImpl());

  locator.registerLazySingleton<ScanBarcodeUseCase>(
    () => ScanBarcodeUseCase(scannerRepository: locator<BarcodeScannerRepository>()),
  );

  // Registro dos ViewModels após os repositórios de eventos
  locator.registerFactory(() => SeparationViewModel());
  locator.registerFactory(() => SeparationItemsViewModel());
}
