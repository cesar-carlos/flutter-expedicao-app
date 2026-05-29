import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/core/network/socket_operation_retry.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/services/cart_validation_service.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/services/picking_state_manager.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/delete_item_separation/delete_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';

void registerPickingModule(GetIt locator) {
  locator.registerLazySingleton<PickingStateManager>(() => PickingStateManager());

  locator.registerLazySingleton<CartValidationService>(
    () => CartValidationService(repository: locator<BasicConsultationRepository<SeparateItemConsultationModel>>()),
  );

  locator.registerLazySingleton<AddItemSeparationUseCase>(
    () => AddItemSeparationUseCase(
      separateItemRepository: locator<BasicRepository<SeparateItemModel>>(),
      separationItemRepository: locator<BasicRepository<SeparationItemModel>>(),
      userSessionService: locator<IUserSessionService>(),
      metricsCollector: locator<MetricsCollector>(),
      socketOperationRetry: locator<SocketOperationRetry>(),
    ),
  );

  locator.registerLazySingleton<CancelItemSeparationUseCase>(
    () => CancelItemSeparationUseCase(
      separateItemRepository: locator<BasicRepository<SeparateItemModel>>(),
      separationItemRepository: locator<BasicRepository<SeparationItemModel>>(),
      separateRepository: locator<BasicRepository<SeparateModel>>(),
      userSessionService: locator<IUserSessionService>(),
    ),
  );

  locator.registerLazySingleton<DeleteItemSeparationUseCase>(
    () => DeleteItemSeparationUseCase(
      separateItemRepository: locator<BasicRepository<SeparateItemModel>>(),
      separationItemRepository: locator<BasicRepository<SeparationItemModel>>(),
      separateRepository: locator<BasicRepository<SeparateModel>>(),
      userSessionService: locator<IUserSessionService>(),
    ),
  );

  locator.registerFactory<CardPickingViewModel>(
    () => CardPickingViewModel.withDependencies(
      repository: locator<BasicConsultationRepository<SeparateItemConsultationModel>>(),
      sectorStockRepository: locator<BasicRepository<ExpeditionSectorStockModel>>(),
      filtersStorage: locator<IFiltersStorageService>(),
      addItemSeparationUseCase: locator<AddItemSeparationUseCase>(),
      saveSeparationCartUseCase: locator<SaveSeparationCartUseCase>(),
      userSessionService: locator<IUserSessionService>(),
      cartEventRepository: locator<SeparateCartInternshipEventRepository>(),
      shelfScanningService: locator<ShelfScanningService>(),
      stateManager: locator<PickingStateManager>(),
      cartValidationService: locator<CartValidationService>(),
      metricsCollector: _resolveMetricsCollector(locator),
    ),
  );
}

MetricsCollector? _resolveMetricsCollector(GetIt locator) {
  try {
    return locator<MetricsCollector>();
  } catch (_) {
    return null;
  }
}
