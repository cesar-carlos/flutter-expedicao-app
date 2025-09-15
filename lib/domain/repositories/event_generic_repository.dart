import 'package:exp/domain/models/event_model/event_listener_model.dart';

/// Repositório genérico para eventos de qualquer modelo
abstract class EventGenericRepository<T> {
  /// Adiciona um listener de evento
  void addListener(EventListenerModel listener);

  /// Remove um listener específico
  void removeListener(String listenerId);

  /// Remove múltiplos listeners
  void removeListeners(List<String> listenerIds);

  /// Remove todos os listeners
  void removeAllListeners();

  /// Verifica se um listener existe
  bool hasListener(String listenerId);

  /// Obtém listener por ID
  EventListenerModel? getListenerById(String listenerId);

  /// Lista de todos os listeners registrados
  List<EventListenerModel> get listeners;

  /// Limpa todos os recursos
  void dispose();
}
