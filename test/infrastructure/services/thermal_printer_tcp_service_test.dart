import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/infrastructure/services/thermal_printer_tcp_service.dart';

void main() {
  group('ThermalPrinterTcpService', () {
    late ThermalPrinterTcpService service;

    setUp(() {
      service = const ThermalPrinterTcpService();
    });

    test('deve enviar bytes para servidor TCP local', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      final received = Completer<List<int>>();

      server.listen((client) {
        final bytes = <int>[];
        client.listen(
          bytes.addAll,
          onDone: () {
            if (!received.isCompleted) {
              received.complete(bytes);
            }
          },
        );
      });

      const payload = 'TESTE IMPRESSAO';
      final payloadBytes = utf8.encode(payload);

      final report = await service.send(ip: '127.0.0.1', port: port, bytes: payloadBytes);

      final data = await received.future.timeout(const Duration(seconds: 2));

      expect(report.ip, equals('127.0.0.1'));
      expect(report.port, equals(port));
      expect(report.payloadBytes, equals(payloadBytes.length));
      expect(data, equals(payloadBytes));

      await server.close();
    });

    test('deve lançar erro com payload vazio', () async {
      expect(() => service.send(ip: '127.0.0.1', port: 9100, bytes: const []), throwsA(isA<StateError>()));
    });
  });
}
