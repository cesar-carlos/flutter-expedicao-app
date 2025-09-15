import 'package:exp/domain/repositories/generic_event_repository.dart';
import 'package:exp/domain/models/event_model/event_listener_model.dart';
import 'package:exp/domain/services/event_service.dart';

/// Implementação genérica do repositório de eventos
class GenericEventRepositoryImpl<T> implements GenericEventRepository<T> {
  final EventService _eventService;
  final String _eventPrefix; // ex: 'separar', 'expedition', etc.
  final List<EventListenerModel> _listeners = [];

  GenericEventRepositoryImpl(this._eventService, this._eventPrefix);

  @override
  void addListener(EventListenerModel listener) {
    // Remove listener existente com mesmo ID se houver
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
    for (final listener in _listeners) {
      _eventService.unsubscribe(listener.id);
    }
    _listeners.clear();
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
