import 'package:exp/domain/models/event_model/basic_event_model.dart';

/// Tipos de eventos disponíveis
enum Event { insert, update, delete }

/// Callback para eventos de repositório
typedef EventCallback = void Function(BasicEventModel event);

/// Modelo para listener de eventos de repositório
class EventListenerModel {
  final String id;
  final Event event;
  final EventCallback callback;
  final bool allEvent;

  const EventListenerModel({required this.id, required this.event, required this.callback, this.allEvent = false});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventListenerModel && other.id == id && other.event == event;
  }

  @override
  int get hashCode => id.hashCode ^ event.hashCode;

  @override
  String toString() {
    return 'RepositoryEventListenerModel(id: $id, event: $event, allEvent: $allEvent)';
  }
}
