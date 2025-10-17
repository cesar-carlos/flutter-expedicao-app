import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';

/// Serviço genérico para gerenciamento de eventos
abstract class EventService {
  /// Inscreve um listener para um evento específico
  void subscribe(String eventName, EventListenerModel listener);

  /// Remove um listener específico
  void unsubscribe(String listenerId);

  /// Remove todos os listeners de um evento
  void unsubscribeAll(String eventName);

  /// Remove todos os listeners
  void unsubscribeAllListeners();

  /// Verifica se um listener está inscrito
  bool isSubscribed(String listenerId);

  /// Obtém todos os listeners de um evento
  List<EventListenerModel> getListeners(String eventName);

  /// Limpa todos os recursos
  void dispose();
}
