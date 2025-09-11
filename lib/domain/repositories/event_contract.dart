import 'package:exp/domain/models/repository_event_listener_model.dart';

/// Contrato para gerenciamento de eventos de repositório
abstract class EventContract {
  /// Lista de listeners registrados
  List<RepositoryEventListenerModel> get listeners;

  /// Adiciona um listener de evento
  void addListener(RepositoryEventListenerModel listener);

  /// Remove um listener específico
  void removeListener(RepositoryEventListenerModel listener);

  /// Remove múltiplos listeners
  void removeListeners(List<RepositoryEventListenerModel> listeners);

  /// Remove listener por ID
  void removeListenerById(String id);

  /// Remove todos os listeners
  void removeAllListeners();

  /// Verifica se um listener existe
  bool hasListener(String id);

  /// Obtém listener por ID
  RepositoryEventListenerModel? getListenerById(String id);
}
