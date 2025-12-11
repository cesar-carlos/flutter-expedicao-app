import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';

enum Event { insert, update, delete }

typedef EventCallback = void Function(BasicEventModel event);

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

  EventListenerModel copyWith({String? id, Event? event, EventCallback? callback, bool? allEvent}) {
    return EventListenerModel(
      id: id ?? this.id,
      event: event ?? this.event,
      callback: callback ?? this.callback,
      allEvent: allEvent ?? this.allEvent,
    );
  }

  bool listensTo(Event eventType) {
    return event == eventType || allEvent;
  }

  @override
  String toString() {
    return 'EventListenerModel(id: $id, event: $event, allEvent: $allEvent)';
  }
}
