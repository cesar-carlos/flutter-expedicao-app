/// Rastreia futures em andamento agrupados por `itemId`.
///
/// Extraído de `CardPickingViewModel` (refator F3) para isolar o
/// gerenciamento do map `Map<String, List<Future<void>>>`. A orquestração
/// real (validação, chamada do use case, atualização do `PickingStateManager`)
/// permanece na ViewModel — este tracker só cuida de:
///
/// - registrar uma operação como pendente
/// - removê-la automaticamente ao finalizar (sucesso ou falha)
/// - permitir aguardar todas as operações em andamento
///
/// Útil para implementar "salvar carrinho só depois que toda sincronização
/// pendente terminar".
class PickingPendingOperationsTracker {
  final Map<String, List<Future<void>>> _operations = {};

  /// Verdadeiro se não há nenhuma operação pendente.
  bool get isEmpty => _operations.isEmpty;

  /// Verdadeiro se há pelo menos uma operação pendente.
  bool get isNotEmpty => _operations.isNotEmpty;

  /// Total de operações em andamento (somando todos os itens).
  int get count => _operations.values.fold(0, (sum, list) => sum + list.length);

  /// Registra uma `operation` em andamento, indexada por `itemId`.
  /// Ela é removida automaticamente ao finalizar (sucesso ou erro).
  ///
  /// Se ninguém estiver `await`-ando a `operation` (callers fire-and-forget),
  /// erros não tratados não viram "uncaught" porque o tracker registra um
  /// listener silencioso. Quem fizer `await` continua recebendo o erro
  /// normalmente — múltiplos listeners convivem em um Future.
  void track(String itemId, Future<void> operation) {
    _operations.putIfAbsent(itemId, () => []).add(operation);
    // whenComplete retorna outro future que re-emite o erro original;
    // anexamos catchError silencioso nele para não vazar uncaught error.
    // Quem fizer `await operation` continua recebendo o erro normalmente
    // (Future Dart suporta múltiplos listeners independentes).
    operation
        .whenComplete(() {
          final list = _operations[itemId];
          if (list == null) return;
          list.remove(operation);
          if (list.isEmpty) {
            _operations.remove(itemId);
          }
        })
        .catchError(_noopError);
  }

  static void _noopError(Object _, StackTrace _) {}

  /// Aguarda todas as operações em andamento finalizarem.
  ///
  /// Erros individuais são silenciados aqui — o objetivo é apenas saber
  /// quando todas terminaram. Quem aguarda cada operação separadamente
  /// continua responsável por tratar seu próprio erro.
  ///
  /// Se [timeout] for informado, retorna após esse limite mesmo que alguma
  /// operação não tenha completado, evitando travar indefinidamente quando
  /// uma sincronização fica pendurada (ex.: socket morto).
  Future<void> waitForAll({Duration? timeout}) async {
    if (_operations.isEmpty) return;
    final all = _operations.values
        .expand((list) => list)
        .map<Future<dynamic>>((f) => f.catchError(_noopError))
        .toList();
    final combined = Future.wait(all, eagerError: false);
    if (timeout == null) {
      await combined;
    } else {
      await combined.timeout(timeout, onTimeout: () => const <dynamic>[]);
    }
  }

  /// Remove tudo (sem cancelar futures em andamento).
  void clear() {
    _operations.clear();
  }
}
