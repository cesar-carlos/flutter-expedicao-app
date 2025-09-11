import 'dart:convert';

import 'package:exp/domain/repositories/event_contract.dart';
import 'package:exp/domain/models/repository_event_listener_model.dart';
import 'package:exp/domain/models/basic_event_model.dart';
import 'package:exp/core/network/socket_config.dart';

/// Implementação do repositório de eventos para separação de expedição
class SeparateEventRepository implements EventContract {
  static SeparateEventRepository? _instance;
  final List<RepositoryEventListenerModel> _listeners = [];

  SeparateEventRepository._() {
    _setupEventListeners();
  }

  /// Singleton instance
  static SeparateEventRepository get instance {
    _instance ??= SeparateEventRepository._();
    return _instance!;
  }

  @override
  List<RepositoryEventListenerModel> get listeners =>
      List.unmodifiable(_listeners);

  @override
  void addListener(RepositoryEventListenerModel listener) {
    // Remove listener existente com mesmo ID se houver
    removeListenerById(listener.id);
    _listeners.add(listener);
  }

  @override
  void removeListener(RepositoryEventListenerModel listener) {
    _listeners.removeWhere((element) => element.id == listener.id);
  }

  @override
  void removeListeners(List<RepositoryEventListenerModel> listeners) {
    for (final listener in listeners) {
      removeListener(listener);
    }
  }

  @override
  void removeListenerById(String id) {
    _listeners.removeWhere((element) => element.id == id);
  }

  @override
  void removeAllListeners() {
    _listeners.clear();
  }

  @override
  bool hasListener(String id) {
    return _listeners.any((listener) => listener.id == id);
  }

  @override
  RepositoryEventListenerModel? getListenerById(String id) {
    try {
      return _listeners.firstWhere((listener) => listener.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Configura os listeners de eventos do socket
  void _setupEventListeners() {
    _onInsert();
    _onUpdate();
    _onDelete();
  }

  /// Configura listener para eventos de inserção
  void _onInsert() {
    const event = 'separar.insert.listen';
    SocketConfig.instance.on(event, (data) {
      _handleEvent(RepositoryEvent.insert, data);
    });
  }

  /// Configura listener para eventos de atualização
  void _onUpdate() {
    const event = 'separar.update.listen';
    SocketConfig.instance.on(event, (data) {
      _handleEvent(RepositoryEvent.update, data);
    });
  }

  /// Configura listener para eventos de exclusão
  void _onDelete() {
    const event = 'separar.delete.listen';
    SocketConfig.instance.on(event, (data) {
      _handleEvent(RepositoryEvent.delete, data);
    });
  }

  /// Manipula eventos recebidos do socket
  void _handleEvent(RepositoryEvent eventType, dynamic data) {
    final basicEvent = _convertToBasicEvent(data);
    final currentSocketId = SocketConfig.instance.id;

    // Filtra listeners por tipo de evento
    final matchingListeners = _listeners
        .where((listener) => listener.event == eventType)
        .toList();

    // Executa callbacks dos listeners
    for (final listener in matchingListeners) {
      // Se não é para escutar todos os eventos e o evento veio da mesma sessão, pula
      if (!listener.allEvent &&
          basicEvent.session == currentSocketId &&
          basicEvent.session != null) {
        continue;
      }

      try {
        listener.callback(basicEvent);
      } catch (e) {
        print('Erro ao executar callback do listener ${listener.id}: $e');
      }
    }
  }

  /// Converte dados recebidos para BasicEventModel
  BasicEventModel _convertToBasicEvent(dynamic data) {
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        return BasicEventModel.fromJson(decoded);
      } else if (data is Map<String, dynamic>) {
        return BasicEventModel.fromJson(data);
      } else {
        return BasicEventModel.empty();
      }
    } catch (e) {
      print('Erro ao converter dados do evento: $e');
      return BasicEventModel.empty();
    }
  }

  /// Limpa todos os recursos
  void dispose() {
    removeAllListeners();

    // Remove listeners do socket
    const events = [
      'separar.insert.listen',
      'separar.update.listen',
      'separar.delete.listen',
    ];

    for (final event in events) {
      try {
        SocketConfig.instance.off(event);
      } catch (e) {
        print('Erro ao remover listener do socket $event: $e');
      }
    }

    _instance = null;
  }
}
