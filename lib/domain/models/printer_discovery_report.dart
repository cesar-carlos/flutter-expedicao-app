class PrinterDiscoveryEndpoint {
  final String ip;
  final int port;
  final int responseTimeMs;

  const PrinterDiscoveryEndpoint({
    required this.ip,
    required this.port,
    required this.responseTimeMs,
  });
}

class PrinterDiscoveryReport {
  final String subnet;
  final List<PrinterDiscoveryEndpoint> endpoints;

  const PrinterDiscoveryReport({
    required this.subnet,
    required this.endpoints,
  });
}
