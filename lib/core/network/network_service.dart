/// Interface para serviços de verificação de conectividade de rede.
///
/// Permite abstrair a implementação concreta de verificação de rede,
/// facilitando testes e permitindo múltiplas implementações.
abstract class NetworkService {
  /// Verifica se o dispositivo possui conexão com a internet disponível.
  ///
  /// Retorna `true` se houver conectividade, `false` caso contrário.
  Future<bool> hasInternetConnection();

  /// Verifica se o dispositivo está conectado a alguma rede.
  ///
  /// Retorna `true` se houver conexão de rede disponível, `false` caso contrário.
  Future<bool> isConnected();
}
