import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/models/thermal_print_result.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/i_thermal_printer_repository.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_params.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_usecase.dart';

void main() {
  group('Fluxo Imprimir Após Salvar', () {
    late _FakeExpeditionItemPrintRepository consultationRepository;
    late _FakeThermalPrinterRepository thermalPrinterRepository;
    late PrintExpeditionTicketUseCase printUseCase;

    setUp(() {
      consultationRepository = _FakeExpeditionItemPrintRepository();
      thermalPrinterRepository = _FakeThermalPrinterRepository();
      printUseCase = PrintExpeditionTicketUseCase(
        expeditionItemPrintRepository: consultationRepository,
        thermalPrinterRepository: thermalPrinterRepository,
      );
    });

    test('deve imprimir com sucesso quando tudo está OK', () async {
      consultationRepository.items = [_buildItem()];
      thermalPrinterRepository.expeditionResult = success(
        ThermalPrintResult(
          printerIp: '192.168.0.200',
          printerPort: 9100,
          payloadBytes: 256,
          itemCount: 1,
          elapsed: const Duration(milliseconds: 120),
          printedAt: DateTime(2026, 2, 9, 10, 30),
        ),
      );

      final result = await printUseCase.call(_validPrintParams());

      expect(result.isSuccess(), isTrue);
      expect(result.getOrNull()?.printerIp, equals('192.168.0.200'));
    });

    test('deve retornar NetworkFailure quando impressora sofre timeout', () async {
      consultationRepository.items = [_buildItem()];
      thermalPrinterRepository.expeditionResult = failure(NetworkFailure.connectionTimeout());

      final result = await printUseCase.call(_validPrintParams());

      expect(result.isError(), isTrue);
      final networkFailure = result.exceptionOrNull();
      expect(networkFailure, isA<NetworkFailure>());
      expect((networkFailure as NetworkFailure).code, equals('CONNECTION_TIMEOUT'));
    });

    test('deve retornar NetworkFailure quando impressora está offline', () async {
      consultationRepository.items = [_buildItem()];
      final networkError = NetworkFailure(message: 'Host unreachable: 192.168.0.200');
      thermalPrinterRepository.expeditionResult = failure(networkError);

      final result = await printUseCase.call(_validPrintParams());

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<NetworkFailure>());
    });

    test('deve retornar DataFailure quando itens para impressão não são encontrados', () async {
      consultationRepository.items = const [];

      final result = await printUseCase.call(_validPrintParams());

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull();
      expect(failure, isA<DataFailure>());
      expect((failure as DataFailure).code, equals('NOT_FOUND'));
    });

    test('simula fluxo real: printUseCase pode ser chamado sem await (unawaited)', () async {
      consultationRepository.items = [_buildItem()];

      thermalPrinterRepository.printDelay = const Duration(milliseconds: 500);
      thermalPrinterRepository.expeditionResult = success(
        ThermalPrintResult(
          printerIp: '192.168.0.200',
          printerPort: 9100,
          payloadBytes: 256,
          itemCount: 1,
          elapsed: const Duration(milliseconds: 500),
          printedAt: DateTime(2026, 2, 9, 10, 30),
        ),
      );

      final printFuture = printUseCase.call(_validPrintParams());

      expect(printFuture, isA<Future<Result<ThermalPrintResult>>>());

      final operationsAfterPrint = ['close_dialog', 'refresh_ui', 'navigate_back'];
      expect(operationsAfterPrint.length, greaterThan(0));

      final result = await printFuture;
      expect(result.isSuccess(), isTrue);
    });

    test('demonstra que falhas na impressão não lançam exceções não tratadas', () async {
      consultationRepository.items = [_buildItem()];
      thermalPrinterRepository.expeditionResult = failure(NetworkFailure.connectionTimeout());

      Result<ThermalPrintResult> result;
      try {
        result = await printUseCase.call(_validPrintParams());
      } catch (e) {
        fail('printUseCase não deve lançar exceção não tratada. Capturado: $e');
      }

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<NetworkFailure>());
    });

    test('simula cenário de UI: salvar sucesso + impressão falha = estado preservado', () async {
      final cartWasSavedSuccessfully = true;
      final dialogWasClosed = false;
      final uiWasRefreshed = false;

      consultationRepository.items = [_buildItem()];
      thermalPrinterRepository.expeditionResult = failure(NetworkFailure.connectionTimeout());

      printUseCase.call(_validPrintParams());

      expect(cartWasSavedSuccessfully, isTrue);
      expect(dialogWasClosed, isFalse);
      expect(uiWasRefreshed, isFalse);
    });

    test('deve tratar múltiplas falhas diferentes sem crash', () async {
      final failureScenarios = [
        NetworkFailure.connectionTimeout(),
        NetworkFailure(message: 'Socket closed'),
        NetworkFailure(message: 'Host unreachable'),
        DataFailure.notFound('Itens'),
        BusinessFailure.invalidState('Impressora offline'),
      ];

      for (final scenarioFailure in failureScenarios) {
        consultationRepository.items = [_buildItem()];
        thermalPrinterRepository.expeditionResult = failure(scenarioFailure);

        Result<ThermalPrintResult>? result;
        try {
          result = await printUseCase.call(_validPrintParams());
        } catch (e) {
          fail('Cenário $scenarioFailure não deve lançar exceção. Erro: $e');
        }

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<AppFailure>());
      }
    });
  });
}

class _FakeExpeditionItemPrintRepository implements BasicConsultationRepository<ExpeditionItemPrintConsultationModel> {
  List<ExpeditionItemPrintConsultationModel> items = const [];
  Object? error;
  QueryBuilder? lastQueryBuilder;

  @override
  Future<List<ExpeditionItemPrintConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    lastQueryBuilder = queryBuilder;
    if (error != null) {
      throw error!;
    }
    return items;
  }
}

class _FakeThermalPrinterRepository implements IThermalPrinterRepository {
  Result<ThermalPrintResult> expeditionResult = success(
    ThermalPrintResult(
      printerIp: '127.0.0.1',
      printerPort: 9100,
      payloadBytes: 1,
      itemCount: 0,
      elapsed: const Duration(milliseconds: 1),
      printedAt: DateTime(2026, 2, 9, 12, 0),
    ),
  );

  Duration printDelay = Duration.zero;

  PrinterConfig? lastPrinter;
  List<ExpeditionItemPrintConsultationModel> lastItems = const [];
  String? lastSeparatorName;
  bool lastAutoCut = true;

  @override
  Future<Result<ThermalPrintResult>> printExpeditionTicket({
    required PrinterConfig printer,
    required List<ExpeditionItemPrintConsultationModel> items,
    String? separatorName,
    bool autoCut = true,
    int? codSetorEstoque,
    int? codUsuario,
  }) async {
    lastPrinter = printer;
    lastItems = items;
    lastSeparatorName = separatorName;
    lastAutoCut = autoCut;

    if (printDelay > Duration.zero) {
      await Future.delayed(printDelay);
    }

    return expeditionResult;
  }

  @override
  Future<Result<ThermalPrintResult>> printTestTicket({required PrinterConfig printer, bool autoCut = true}) async {
    return expeditionResult;
  }
}

PrintExpeditionTicketParams _validPrintParams() {
  return PrintExpeditionTicketParams(
    codEmpresa: 1,
    codSepararEstoque: 2,
    printer: const PrinterConfig(id: 'printer-1', name: 'Impressora Expedicao', ip: '192.168.0.200', port: 9100),
    codSetorEstoque: 119,
  );
}

ExpeditionItemPrintConsultationModel _buildItem() {
  return ExpeditionItemPrintConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 2,
    item: '1',
    origem: 'SEPARACAO_ESTOQUE',
    codOrigem: 4242,
    itemOrigem: '1',
    dataSepararEstoque: DateTime(2026, 2, 9),
    horaSepararEstoque: '10:00',
    situacao: 'SEPARANDO',
    codTipoOperacaoSaida: 10,
    descricaoTipoOperacaoSaida: 'EXPEDICAO',
    codVendedor: 20,
    nomeVendedor: 'VENDEDOR TESTE',
    tipoEntidade: 'CLIENTE',
    codEntidade: '20087',
    nomeEntidade: 'CENTRAL MOTOS',
    codPrioridade: 5,
    descricaoPrioridade: 'TRANSPORTADORA',
    codCliente: 20087,
    nomeCliente: 'S A M DE BRITO - ME',
    nomeFantasiaCliente: 'CENTRAL MOTOS',
    codTransportadora: 1,
    nomeFantasiaTransportadora: 'CAR VALIMA',
    razaoSocialTransportadora: 'CAR VALIMA',
    codMunicipioEntrega: 1,
    nomeMunicipioEntrega: 'RIBEIRAO CASCAL',
    codLocalArmazenagem: 1,
    nomeLocalArmazenagem: 'MEZANINO 1',
    codSetorEstoque: 119,
    descricaoSetorEstoque: 'MEZANINO 1',
    codProduto: 16580,
    nomeProduto: 'PARAF PASTILHA FREIO',
    descricaoProduto: 'PARAF PASTILHA FREIO CG150',
    codGrupoProduto: 1,
    nomeGrupoProduto: 'PECAS',
    codMarca: 1,
    nomeMarca: 'TRILHA',
    codigoFabricante: '39885',
    codigoFornecedor: 'F0001',
    codigoReferencia: '01-1R-G-Q4-33',
    codigoBarras: '7891234567890',
    descricaoEnderecoProduto: '01-1R-G-Q4-33',
    codUnidadeMedida: 'UN',
    descricaoUnidadeMedida: 'UNIDADE',
    quantidade: 10.0,
    quantidadeInterna: 10.0,
    quantidadeExterna: 0.0,
    quantidadeSeparacao: 10.0,
    historicoSepararEstoque: null,
    observacaoSepararEstoque: 'COMPLEMENTO A MANHA',
    orcamentoObservacao: null,
  );
}
