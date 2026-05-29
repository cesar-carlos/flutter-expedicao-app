import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/data/repositories/event_repository/event_generic_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/event_repository/separate_cart_internship_event_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/event_repository/separate_event_repository_impl.dart';
import 'package:data7_expedicao/data/services/event_service_impl.dart';
import 'package:data7_expedicao/data/services/socket_service.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/repositories/separate_event_repository.dart';
import 'package:data7_expedicao/domain/services/event_service.dart';
import 'package:data7_expedicao/domain/services/i_socket_connection_port.dart';
import 'package:data7_expedicao/presentation/viewmodels/socket_viewmodel.dart';

void registerSocketModule(GetIt locator) {
  locator.registerLazySingleton(() => SocketService());
  locator.registerLazySingleton<ISocketConnectionPort>(() => locator<SocketService>());

  locator.registerLazySingleton(() {
    final viewModel = SocketViewModel();
    viewModel.initialize();
    return viewModel;
  });

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
}
