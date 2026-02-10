import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/models/thermal_print_result.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/thermal_printer_repository.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_params.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_usecase.dart';

void main() {
  group('PrintExpeditionTicketUseCase', () {
    late _FakeExpeditionItemPrintRepository consultationRepository;
    late _FakeThermalPrinterRepository thermalPrinterRepository;
    late PrintExpeditionTicketUseCase useCase;

    setUp(() {
      consultationRepository = _FakeExpeditionItemPrintRepository();
      thermalPrinterRepository = _FakeThermalPrinterRepository();
      useCase = PrintExpeditionTicketUseCase(
        expeditionItemPrintRepository: consultationRepository,
        thermalPrinterRepository: thermalPrinterRepository,
      );
    });

    test('deve retornar ValidationFailure quando params forem invalidos', () async {
      final params = PrintExpeditionTicketParams(
        codEmpresa: 0,
        codSepararEstoque: 0,
        printer: const PrinterConfig(id: '1', name: '', ip: '', port: 70000),
      );

      final result = await useCase.call(params);

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull();
      expect(failure, isA<ValidationFailure>());
    });

    test('deve retornar DataFailure quando consulta de itens vier vazia', () async {
      consultationRepository.items = const [];

      final result = await useCase.call(_validParams());

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull();
      expect(failure, isA<DataFailure>());
      expect((failure as DataFailure).code, equals('NOT_FOUND'));
    });

    test('deve mapear DataError para NetworkFailure', () async {
      consultationRepository.error = DataError(message: 'socket indisponivel');

      final result = await useCase.call(_validParams());

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull();
      expect(failure, isA<NetworkFailure>());
      expect((failure as NetworkFailure).message, contains('socket indisponivel'));
    });

    test('deve consultar itens e enviar para repositorio termico com sucesso', () async {
      consultationRepository.items = [_buildItem()];

      final expectedPrintResult = ThermalPrintResult(
        printerIp: '192.168.0.200',
        printerPort: 9100,
        payloadBytes: 256,
        itemCount: 1,
        elapsed: const Duration(milliseconds: 120),
        printedAt: DateTime(2026, 2, 9, 10, 30),
      );
      thermalPrinterRepository.expeditionResult = success(expectedPrintResult);

      final params = _validParams(separatorName: 'JOAO');
      final result = await useCase.call(params);

      expect(result.isSuccess(), isTrue);
      final successResult = result.getOrNull();
      expect(successResult, isNotNull);
      expect(successResult!.printerIp, equals(expectedPrintResult.printerIp));
      expect(successResult.printerPort, equals(expectedPrintResult.printerPort));
      expect(successResult.payloadBytes, equals(expectedPrintResult.payloadBytes));
      expect(successResult.itemCount, equals(1));

      expect(thermalPrinterRepository.lastPrinter, isNotNull);
      expect(thermalPrinterRepository.lastPrinter!.ip, equals('192.168.0.200'));
      expect(thermalPrinterRepository.lastItems.length, equals(1));
      expect(thermalPrinterRepository.lastSeparatorName, equals('JOAO'));

      final capturedQuery = consultationRepository.lastQueryBuilder;
      expect(capturedQuery, isNotNull);
      expect(capturedQuery!.buildSqlWhere(), contains("CodEmpresa = '1'"));
      expect(capturedQuery.buildSqlWhere(), contains("CodSepararEstoque = '2'"));
      expect(capturedQuery.buildOrderByQuery(), equals('order_by=Item&order_direction=ASC'));
    });
  });
}

PrintExpeditionTicketParams _validParams({String? separatorName}) {
  return PrintExpeditionTicketParams(
    codEmpresa: 1,
    codSepararEstoque: 2,
    printer: const PrinterConfig(id: 'printer-1', name: 'Impressora Expedicao', ip: '192.168.0.200', port: 9100),
    separatorName: separatorName,
    autoCut: true,
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

class _FakeThermalPrinterRepository implements ThermalPrinterRepository {
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
    return expeditionResult;
  }

  @override
  Future<Result<ThermalPrintResult>> printTestTicket({required PrinterConfig printer, bool autoCut = true}) async {
    return expeditionResult;
  }
}
