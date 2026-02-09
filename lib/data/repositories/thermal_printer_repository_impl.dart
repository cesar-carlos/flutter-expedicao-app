import 'dart:async';
import 'dart:io';

import 'package:data7_expedicao/core/network/retry_policy.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/models/thermal_print_result.dart';
import 'package:data7_expedicao/domain/repositories/thermal_printer_repository.dart';
import 'package:data7_expedicao/infrastructure/services/esc_pos_ticket_builder_service.dart';
import 'package:data7_expedicao/infrastructure/services/thermal_printer_tcp_service.dart';

class ThermalPrinterRepositoryImpl implements ThermalPrinterRepository {
  final EscPosTicketBuilderService _ticketBuilderService;
  final ThermalPrinterTcpService _tcpService;
  final RetryPolicy _retryPolicy;

  const ThermalPrinterRepositoryImpl({
    required EscPosTicketBuilderService ticketBuilderService,
    required ThermalPrinterTcpService tcpService,
    required RetryPolicy retryPolicy,
  }) : _ticketBuilderService = ticketBuilderService,
       _tcpService = tcpService,
       _retryPolicy = retryPolicy;

  @override
  Future<Result<ThermalPrintResult>> printTestTicket({required PrinterConfig printer, bool autoCut = true}) async {
    final validationFailure = _validatePrinter(printer);
    if (validationFailure != null) {
      return failure(validationFailure);
    }

    _logPrintEvent(operation: 'test', status: 'start', ip: printer.ip, port: printer.port, itemCount: 0);

    try {
      final bytes = await _ticketBuilderService.buildPrinterTestTicketBytes(
        printerName: printer.name,
        printerIp: printer.ip,
        printerPort: printer.port,
        autoCut: autoCut,
      );

      final report = await _retryPolicy.execute(
        () => _tcpService.send(ip: printer.ip, port: printer.port, bytes: bytes),
        tag: 'ThermalPrinterRepositoryImpl',
      );

      _logPrintEvent(
        operation: 'test',
        status: 'success',
        ip: report.ip,
        port: report.port,
        payloadBytes: report.payloadBytes,
        itemCount: 0,
        elapsedMs: report.elapsed.inMilliseconds,
      );

      return success(
        ThermalPrintResult(
          printerIp: report.ip,
          printerPort: report.port,
          payloadBytes: report.payloadBytes,
          itemCount: 0,
          elapsed: report.elapsed,
          printedAt: report.sentAt,
        ),
      );
    } on TimeoutException catch (e) {
      _logPrintEvent(
        operation: 'test',
        status: 'failure',
        ip: printer.ip,
        port: printer.port,
        itemCount: 0,
        errorType: 'TimeoutException',
        errorMessage: e.toString(),
      );
      return failure(NetworkFailure.connectionTimeout());
    } on SocketException catch (e) {
      _logPrintEvent(
        operation: 'test',
        status: 'failure',
        ip: printer.ip,
        port: printer.port,
        itemCount: 0,
        errorType: 'SocketException',
        errorMessage: e.message,
      );
      return failure(NetworkFailure(message: e.message));
    } on StateError catch (e) {
      _logPrintEvent(
        operation: 'test',
        status: 'failure',
        ip: printer.ip,
        port: printer.port,
        itemCount: 0,
        errorType: 'StateError',
        errorMessage: e.message,
      );
      return failure(BusinessFailure.invalidState(e.message));
    } catch (e) {
      _logPrintEvent(
        operation: 'test',
        status: 'failure',
        ip: printer.ip,
        port: printer.port,
        itemCount: 0,
        errorType: e.runtimeType.toString(),
        errorMessage: e.toString(),
      );
      return failure(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<Result<ThermalPrintResult>> printExpeditionTicket({
    required PrinterConfig printer,
    required List<ExpeditionItemPrintConsultationModel> items,
    String? separatorName,
    bool autoCut = true,
  }) async {
    final validationFailure = _validatePrinter(printer);
    if (validationFailure != null) {
      return failure(validationFailure);
    }

    if (items.isEmpty) {
      return failure(DataFailure.notFound('Itens para impressao'));
    }

    _logPrintEvent(
      operation: 'expedition',
      status: 'start',
      ip: printer.ip,
      port: printer.port,
      itemCount: items.length,
    );

    try {
      final bytes = await _ticketBuilderService.buildExpeditionTicketBytes(
        items: items,
        separatorName: separatorName,
        autoCut: autoCut,
      );

      final report = await _retryPolicy.execute(
        () => _tcpService.send(ip: printer.ip, port: printer.port, bytes: bytes),
        tag: 'ThermalPrinterRepositoryImpl',
      );

      _logPrintEvent(
        operation: 'expedition',
        status: 'success',
        ip: report.ip,
        port: report.port,
        payloadBytes: report.payloadBytes,
        itemCount: items.length,
        elapsedMs: report.elapsed.inMilliseconds,
      );

      return success(
        ThermalPrintResult(
          printerIp: report.ip,
          printerPort: report.port,
          payloadBytes: report.payloadBytes,
          itemCount: items.length,
          elapsed: report.elapsed,
          printedAt: report.sentAt,
        ),
      );
    } on TimeoutException catch (e) {
      _logPrintEvent(
        operation: 'expedition',
        status: 'failure',
        ip: printer.ip,
        port: printer.port,
        itemCount: items.length,
        errorType: 'TimeoutException',
        errorMessage: e.toString(),
      );
      return failure(NetworkFailure.connectionTimeout());
    } on SocketException catch (e) {
      _logPrintEvent(
        operation: 'expedition',
        status: 'failure',
        ip: printer.ip,
        port: printer.port,
        itemCount: items.length,
        errorType: 'SocketException',
        errorMessage: e.message,
      );
      return failure(NetworkFailure(message: e.message));
    } on StateError catch (e) {
      _logPrintEvent(
        operation: 'expedition',
        status: 'failure',
        ip: printer.ip,
        port: printer.port,
        itemCount: items.length,
        errorType: 'StateError',
        errorMessage: e.message,
      );
      return failure(BusinessFailure.invalidState(e.message));
    } catch (e) {
      _logPrintEvent(
        operation: 'expedition',
        status: 'failure',
        ip: printer.ip,
        port: printer.port,
        itemCount: items.length,
        errorType: e.runtimeType.toString(),
        errorMessage: e.toString(),
      );
      return failure(UnknownFailure.fromException(e));
    }
  }

  AppFailure? _validatePrinter(PrinterConfig printer) {
    if (printer.ip.trim().isEmpty) {
      return ValidationFailure.fromErrors(['ip/host da impressora nao pode estar vazio']);
    }

    if (printer.port < 1 || printer.port > 65535) {
      return ValidationFailure.fromErrors(['porta da impressora deve estar entre 1 e 65535']);
    }

    return null;
  }

  void _logPrintEvent({
    required String operation,
    required String status,
    required String ip,
    required int port,
    required int itemCount,
    int payloadBytes = 0,
    int elapsedMs = 0,
    String? errorType,
    String? errorMessage,
  }) {
    final message =
        'thermal_print'
        ' timestamp=${DateTime.now().toIso8601String()}'
        ' operation=$operation'
        ' status=$status'
        ' ip=$ip'
        ' port=$port'
        ' payloadBytes=$payloadBytes'
        ' itemCount=$itemCount'
        ' elapsedMs=$elapsedMs'
        ' errorType=${_sanitizeForLog(errorType)}'
        ' errorMessage=${_sanitizeForLog(errorMessage)}';

    if (status == 'failure') {
      AppLogger.error(message, tag: 'ThermalPrinterRepositoryImpl');
      return;
    }

    if (status == 'start') {
      AppLogger.debug(message, tag: 'ThermalPrinterRepositoryImpl');
      return;
    }

    AppLogger.info(message, tag: 'ThermalPrinterRepositoryImpl');
  }

  String _sanitizeForLog(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return '-';
    }
    return normalized.replaceAll('\n', ' ').replaceAll('\r', ' ');
  }
}
