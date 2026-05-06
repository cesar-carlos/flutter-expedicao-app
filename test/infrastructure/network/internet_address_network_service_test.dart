import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/infrastructure/network/internet_address_network_service.dart';

void main() {
  group('InternetAddressNetworkService', () {
    test('hasInternetConnection retorna false quando lookup retorna vazio', () async {
      final service = InternetAddressNetworkService(
        testHost: 'example.test',
        timeout: const Duration(seconds: 1),
        lookup: (_) async => <InternetAddress>[],
      );

      expect(await service.hasInternetConnection(), isFalse);
      expect(await service.isConnected(), isFalse);
    });

    test('hasInternetConnection retorna false quando lookup lanca', () async {
      final service = InternetAddressNetworkService(
        testHost: 'example.test',
        timeout: const Duration(seconds: 1),
        lookup: (_) async => throw const SocketException('dns'),
      );

      expect(await service.hasInternetConnection(), isFalse);
    });

    test('hasInternetConnection retorna true quando lookup retorna endereco valido', () async {
      final service = InternetAddressNetworkService(
        testHost: 'example.test',
        timeout: const Duration(seconds: 1),
        lookup: (_) async {
          final addr = InternetAddress.fromRawAddress(InternetAddress.loopbackIPv4.rawAddress);
          return [addr];
        },
      );

      expect(await service.hasInternetConnection(), isTrue);
    });
  });
}
