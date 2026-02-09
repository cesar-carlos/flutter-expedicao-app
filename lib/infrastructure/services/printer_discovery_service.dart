import 'dart:async';
import 'dart:io';

class PrinterDiscoveryEndpoint {
  final String ip;
  final int port;
  final int responseTimeMs;

  const PrinterDiscoveryEndpoint({required this.ip, required this.port, required this.responseTimeMs});
}

class PrinterDiscoveryReport {
  final String subnet;
  final List<PrinterDiscoveryEndpoint> endpoints;

  const PrinterDiscoveryReport({required this.subnet, required this.endpoints});
}

class PrinterDiscoveryService {
  const PrinterDiscoveryService();

  Future<String?> detectLocalSubnetPrefix() async {
    final localIp = await _resolveLocalPrivateIp();
    if (localIp == null) {
      return null;
    }
    return _extractPrefix(localIp);
  }

  Future<PrinterDiscoveryReport> discover({
    int port = 9100,
    Duration connectTimeout = const Duration(milliseconds: 250),
    int concurrency = 48,
    String? subnetPrefix,
    int startHost = 1,
    int endHost = 254,
  }) async {
    if (port < 1 || port > 65535) {
      throw StateError('Porta invalida para descoberta: $port');
    }

    if (startHost < 1 || startHost > 254 || endHost < 1 || endHost > 254) {
      throw StateError('Faixa de hosts invalida: $startHost-$endHost');
    }

    if (startHost > endHost) {
      throw StateError('Host inicial nao pode ser maior que host final.');
    }

    final localIp = await _resolveLocalPrivateIp();

    if (localIp == null && subnetPrefix == null) {
      throw StateError('Nao foi possivel identificar um IP local privado para descoberta.');
    }

    final resolvedPrefix = _resolvePrefix(subnetPrefix: subnetPrefix, localIp: localIp);
    final subnet = '$resolvedPrefix.$startHost-$endHost';
    final targets = _buildTargets(prefix: resolvedPrefix, localIp: localIp, startHost: startHost, endHost: endHost);
    final found = <PrinterDiscoveryEndpoint>[];

    final safeConcurrency = concurrency.clamp(1, 128);
    final queue = List<String>.from(targets);

    final workers = List.generate(safeConcurrency, (_) async {
      while (queue.isNotEmpty) {
        final host = queue.removeLast();
        final endpoint = await _probeHost(host: host, port: port, timeout: connectTimeout);
        if (endpoint != null) {
          found.add(endpoint);
        }
      }
    });

    await Future.wait(workers);

    found.sort((a, b) => a.ip.compareTo(b.ip));
    return PrinterDiscoveryReport(subnet: subnet, endpoints: found);
  }

  String _resolvePrefix({required String? subnetPrefix, required String? localIp}) {
    if (subnetPrefix != null && subnetPrefix.trim().isNotEmpty) {
      return _normalizeSubnetPrefix(subnetPrefix.trim());
    }

    if (localIp == null) {
      throw StateError('Prefixo de rede nao informado e IP local nao disponivel.');
    }

    return _extractPrefix(localIp);
  }

  String _normalizeSubnetPrefix(String value) {
    final parts = value.split('.');
    if (parts.length != 3) {
      throw StateError('Prefixo de rede invalido: $value');
    }

    final normalized = <int>[];
    for (final part in parts) {
      final parsed = int.tryParse(part);
      if (parsed == null || parsed < 0 || parsed > 255) {
        throw StateError('Prefixo de rede invalido: $value');
      }
      normalized.add(parsed);
    }

    return '${normalized[0]}.${normalized[1]}.${normalized[2]}';
  }

  Future<String?> _resolveLocalPrivateIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        final ip = address.address;
        if (_isPrivateIpv4(ip)) {
          return ip;
        }
      }
    }

    return null;
  }

  bool _isPrivateIpv4(String ip) {
    final octets = ip.split('.');
    if (octets.length != 4) return false;

    final a = int.tryParse(octets[0]);
    final b = int.tryParse(octets[1]);
    if (a == null || b == null) return false;

    if (a == 10) return true;
    if (a == 192 && b == 168) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    return false;
  }

  String _extractPrefix(String ip) {
    final octets = ip.split('.');
    if (octets.length != 4) {
      throw StateError('IP local invalido para descoberta: $ip');
    }
    return '${octets[0]}.${octets[1]}.${octets[2]}';
  }

  List<String> _buildTargets({
    required String prefix,
    required String? localIp,
    required int startHost,
    required int endHost,
  }) {
    final targets = <String>[];
    for (var host = startHost; host <= endHost; host++) {
      final ip = '$prefix.$host';
      if (localIp != null && ip == localIp) continue;
      targets.add(ip);
    }
    return targets;
  }

  Future<PrinterDiscoveryEndpoint?> _probeHost({
    required String host,
    required int port,
    required Duration timeout,
  }) async {
    Socket? socket;
    final stopwatch = Stopwatch()..start();

    try {
      socket = await Socket.connect(host, port, timeout: timeout);
      stopwatch.stop();
      return PrinterDiscoveryEndpoint(ip: host, port: port, responseTimeMs: stopwatch.elapsedMilliseconds);
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    } finally {
      socket?.destroy();
    }
  }
}
