import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/thermal_print_result.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/thermal_printer_repository.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_params.dart';

/// Use case para impressão de ticket de expedição
///
/// Responsabilidades:
/// - Consultar itens de expedição para impressão baseados em empresa e separação
/// - Aplicar filtro de setor de estoque se fornecido (isolamento por setor)
/// - Validar parâmetros de impressora (nome, IP, porta)
/// - Gerar comandos ESC/POS para impressora térmica
/// - Enviar comandos via TCP para impressora
/// - Retornar resultado da impressão com métricas (bytes, tempo, quantidade)
///
/// Fluxo de execução:
/// 1. Valida parâmetros (empresa, separação, impressora)
/// 2. Monta QueryBuilder com filtros (empresa, separação, setor opcional)
/// 3. Consulta itens de expedição no repositório
/// 4. Delega impressão ao ThermalPrinterRepository
/// 5. Retorna sucesso com métricas ou falha específica
///
/// Tratamento de erros:
/// - ValidationFailure: parâmetros inválidos
/// - DataFailure: itens não encontrados (NOT_FOUND)
/// - NetworkFailure: erros de conexão com impressora
/// - UnknownFailure: erros inesperados
class PrintExpeditionTicketUseCase {
  final BasicConsultationRepository<ExpeditionItemPrintConsultationModel> _expeditionItemPrintRepository;
  final ThermalPrinterRepository _thermalPrinterRepository;

  const PrintExpeditionTicketUseCase({
    required BasicConsultationRepository<ExpeditionItemPrintConsultationModel> expeditionItemPrintRepository,
    required ThermalPrinterRepository thermalPrinterRepository,
  }) : _expeditionItemPrintRepository = expeditionItemPrintRepository,
       _thermalPrinterRepository = thermalPrinterRepository;

  Future<Result<ThermalPrintResult>> call(PrintExpeditionTicketParams params) async {
    if (!params.isValid) {
      return failure(ValidationFailure.fromErrors(params.validationErrors));
    }

    try {
      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', params.codEmpresa.toString())
        ..equals('CodSepararEstoque', params.codSepararEstoque.toString());

      // Adiciona filtro de setor se fornecido
      if (params.codSetorEstoque != null && params.codSetorEstoque! > 0) {
        queryBuilder.equals('CodSetorEstoque', params.codSetorEstoque.toString());
      }

      queryBuilder.orderByAsc('Item');

      final items = await _expeditionItemPrintRepository.selectConsultation(queryBuilder);
      if (items.isEmpty) {
        return failure(DataFailure.notFound('Itens para impressao da separacao ${params.codSepararEstoque}'));
      }

      return _thermalPrinterRepository.printExpeditionTicket(
        printer: params.printer,
        items: items,
        separatorName: params.separatorName,
        autoCut: params.autoCut,
        codSetorEstoque: params.codSetorEstoque,
        codUsuario: params.codUsuario,
      );
    } on DataError catch (e) {
      return failure(NetworkFailure(message: e.message));
    } catch (e) {
      return failure(UnknownFailure.fromException(e));
    }
  }
}
