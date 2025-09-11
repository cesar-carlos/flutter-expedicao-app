import 'package:exp/domain/models/basic_event_model.dart';

/// Tipos de eventos disponíveis
enum RepositoryEvent { insert, update, delete }

/// Callback para eventos de repositório
typedef EventCallback = void Function(BasicEventModel event);

/// Modelo para listener de eventos de repositório
class RepositoryEventListenerModel {
  final String id;
  final RepositoryEvent event;
  final EventCallback callback;
  final bool allEvent;

  const RepositoryEventListenerModel({
    required this.id,
    required this.event,
    required this.callback,
    this.allEvent = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepositoryEventListenerModel &&
        other.id == id &&
        other.event == event;
  }

  @override
  int get hashCode => id.hashCode ^ event.hashCode;

  @override
  String toString() {
    return 'RepositoryEventListenerModel(id: $id, event: $event, allEvent: $allEvent)';
  }
}
