import 'package:data7_expedicao/domain/models/thermal_printer_tcp_send_report.dart';

abstract class IThermalPrinterTcpService {
  Future<ThermalPrinterTcpSendReport> send({
    required String ip,
    required int port,
    required List<int> bytes,
    Duration connectTimeout = const Duration(seconds: 3),
    Duration writeTimeout = const Duration(seconds: 5),
  });
}
