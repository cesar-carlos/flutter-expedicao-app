import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/utils/print_failure_message_helper.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/get_default_printer/get_default_printer_usecase.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_params.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_usecase.dart';

sealed class PrintTicketResult {
  const PrintTicketResult();
}

class PrintTicketNoPrinterConfigured extends PrintTicketResult {
  const PrintTicketNoPrinterConfigured();
}

class PrintTicketSent extends PrintTicketResult {
  final PrinterConfig printer;

  const PrintTicketSent(this.printer);
}

class PrintTicketFailed extends PrintTicketResult {
  final String message;

  const PrintTicketFailed(this.message);
}

class PrintTicketError extends PrintTicketResult {
  const PrintTicketError();
}

class SeparationPrintCoordinator {
  final GetDefaultPrinterUseCase _getDefaultPrinterUseCase;
  final IUserSessionService _userSessionService;
  final PrintExpeditionTicketUseCase _printExpeditionTicketUseCase;

  const SeparationPrintCoordinator({
    required GetDefaultPrinterUseCase getDefaultPrinterUseCase,
    required IUserSessionService userSessionService,
    required PrintExpeditionTicketUseCase printExpeditionTicketUseCase,
  }) : _getDefaultPrinterUseCase = getDefaultPrinterUseCase,
       _userSessionService = userSessionService,
       _printExpeditionTicketUseCase = printExpeditionTicketUseCase;

  Future<PrintTicketResult> printSeparationTicket({
    required int codEmpresa,
    required int codSepararEstoque,
  }) async {
    try {
      final printer = await _getDefaultPrinterUseCase.call();

      if (printer == null) {
        return const PrintTicketNoPrinterConfigured();
      }

      final appUser = await _userSessionService.loadUserSession();

      final separatorName = appUser?.userSystemModel?.nomeUsuario ?? appUser?.nome;
      final userSectorStock = appUser?.userSystemModel?.codSetorEstoque;
      final userSectorName = appUser?.userSystemModel?.nomeSetorEstoque;

      final result = await _printExpeditionTicketUseCase.call(
        PrintExpeditionTicketParams(
          codEmpresa: codEmpresa,
          codSepararEstoque: codSepararEstoque,
          printer: printer,
          separatorName: separatorName,
          codSetorEstoque: (userSectorStock != null && userSectorStock > 0) ? userSectorStock : null,
          codUsuario: appUser?.userSystemModel?.codUsuario,
        ),
      );

      final success = result.getOrNull();
      if (success != null) {
        return PrintTicketSent(printer);
      }

      final failure = result.exceptionOrNull();

      String errorMessage;
      if (failure is DataFailure && failure.code == 'NOT_FOUND') {
        if (userSectorStock != null && userSectorStock > 0) {
          errorMessage =
              'Não existem itens do setor $userSectorStock ($userSectorName) para imprimir nesta separação.\n'
              'Usuário: $separatorName';
        } else {
          errorMessage =
              'Não existem itens para imprimir nesta separação.\n'
              'Usuário: $separatorName';
        }
      } else {
        errorMessage = const PrintFailureMessageHelper().build(failure, context: PrintFailureContext.separation);
      }

      return PrintTicketFailed(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao imprimir separação', tag: 'SeparationPrintCoordinator', error: e, stackTrace: stackTrace);
      return const PrintTicketError();
    }
  }
}
