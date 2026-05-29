import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/core/network/ambiguous_send_exception.dart';
import 'package:data7_expedicao/core/network/retry_policy.dart';
import 'package:data7_expedicao/data/datasources/printer_preferences_service.dart';
import 'package:data7_expedicao/data/repositories/printer_preferences_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/thermal_printer_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_discovery_service.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_preferences_repository.dart';
import 'package:data7_expedicao/domain/repositories/i_thermal_printer_repository.dart';
import 'package:data7_expedicao/domain/usecases/get_default_printer/get_default_printer_usecase.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_usecase.dart';
import 'package:data7_expedicao/infrastructure/services/esc_pos_ticket_builder_service.dart';
import 'package:data7_expedicao/infrastructure/services/printer_discovery_service.dart';
import 'package:data7_expedicao/infrastructure/services/thermal_printer_tcp_service.dart';

void registerPrintingModule(GetIt locator) {
  locator.registerLazySingleton(() => const PrinterPreferencesService());
  locator.registerLazySingleton<IPrinterPreferencesRepository>(
    () => PrinterPreferencesRepositoryImpl(service: locator<PrinterPreferencesService>()),
  );
  locator.registerLazySingleton<GetDefaultPrinterUseCase>(
    () => GetDefaultPrinterUseCase(repository: locator<IPrinterPreferencesRepository>()),
  );
  locator.registerLazySingleton<PrinterDiscoveryService>(() => const PrinterDiscoveryService());
  locator.registerLazySingleton<IPrinterDiscoveryService>(() => locator<PrinterDiscoveryService>());
  locator.registerLazySingleton(() => const EscPosTicketBuilderService());
  locator.registerLazySingleton(() => const ThermalPrinterTcpService());

  locator.registerLazySingleton<IThermalPrinterRepository>(
    () => ThermalPrinterRepositoryImpl(
      ticketBuilderService: locator<EscPosTicketBuilderService>(),
      tcpService: locator<ThermalPrinterTcpService>(),
      // Policy dedicada: NAO retenta falhas pos-envio (AmbiguousSendException)
      // para evitar tickets duplicados quando os bytes ja foram entregues.
      retryPolicy: RetryPolicy.withJitter(
        maxAttempts: 3,
        initialDelay: const Duration(seconds: 1),
        backoffMultiplier: 2.0,
        maxDelay: const Duration(seconds: 10),
        shouldRetry: (error) => error is! AmbiguousSendException,
      ),
    ),
  );

  locator.registerLazySingleton<PrintExpeditionTicketUseCase>(
    () => PrintExpeditionTicketUseCase(
      expeditionItemPrintRepository: locator<BasicConsultationRepository<ExpeditionItemPrintConsultationModel>>(),
      thermalPrinterRepository: locator<IThermalPrinterRepository>(),
    ),
  );
}
