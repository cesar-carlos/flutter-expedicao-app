/// Estados possiveis da conexao do socket.
enum SocketConnectionState { disconnected, connecting, connected, reconnecting, error }

/// Porta de dominio para comunicacao via socket.
///
/// Expoe apenas as operacoes usadas pela camada de apresentacao. Os
/// metodos [addListener] e [removeListener] usam `void Function()` (Dart
/// puro), compativel com o `Listenable`/`ChangeNotifier` implementado em
/// `data/`, sem depender de Flutter neste contrato.
abstract interface class ISocketConnectionPort {
  String? get userId;

  SocketConnectionState get connectionState;

  bool get isConnected;

  bool get isTrafficPaused;

  bool get isSessionEndedByServer;

  Future<void> connect();

  void disconnect();

  Future<void> reconnect();

  void pauseForServerDisconnect();

  Future<void> reconnectAfterServerEnd();

  Stream<dynamic> on(String eventName);

  void off(String eventName);

  void emit(String eventName, dynamic data);

  void addListener(void Function() listener);

  void removeListener(void Function() listener);
}
