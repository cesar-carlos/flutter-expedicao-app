class ThermalPrinterTcpSendReport {
  final String ip;
  final int port;
  final int payloadBytes;
  final Duration elapsed;
  final DateTime sentAt;

  const ThermalPrinterTcpSendReport({
    required this.ip,
    required this.port,
    required this.payloadBytes,
    required this.elapsed,
    required this.sentAt,
  });
}
