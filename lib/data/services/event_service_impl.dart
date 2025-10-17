import 'dart:convert';

import 'package:data7_expedicao/domain/services/event_service.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';

/// Implementação do serviço de eventos
///
/// Gerencia listeners de eventos e comunica com o SocketConfig para receber
/// eventos em tempo real do servidor.
class EventServiceImpl implements EventService {
  final Map<String, List<EventListenerModel>> _eventListeners = {};
  final Map<String, String> _listenerToEvent = {}; // listenerId -> eventName

  EventServiceImpl();

  @override
  void subscribe(String eventName, EventListenerModel listener) {
    // Remove listener existente se houver
    unsubscribe(listener.id);

    // Adiciona o listener
    _eventListeners.putIfAbsent(eventName, () => []).add(listener);
    _listenerToEvent[listener.id] = eventName;

    // Configura o listener no socket se for o primeiro para este evento
    if (_eventListeners[eventName]!.length == 1) {
      SocketConfig.instance.on(eventName, (data) => _handleEvent(eventName, data));
    }
  }

  @override
  void unsubscribe(String listenerId) {
    final eventName = _listenerToEvent.remove(listenerId);
    if (eventName != null) {
      _eventListeners[eventName]?.removeWhere((listener) => listener.id == listenerId);

      // Remove o listener do socket se não há mais listeners para este evento
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

  /// Manipula eventos recebidos do socket
  ///
  /// Converte os dados recebidos para BasicEventModel e executa os callbacks
  /// dos listeners registrados, respeitando as configurações de sessão.
  void _handleEvent(String eventName, dynamic data) {
    final listeners = _eventListeners[eventName];
    if (listeners == null || listeners.isEmpty) return;

    final basicEvent = _convertToBasicEvent(data, eventName);
    final currentSocketId = SocketConfig.instance.id;

    // Executa callbacks dos listeners
    for (final listener in listeners) {
      // Se não é para escutar todos os eventos e o evento veio da mesma sessão, pula
      if (!listener.allEvent && basicEvent.session == currentSocketId && basicEvent.session != null) {
        continue;
      }

      try {
        listener.callback(basicEvent);
      } catch (e) {
        // Erro ao executar callback do listener - continuar com outros listeners
      }
    }
  }

  /// Converte dados recebidos para BasicEventModel
  ///
  /// Suporta diferentes formatos de dados (String JSON, Map) e extrai
  /// automaticamente o tipo de evento baseado no nome do evento.
  BasicEventModel _convertToBasicEvent(dynamic data, String eventName) {
    try {
      Map<String, dynamic>? eventData;

      if (data is String) {
        eventData = jsonDecode(data);
      } else if (data is Map<String, dynamic>) {
        eventData = data;
      } else {
        // Dados não reconhecidos - criar evento vazio
        final eventType = _extractEventType(eventName);
        return BasicEventModel.empty(eventType: eventType);
      }

      if (eventData != null) {
        final eventType = _extractEventType(eventName);

        // Criar BasicEventModel com os dados corretos
        return BasicEventModel(
          session: eventData['Session'] ?? eventData['session'],
          data: eventData, // Passar os dados completos do evento
          timestamp: DateTime.now(),
          eventType: eventType,
        );
      } else {
        final eventType = _extractEventType(eventName);
        return BasicEventModel.empty(eventType: eventType);
      }
    } catch (e) {
      // Erro ao converter dados do evento - criar evento vazio
      final eventType = _extractEventType(eventName);
      return BasicEventModel.empty(eventType: eventType);
    }
  }

  /// Extrai o tipo de evento do nome do evento
  Event _extractEventType(String eventName) {
    if (eventName.contains('.insert.')) return Event.insert;
    if (eventName.contains('.update.')) return Event.update;
    if (eventName.contains('.delete.')) return Event.delete;
    return Event.insert; // Fallback
  }
}
