import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/core/utils/i_logger.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_route_internship_consultation_repository_impl.dart'
    as consultation;
import 'package:data7_expedicao/data/repositories/expedition_cart_route_internship_gorup__impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_route_internship_gorup_consultation_repository_impl.dart'
    as group_consultation;
import 'package:data7_expedicao/data/repositories/expedition_cart_route_internship_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_cart_route_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_cart_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_item_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_item_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_internship_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_item_print_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/expedition_sector_stock_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_item_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_item_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_item_unidade_medida_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_progress_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separation_item_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separation_item_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separation_item_summary_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separation_user_sector_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separation_user_sector_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/stock_product_consultation_repository_impl.dart';
import 'package:data7_expedicao/data/services/filters_storage_service.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_group_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_group_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/expedition_check.dart';
import 'package:data7_expedicao/domain/models/expedition_check_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_check_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_check_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_check_item_model.dart';
import 'package:data7_expedicao/domain/models/expedition_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/separate_progress_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_summary_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_model.dart';
import 'package:data7_expedicao/domain/models/stock_product_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_usecase.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_link/check_separation_user_sector_link_usecase.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_usecase.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_usecase.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation/save_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_usecase.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_items_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_viewmodel.dart';

void registerSeparationModule(GetIt locator) {
  locator.registerLazySingleton<BasicRepository<SeparateModel>>(() => SeparateRepositoryImpl());

  locator.registerLazySingleton<BasicRepository<SeparationUserSectorModel>>(() => SeparationUserSectorRepositoryImpl());

  locator.registerLazySingleton<BasicConsultationRepository<SeparationUserSectorConsultationModel>>(
    () => SeparationUserSectorConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<SeparateConsultationModel>>(
    () => SeparateConsultationRepositoryImpl(),
  );

  locator.registerLazySingleton<BasicConsultationRepository<ExpeditionItemPrintConsultationModel>>(
    () => ExpeditionItemPrintConsultationRepositoryImpl(),
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

  locator.registerLazySingleton<FiltersStorageService>(() => FiltersStorageService());
  locator.registerLazySingleton<IFiltersStorageService>(() => locator<FiltersStorageService>());

  locator.registerLazySingleton<SaveSeparationCartUseCase>(
    () => SaveSeparationCartUseCase(
      cartRouteInternshipRepository: locator<BasicRepository<ExpeditionCartRouteInternshipModel>>(),
      separationItemConsultationRepository: locator<BasicConsultationRepository<SeparationItemConsultationModel>>(),
      separateItemRepository: locator<BasicConsultationRepository<SeparateItemConsultationModel>>(),
      separateProgressRepository: locator<BasicConsultationRepository<SeparateProgressConsultationModel>>(),
      separationItemModelRepository: locator<BasicRepository<SeparationItemModel>>(),
      cartRepository: locator<BasicRepository<ExpeditionCartModel>>(),
      userSessionService: locator<IUserSessionService>(),
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
      userSessionService: locator<IUserSessionService>(),
    ),
  );

  locator.registerLazySingleton<RegisterSeparationUserSectorUseCase>(
    () => RegisterSeparationUserSectorUseCase(repository: locator<BasicRepository<SeparationUserSectorModel>>()),
  );

  locator.registerLazySingleton<CheckSeparationUserSectorLinkUseCase>(
    () => CheckSeparationUserSectorLinkUseCase(
      repository: locator<BasicConsultationRepository<SeparationUserSectorConsultationModel>>(),
    ),
  );

  locator.registerLazySingleton<CheckSeparationUserSectorCompletionUseCase>(
    () => CheckSeparationUserSectorCompletionUseCase(
      repository: locator<BasicConsultationRepository<SeparationUserSectorConsultationModel>>(),
    ),
  );

  locator.registerLazySingleton<GetSeparationConsultationUseCase>(
    () =>
        GetSeparationConsultationUseCase(repository: locator<BasicConsultationRepository<SeparateConsultationModel>>()),
  );

  locator.registerLazySingleton<ResolveSeparationUserLinkUseCase>(
    () => ResolveSeparationUserLinkUseCase(checkLinkUseCase: locator<CheckSeparationUserSectorLinkUseCase>()),
  );

  locator.registerLazySingleton<NextSeparationUserUseCase>(
    () => NextSeparationUserUseCase(
      separationUserSectorRepository: locator<BasicConsultationRepository<SeparationUserSectorConsultationModel>>(),
      getRegisterUseCase: () => locator<RegisterSeparationUserSectorUseCase>(),
      logger: locator<ILogger>(),
    ),
  );

  // Registro dos ViewModels após os repositórios de eventos
  locator.registerFactory(() => SeparationViewModel());
  locator.registerFactory(() => SeparationItemsViewModel());
}
