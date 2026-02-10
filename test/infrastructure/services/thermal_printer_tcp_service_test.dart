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

    test('deve lançar SocketException com host inexistente', () async {
      // Usa um IP não roteável que garantidamente não existe na rede local
      const nonExistentIp = '192.168.255.254';

      expect(
        () => service.send(
          ip: nonExistentIp,
          port: 9100,
          bytes: utf8.encode('TEST'),
          connectTimeout: const Duration(seconds: 2),
        ),
        throwsA(isA<SocketException>()),
      );
    });

    test('deve lançar erro ao desconectar durante escrita', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;

      server.listen((client) {
        // Fecha a conexão imediatamente ao receber dados
        client.add(<int>[]);
        client.close();
      });

      expect(
        () => service.send(
          ip: '127.0.0.1',
          port: port,
          bytes: utf8.encode('TEST' * 1000), // Payload maior para garantir flush pendente
          writeTimeout: const Duration(seconds: 2),
        ),
        throwsA(anyOf(isA<SocketException>(), isA<StateError>())),
      );

      await server.close();
    });

    test('deve lançar TimeoutException ao exceder tempo de conexão', () async {
      // Usa um IP que pode existir mas não responde (blackhole)
      // Usamos firewall blocking ou IP não roteável
      const blackholeIp = '10.255.255.1';

      expect(
        () => service.send(
          ip: blackholeIp,
          port: 9100,
          bytes: utf8.encode('TEST'),
          connectTimeout: const Duration(milliseconds: 100),
        ),
        throwsA(anyOf(isA<TimeoutException>(), isA<SocketException>())),
        reason: 'Deve falhar com timeout ou socket exception para host não responsivo',
      );
    });

    test('deve validar IP vazio', () async {
      expect(
        () => service.send(ip: '  ', port: 9100, bytes: utf8.encode('TEST')),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('IP/host'),
        )),
      );
    });

    test('deve validar porta fora do range', () async {
      expect(
        () => service.send(ip: '127.0.0.1', port: 0, bytes: utf8.encode('TEST')),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Porta'),
        )),
      );

      expect(
        () => service.send(ip: '127.0.0.1', port: 65536, bytes: utf8.encode('TEST')),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Porta'),
        )),
      );
    });

    test('deve medir tempo de envio corretamente', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;

      server.listen((client) {
        client.listen((_) {}, onDone: client.close);
      });

      final payload = utf8.encode('TESTE DE PERFORMANCE');
      final report = await service.send(
        ip: '127.0.0.1',
        port: port,
        bytes: payload,
      );

      expect(report.elapsed.inMilliseconds, greaterThan(0), reason: 'Deve medir tempo positivo');
      expect(report.sentAt, isNotNull, reason: 'Deve registrar timestamp');
      expect(report.payloadBytes, equals(payload.length));

      await server.close();
    });
  });
}
