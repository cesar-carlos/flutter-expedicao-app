import 'dart:io';

import 'package:data7_expedicao/core/network/network_service.dart';

typedef InternetAddressLookup = Future<List<InternetAddress>> Function(String host);

/// Implementação de [NetworkService] usando DNS lookup.
///
/// Verifica a conectividade tentando resolver o DNS de um host conhecido.
/// Esta abordagem é mais confiável que verificar apenas o status da interface de rede.
class InternetAddressNetworkService implements NetworkService {
  /// Host usado para verificar conectividade.
  final String testHost;

  /// Timeout máximo para a verificação de DNS.
  final Duration timeout;

  final InternetAddressLookup _lookup;

  /// Cria uma nova instância de [InternetAddressNetworkService].
  ///
  /// [testHost] é o host usado para verificar a conectividade (padrão: 'github.com').
  /// [timeout] é o tempo máximo de espera pela resposta do DNS (padrão: 3 segundos).
  /// [lookup] permite substituir [InternetAddress.lookup] em testes.
  InternetAddressNetworkService({
    this.testHost = 'github.com',
    this.timeout = const Duration(seconds: 3),
    InternetAddressLookup? lookup,
  }) : _lookup = lookup ?? InternetAddress.lookup;

  @override
  Future<bool> hasInternetConnection() async {
    try {
      final lookup = await _lookup(testHost).timeout(timeout);
      return lookup.isNotEmpty && lookup.any((addr) => addr.rawAddress.isNotEmpty);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isConnected() async {
    return await hasInternetConnection();
  }
}
