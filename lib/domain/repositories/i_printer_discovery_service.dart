import 'package:data7_expedicao/domain/models/printer_discovery_report.dart';

abstract class IPrinterDiscoveryService {
  Future<String?> detectLocalSubnetPrefix();

  Future<PrinterDiscoveryReport> discover({
    int port = 9100,
    Duration connectTimeout = const Duration(milliseconds: 250),
    int concurrency = 48,
    String? subnetPrefix,
    int startHost = 1,
    int endHost = 254,
  });
}
