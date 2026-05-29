import 'dart:async';
import 'dart:io';

import 'package:data7_expedicao/core/network/ambiguous_send_exception.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/thermal_printer_tcp_send_report.dart';
import 'package:data7_expedicao/domain/repositories/i_thermal_printer_tcp_service.dart';

class ThermalPrinterTcpService implements IThermalPrinterTcpService {
  const ThermalPrinterTcpService();

  @override
  Future<ThermalPrinterTcpSendReport> send({
    required String ip,
    required int port,
    required List<int> bytes,
    Duration connectTimeout = const Duration(seconds: 3),
    Duration writeTimeout = const Duration(seconds: 5),
  }) async {
    if (ip.trim().isEmpty) {
      throw StateError('IP/host da impressora nao pode estar vazio.');
    }

    if (port < 1 || port > 65535) {
      throw StateError('Porta da impressora invalida: $port');
    }

    if (bytes.isEmpty) {
      throw StateError('Payload de impressao vazio.');
    }

    Socket? socket;
    final stopwatch = Stopwatch()..start();

    _safeDebug(
      'thermal_tcp_send timestamp=${DateTime.now().toIso8601String()} status=start ip=$ip port=$port payloadBytes=${bytes.length}',
    );

    // Fase de conexao: falhas aqui sao seguras para retry, pois os bytes
    // ainda NAO foram enviados.
    try {
      socket = await Socket.connect(ip, port, timeout: connectTimeout);
    } catch (e) {
      stopwatch.stop();
      _logFailure(ip: ip, port: port, payloadBytes: bytes.length, stopwatch: stopwatch, error: e);
      rethrow;
    }

    // Fase de envio: a partir de `add`, os bytes podem ter chegado a
    // impressora. Qualquer falha aqui e ambigua e NAO deve ser retentada
    // (evita ticket duplicado).
    try {
      socket.add(bytes);
      await socket.flush().timeout(writeTimeout);
    } catch (e, s) {
      stopwatch.stop();
      _logFailure(ip: ip, port: port, payloadBytes: bytes.length, stopwatch: stopwatch, error: e);
      socket.destroy();
      throw AmbiguousSendException(
        'Falha apos inicio do envio TCP para $ip:$port; impressao pode ter ocorrido',
        e,
        s,
      );
    }

    // Bytes ja foram enviados (flush concluido). A limpeza abaixo e
    // best-effort: uma falha ao fechar nao invalida o envio.
    try {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      await socket.close();
    } catch (_) {
      // Bytes ja enviados; falha ao fechar nao invalida o envio.
    } finally {
      socket.destroy();
    }
    socket = null;
    stopwatch.stop();

    _safeInfo(
      'thermal_tcp_send timestamp=${DateTime.now().toIso8601String()} status=success ip=$ip port=$port payloadBytes=${bytes.length} elapsedMs=${stopwatch.elapsedMilliseconds}',
    );

    return ThermalPrinterTcpSendReport(
      ip: ip,
      port: port,
      payloadBytes: bytes.length,
      elapsed: stopwatch.elapsed,
      sentAt: DateTime.now(),
    );
  }

  void _logFailure({
    required String ip,
    required int port,
    required int payloadBytes,
    required Stopwatch stopwatch,
    required Object error,
  }) {
    _safeError(
      'thermal_tcp_send timestamp=${DateTime.now().toIso8601String()} status=failure ip=$ip port=$port payloadBytes=$payloadBytes elapsedMs=${stopwatch.elapsedMilliseconds} errorType=${error.runtimeType} errorMessage=${error.toString().replaceAll('\n', ' ').replaceAll('\r', ' ')}',
    );
  }

  void _safeDebug(String message) {
    try {
      AppLogger.debug(message, tag: 'ThermalPrinterTcpService');
    } catch (_) {}
  }

  void _safeInfo(String message) {
    try {
      AppLogger.info(message, tag: 'ThermalPrinterTcpService');
    } catch (_) {}
  }

  void _safeError(String message) {
    try {
      AppLogger.error(message, tag: 'ThermalPrinterTcpService');
    } catch (_) {}
  }
}
