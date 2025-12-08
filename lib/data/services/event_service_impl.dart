import 'dart:convert';

import 'package:data7_expedicao/domain/services/event_service.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';

class EventServiceImpl implements EventService {
  final Map<String, List<EventListenerModel>> _eventListeners = {};
  final Map<String, String> _listenerToEvent = {};

  EventServiceImpl();

  @override
  void subscribe(String eventName, EventListenerModel listener) {
    unsubscribe(listener.id);

    _eventListeners.putIfAbsent(eventName, () => []).add(listener);
    _listenerToEvent[listener.id] = eventName;

    if (_eventListeners[eventName]!.length == 1) {
      SocketConfig.instance.on(eventName, (data) => _handleEvent(eventName, data));
    }
  }

  @override
  void unsubscribe(String listenerId) {
    final eventName = _listenerToEvent.remove(listenerId);
    if (eventName != null) {
      _eventListeners[eventName]?.removeWhere((listener) => listener.id == listenerId);

      if (_eventListeners[eventName]!.isEmpty) {
        SocketConfig.instance.off(eventName);
        _eventListeners.remove(eventName);
      }
    }
  }

  @override
  void unsubscribeAll(String eventName) {
    final listeners = _eventListeners.remove(eventName);
    if (listeners != null) {
      for (final listener in listeners) {
        _listenerToEvent.remove(listener.id);
      }
      SocketConfig.instance.off(eventName);
    }
  }

  @override
  void unsubscribeAllListeners() {
    for (final eventName in _eventListeners.keys) {
      SocketConfig.instance.off(eventName);
    }
    _eventListeners.clear();
    _listenerToEvent.clear();
  }

  @override
  bool isSubscribed(String listenerId) {
    return _listenerToEvent.containsKey(listenerId);
  }

  @override
  List<EventListenerModel> getListeners(String eventName) {
    return List.unmodifiable(_eventListeners[eventName] ?? []);
  }

  @override
  void dispose() {
    unsubscribeAllListeners();
  }

  void _handleEvent(String eventName, dynamic data) {
    final listeners = _eventListeners[eventName];
    if (listeners == null || listeners.isEmpty) return;

    final basicEvent = _convertToBasicEvent(data, eventName);
    final currentSocketId = SocketConfig.instance.id;

    for (final listener in listeners) {
      if (!listener.allEvent && basicEvent.session == currentSocketId && basicEvent.session != null) {
        continue;
      }

      try {
        listener.callback(basicEvent);
      } catch (e) {}
    }
  }

  BasicEventModel _convertToBasicEvent(dynamic data, String eventName) {
    try {
      Map<String, dynamic>? eventData;

      if (data is String) {
        eventData = jsonDecode(data);
      } else if (data is Map<String, dynamic>) {
        eventData = data;
      } else {
        final eventType = _extractEventType(eventName);
        return BasicEventModel.empty(eventType: eventType);
      }

      if (eventData != null) {
        final eventType = _extractEventType(eventName);

        return BasicEventModel(
          session: eventData['Session'] ?? eventData['session'],
          data: eventData,
          timestamp: DateTime.now(),
          eventType: eventType,
        );
      } else {
        final eventType = _extractEventType(eventName);
        return BasicEventModel.empty(eventType: eventType);
      }
    } catch (e) {
      final eventType = _extractEventType(eventName);
      return BasicEventModel.empty(eventType: eventType);
    }
  }

  Event _extractEventType(String eventName) {
    if (eventName.contains('.insert.')) return Event.insert;
    if (eventName.contains('.update.')) return Event.update;
    if (eventName.contains('.delete.')) return Event.delete;
    return Event.insert;
  }
}
