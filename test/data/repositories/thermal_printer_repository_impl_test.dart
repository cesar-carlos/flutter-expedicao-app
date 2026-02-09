import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/network/retry_policy.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/i_logger.dart';
import 'package:data7_expedicao/data/repositories/thermal_printer_repository_impl.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/infrastructure/services/esc_pos_ticket_builder_service.dart';
import 'package:data7_expedicao/infrastructure/services/thermal_printer_tcp_service.dart';

void main() {
  group('ThermalPrinterRepositoryImpl', () {
    late _FakeEscPosTicketBuilderService ticketBuilderService;
    late _FakeThermalPrinterTcpService tcpService;
    late _FakeRetryPolicy retryPolicy;
    late ThermalPrinterRepositoryImpl repository;

    setUpAll(() {
      if (locator.isRegistered<ILogger>()) {
        locator.unregister<ILogger>();
      }
      locator.registerSingleton<ILogger>(_SilentLogger());
    });

    tearDownAll(() {
      if (locator.isRegistered<ILogger>()) {
        locator.unregister<ILogger>();
      }
    });

    setUp(() {
      ticketBuilderService = _FakeEscPosTicketBuilderService();
      tcpService = _FakeThermalPrinterTcpService();
      retryPolicy = _FakeRetryPolicy(maxTries: 1);
      repository = ThermalPrinterRepositoryImpl(
        ticketBuilderService: ticketBuilderService,
        tcpService: tcpService,
        retryPolicy: retryPolicy,
      );
    });

    test('deve retornar ValidationFailure quando ip for vazio', () async {
      final result = await repository.printExpeditionTicket(
        printer: const PrinterConfig(id: '1', name: 'IMP', ip: '', port: 9100),
        items: [_buildItem()],
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<ValidationFailure>());
    });

    test('deve retornar ValidationFailure quando porta for invalida', () async {
      final result = await repository.printTestTicket(
        printer: const PrinterConfig(
          id: '1',
          name: 'IMP',
          ip: '192.168.0.10',
          port: 70000,
        ),
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<ValidationFailure>());
    });

    test('deve retornar DataFailure quando itens estiverem vazios', () async {
      final result = await repository.printExpeditionTicket(
        printer: const PrinterConfig(
          id: '1',
          name: 'IMP',
          ip: '192.168.0.10',
          port: 9100,
        ),
        items: const [],
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<DataFailure>());
      expect(
        (result.exceptionOrNull() as DataFailure).code,
        equals('NOT_FOUND'),
      );
    });

    test('deve retornar sucesso na impressao de expedicao', () async {
      tcpService.scriptedResponses = [_buildSendReport()];

      final result = await repository.printExpeditionTicket(
        printer: const PrinterConfig(
          id: '1',
          name: 'IMP',
          ip: '192.168.0.10',
          port: 9100,
        ),
        items: [_buildItem()],
        separatorName: 'JOAO',
      );

      expect(result.isSuccess(), isTrue);
      expect(ticketBuilderService.expeditionCalls, equals(1));
      expect(ticketBuilderService.lastSeparatorName, equals('JOAO'));
      expect(tcpService.sendCalls, equals(1));

      final successResult = result.getOrNull();
      expect(successResult, isNotNull);
      expect(successResult!.printerIp, equals('192.168.0.10'));
      expect(successResult.printerPort, equals(9100));
      expect(successResult.payloadBytes, equals(3));
      expect(successResult.itemCount, equals(1));
    });

    test('deve retornar sucesso na impressao de teste', () async {
      tcpService.scriptedResponses = [_buildSendReport()];

      final result = await repository.printTestTicket(
        printer: const PrinterConfig(
          id: '1',
          name: 'IMP TESTE',
          ip: '192.168.0.10',
          port: 9100,
        ),
      );

      expect(result.isSuccess(), isTrue);
      expect(ticketBuilderService.testCalls, equals(1));
      expect(tcpService.sendCalls, equals(1));

      final successResult = result.getOrNull();
      expect(successResult, isNotNull);
      expect(successResult!.itemCount, equals(0));
      expect(successResult.payloadBytes, equals(3));
    });

    test('deve mapear TimeoutException para NetworkFailure', () async {
      tcpService.scriptedResponses = [TimeoutException('timeout')];

      final result = await repository.printExpeditionTicket(
        printer: const PrinterConfig(
          id: '1',
          name: 'IMP',
          ip: '192.168.0.10',
          port: 9100,
        ),
        items: [_buildItem()],
      );

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull();
      expect(failure, isA<NetworkFailure>());
      expect((failure as NetworkFailure).code, equals('CONNECTION_TIMEOUT'));
    });

    test('deve mapear SocketException para NetworkFailure', () async {
      tcpService.scriptedResponses = [const SocketException('offline')];

      final result = await repository.printExpeditionTicket(
        printer: const PrinterConfig(
          id: '1',
          name: 'IMP',
          ip: '192.168.0.10',
          port: 9100,
        ),
        items: [_buildItem()],
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<NetworkFailure>());
    });

    test('deve mapear StateError para BusinessFailure', () async {
      tcpService.scriptedResponses = [StateError('estado invalido')];

      final result = await repository.printExpeditionTicket(
        printer: const PrinterConfig(
          id: '1',
          name: 'IMP',
          ip: '192.168.0.10',
          port: 9100,
        ),
        items: [_buildItem()],
      );

      expect(result.isError(), isTrue);
      final failure = result.exceptionOrNull();
      expect(failure, isA<BusinessFailure>());
      expect((failure as BusinessFailure).code, equals('INVALID_STATE'));
    });

    test('deve mapear excecao desconhecida para UnknownFailure', () async {
      tcpService.scriptedResponses = [FormatException('erro generico')];

      final result = await repository.printExpeditionTicket(
        printer: const PrinterConfig(
          id: '1',
          name: 'IMP',
          ip: '192.168.0.10',
          port: 9100,
        ),
        items: [_buildItem()],
      );

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<UnknownFailure>());
    });

    test('deve realizar retry e obter sucesso na segunda tentativa', () async {
      retryPolicy = _FakeRetryPolicy(maxTries: 3);
      repository = ThermalPrinterRepositoryImpl(
        ticketBuilderService: ticketBuilderService,
        tcpService: tcpService,
        retryPolicy: retryPolicy,
      );

      tcpService.scriptedResponses = [
        const SocketException('offline'),
        _buildSendReport(),
      ];

      final result = await repository.printExpeditionTicket(
        printer: const PrinterConfig(
          id: '1',
          name: 'IMP',
          ip: '192.168.0.10',
          port: 9100,
        ),
        items: [_buildItem()],
      );

      expect(result.isSuccess(), isTrue);
      expect(retryPolicy.executeCalls, equals(1));
      expect(tcpService.sendCalls, equals(2));
    });
  });
}

ThermalPrinterTcpSendReport _buildSendReport() {
  return ThermalPrinterTcpSendReport(
    ip: '192.168.0.10',
    port: 9100,
    payloadBytes: 3,
    elapsed: const Duration(milliseconds: 50),
    sentAt: DateTime(2026, 2, 9, 13, 0),
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

class _FakeEscPosTicketBuilderService extends EscPosTicketBuilderService {
  int expeditionCalls = 0;
  int testCalls = 0;
  String? lastSeparatorName;
  Object? expeditionError;
  Object? testError;

  @override
  Future<List<int>> buildExpeditionTicketBytes({
    required List<ExpeditionItemPrintConsultationModel> items,
    String? separatorName,
    Uint8List? logoBytes,
    int logoMaxWidthPx = 576,
    bool autoCut = true,
  }) async {
    expeditionCalls++;
    lastSeparatorName = separatorName;
    if (expeditionError != null) {
      throw expeditionError!;
    }
    return [1, 2, 3];
  }

  @override
  Future<List<int>> buildPrinterTestTicketBytes({
    required String printerName,
    required String printerIp,
    required int printerPort,
    Uint8List? logoBytes,
    int logoMaxWidthPx = 576,
    bool autoCut = true,
  }) async {
    testCalls++;
    if (testError != null) {
      throw testError!;
    }
    return [1, 2, 3];
  }
}

class _FakeThermalPrinterTcpService extends ThermalPrinterTcpService {
  int sendCalls = 0;
  List<dynamic> scriptedResponses = [];

  @override
  Future<ThermalPrinterTcpSendReport> send({
    required String ip,
    required int port,
    required List<int> bytes,
    Duration connectTimeout = const Duration(seconds: 3),
    Duration writeTimeout = const Duration(seconds: 5),
  }) async {
    sendCalls++;

    if (scriptedResponses.isNotEmpty) {
      final response = scriptedResponses.removeAt(0);
      if (response is ThermalPrinterTcpSendReport) {
        return response;
      }
      throw response;
    }

    return _buildSendReport();
  }
}

class _FakeRetryPolicy extends RetryPolicy {
  final int maxTries;
  int executeCalls = 0;

  _FakeRetryPolicy({required this.maxTries}) : super(maxAttempts: 1);

  @override
  Future<T> execute<T>(Future<T> Function() operation, {String? tag}) async {
    executeCalls++;

    Object? lastError;
    for (var attempt = 1; attempt <= maxTries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        lastError = e;
        if (attempt == maxTries) {
          rethrow;
        }
      }
    }

    throw lastError ?? StateError('retry sem erro capturado');
  }
}

class _SilentLogger implements ILogger {
  @override
  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void info(String message, {String? tag}) {}

  @override
  void severe(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {}
}
