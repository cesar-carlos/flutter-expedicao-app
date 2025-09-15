import 'package:exp/domain/models/event_model/event_listener_model.dart';

/// Contrato para gerenciamento de eventos de repositório
abstract class EventContract {
  /// Lista de listeners registrados
  List<EventListenerModel> get listeners;

  /// Adiciona um listener de evento
  void addListener(EventListenerModel listener);

  /// Remove um listener específico
  void removeListener(EventListenerModel listener);

  /// Remove múltiplos listeners
  void removeListeners(List<EventListenerModel> listeners);

  /// Remove listener por ID
  void removeListenerById(String id);

  /// Remove todos os listeners
  void removeAllListeners();

  /// Verifica se um listener existe
  bool hasListener(String id);

  /// Obtém listener por ID
  EventListenerModel? getListenerById(String id);
}
