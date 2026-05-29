import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/data/repositories/expedition_cancellation_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_cancellation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/expedition_internship_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_with_consistency_usecase.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_usecase.dart';

void registerCartModule(GetIt locator) {
  locator.registerLazySingleton<AddCartUseCase>(
    () => AddCartUseCase(
      cartRepository: locator<BasicRepository<ExpeditionCartModel>>(),
      cartRouteRepository: locator<BasicRepository<ExpeditionCartRouteModel>>(),
      cartRouteInternshipRepository: locator<BasicRepository<ExpeditionCartRouteInternshipModel>>(),
      cartConsultationRepository: locator<BasicConsultationRepository<ExpeditionCartConsultationModel>>(),
      expeditionInternshipRepository: locator<BasicRepository<ExpeditionInternshipModel>>(),
      userSystemRepository: locator<UserSystemRepository>(),
      userSessionService: locator<IUserSessionService>(),
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
      userSessionService: locator<IUserSessionService>(),
    ),
  );

  locator.registerLazySingleton<CancelCardItemSeparationUseCase>(
    () => CancelCardItemSeparationUseCase(
      separateItemRepository: locator<BasicRepository<SeparateItemModel>>(),
      separationItemRepository: locator<BasicRepository<SeparationItemModel>>(),
      userSessionService: locator<IUserSessionService>(),
    ),
  );

  locator.registerLazySingleton<CancelCartWithConsistencyUseCase>(
    () => CancelCartWithConsistencyUseCase(
      cancelCartUseCase: locator<CancelCartUseCase>(),
      cancelCardItemSeparationUseCase: locator<CancelCardItemSeparationUseCase>(),
    ),
  );
}
