import 'package:data7_expedicao/domain/repositories/event_generic_repository.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/services/event_service.dart';

class EventGenericRepositoryImpl<T> implements EventGenericRepository<T> {
  final EventService _eventService;
  final String _eventPrefix;
  final List<EventListenerModel> _listeners = [];

  EventGenericRepositoryImpl(this._eventService, this._eventPrefix);

  @override
  void addListener(EventListenerModel listener) {
    removeListener(listener.id);

    _listeners.add(listener);
    final eventName = '$_eventPrefix.${listener.event.name}.listen';
    _eventService.subscribe(eventName, listener);
  }

  @override
  void removeListener(String listenerId) {
    _listeners.removeWhere((listener) => listener.id == listenerId);
    _eventService.unsubscribe(listenerId);
  }

  @override
  void removeListeners(List<String> listenerIds) {
    for (final listenerId in listenerIds) {
      removeListener(listenerId);
    }
  }

  @override
  void removeAllListeners() {
    // Bug HH: copia a lista antes de iterar — `unsubscribe` pode disparar
    // callbacks que mexem em `_listeners`, causando ConcurrentModificationError.
    final snapshot = List<EventListenerModel>.from(_listeners);
    _listeners.clear();
    for (final listener in snapshot) {
      _eventService.unsubscribe(listener.id);
    }
  }

  @override
  bool hasListener(String listenerId) {
    return _listeners.any((listener) => listener.id == listenerId);
  }

  @override
  EventListenerModel? getListenerById(String listenerId) {
    try {
      return _listeners.firstWhere((listener) => listener.id == listenerId);
    } catch (e) {
      return null;
    }
  }

  @override
  List<EventListenerModel> get listeners => List.unmodifiable(_listeners);

  @override
  void dispose() {
    removeAllListeners();
  }
}
