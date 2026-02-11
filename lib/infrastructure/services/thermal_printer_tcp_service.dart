import 'dart:async';
import 'dart:io';

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

    try {
      _safeDebug(
        'thermal_tcp_send timestamp=${DateTime.now().toIso8601String()} status=start ip=$ip port=$port payloadBytes=${bytes.length}',
      );

      socket = await Socket.connect(ip, port, timeout: connectTimeout);
      socket.add(bytes);
      await socket.flush().timeout(writeTimeout);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      await socket.close();
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
    } catch (e) {
      _safeError(
        'thermal_tcp_send timestamp=${DateTime.now().toIso8601String()} status=failure ip=$ip port=$port payloadBytes=${bytes.length} elapsedMs=${stopwatch.elapsedMilliseconds} errorType=${e.runtimeType} errorMessage=${e.toString().replaceAll('\n', ' ').replaceAll('\r', ' ')}',
      );
      rethrow;
    } finally {
      socket?.destroy();
    }
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
