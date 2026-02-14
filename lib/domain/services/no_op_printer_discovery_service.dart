import 'package:data7_expedicao/domain/models/printer_discovery_report.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_discovery_service.dart';

class NoOpPrinterDiscoveryService implements IPrinterDiscoveryService {
  const NoOpPrinterDiscoveryService();

  @override
  Future<String?> detectLocalSubnetPrefix() async => null;

  @override
  Future<PrinterDiscoveryReport> discover({
    int port = 9100,
    Duration connectTimeout = const Duration(milliseconds: 250),
    int concurrency = 48,
    String? subnetPrefix,
    int startHost = 1,
    int endHost = 254,
  }) async =>
      const PrinterDiscoveryReport(subnet: '', endpoints: []);
}
