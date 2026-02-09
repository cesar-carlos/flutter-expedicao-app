class ThermalPrintResult {
  final String printerIp;
  final int printerPort;
  final int payloadBytes;
  final int itemCount;
  final Duration elapsed;
  final DateTime printedAt;

  const ThermalPrintResult({
    required this.printerIp,
    required this.printerPort,
    required this.payloadBytes,
    required this.itemCount,
    required this.elapsed,
    required this.printedAt,
  });
}
