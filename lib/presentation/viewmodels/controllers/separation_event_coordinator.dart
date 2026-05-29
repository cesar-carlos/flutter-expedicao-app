import 'dart:developer' as developer;

import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_event_repository.dart';

/// Controller responsável por orquestrar a escuta de eventos remotos da
/// lista de separações.
///
/// Extraído de [SeparationViewModel] para isolar:
/// - Registro/desregistro dos listeners (insert/update/delete,
///   consultation e update_list) com seus IDs e flags
/// - Parsing dos payloads (incluindo o formato `Mutation` em lote)
///
/// O merge da lista, a ordenação e o `notifyListeners` permanecem no
/// ViewModel (dono da lista). O coordinator apenas dispara callbacks:
/// - [onSeparationEvent]: para cada mutação CRUD parseada
/// - [onListResyncRequested]: quando um evento de lista pede resync
class SeparationEventCoordinator {
  static const String _insertListenerId = 'separation_viewmodel_insert';
  static const String _updateListenerId = 'separation_viewmodel_update';
  static const String _deleteListenerId = 'separation_viewmodel_delete';
  static const String _consultationListenerId = 'separation_viewmodel_consultation';
  static const String _updateListListenerId = 'separation_viewmodel_update_list';

  final SeparateEventRepository _eventRepository;
  final bool Function() _isDisposed;
  final void Function(Event eventType, SeparateConsultationModel data) _onSeparationEvent;
  final void Function() _onListResyncRequested;

  bool _eventListenersRegistered = false;
  bool _consultationListenerRegistered = false;
  bool _updateListListenerRegistered = false;

  SeparationEventCoordinator({
    required SeparateEventRepository eventRepository,
    required bool Function() isDisposed,
    required void Function(Event eventType, SeparateConsultationModel data) onSeparationEvent,
    required void Function() onListResyncRequested,
  }) : _eventRepository = eventRepository,
       _isDisposed = isDisposed,
       _onSeparationEvent = onSeparationEvent,
       _onListResyncRequested = onListResyncRequested;

  void start() {
    if (_isDisposed()) return;
    _registerEventListener();
    _registerConsultationEventListener();
    _registerUpdateListEventListener();
  }

  void stop() {
    if (_isDisposed()) return;
    _unregisterEventListener();
    _unregisterConsultationEventListener();
    _unregisterUpdateListEventListener();
  }

  void _registerEventListener() {
    if (_isDisposed() || _eventListenersRegistered) return;

    try {
      // allEvent: true — [EventServiceImpl] ignora eventos com Session == socket atual
      // quando allEvent é false (evitar eco em outros fluxos). Na listagem, isso impedia
      // de ver a própria separação criada neste app até dar refresh.
      _eventRepository.addListener(
        EventListenerModel(id: _insertListenerId, event: Event.insert, callback: _onRawSeparationEvent, allEvent: true),
      );

      _eventRepository.addListener(
        EventListenerModel(id: _updateListenerId, event: Event.update, callback: _onRawSeparationEvent, allEvent: true),
      );

      _eventRepository.addListener(
        EventListenerModel(id: _deleteListenerId, event: Event.delete, callback: _onRawSeparationEvent, allEvent: true),
      );

      _eventListenersRegistered = true;
    } catch (e, s) {
      developer.log('Erro ao registrar evento de separação', error: e, stackTrace: s);
    }
  }

  void _registerConsultationEventListener() {
    if (_isDisposed() || _consultationListenerRegistered) return;

    try {
      _eventRepository.addConsultationListener(
        EventListenerModel(
          id: _consultationListenerId,
          event: Event.insert,
          callback: _onRawListEvent,
          allEvent: true,
        ),
      );
      _consultationListenerRegistered = true;
    } catch (e, s) {
      developer.log('Erro ao registrar evento de consulta de separação', error: e, stackTrace: s);
    }
  }

  void _registerUpdateListEventListener() {
    if (_isDisposed() || _updateListListenerRegistered) return;

    try {
      _eventRepository.addUpdateListener(
        EventListenerModel(
          id: _updateListListenerId,
          event: Event.update,
          callback: _onRawListEvent,
          allEvent: true,
        ),
      );
      _updateListListenerRegistered = true;
    } catch (e, s) {
      developer.log('Erro ao registrar evento de atualização de lista', error: e, stackTrace: s);
    }
  }

  void _unregisterEventListener() {
    if (!_eventListenersRegistered) return;

    try {
      _eventRepository.removeListeners([_insertListenerId, _updateListenerId, _deleteListenerId]);
      _eventListenersRegistered = false;
    } catch (e, s) {
      developer.log('Erro ao desregistrar evento de separação', error: e, stackTrace: s);
    }
  }

  void _unregisterConsultationEventListener() {
    if (!_consultationListenerRegistered) return;

    try {
      _eventRepository.removeConsultationListener(_consultationListenerId);
      _consultationListenerRegistered = false;
    } catch (e, s) {
      developer.log('Erro ao desregistrar evento de consulta de separação', error: e, stackTrace: s);
    }
  }

  void _unregisterUpdateListEventListener() {
    if (!_updateListListenerRegistered) return;

    try {
      _eventRepository.removeUpdateListener(_updateListListenerId);
      _updateListListenerRegistered = false;
    } catch (e, s) {
      developer.log('Erro ao desregistrar evento de atualização de lista', error: e, stackTrace: s);
    }
  }

  void _onRawSeparationEvent(BasicEventModel event) {
    if (_isDisposed()) return;

    try {
      _processEventData(event);
    } catch (e, s) {
      developer.log('Erro ao processar evento de separação', error: e, stackTrace: s);
    }
  }

  void _processEventData(BasicEventModel event) {
    if (event.data == null) return;

    try {
      if (event.data is Map<String, dynamic>) {
        final dataMap = event.data as Map<String, dynamic>;

        if (dataMap.containsKey('Mutation') && dataMap['Mutation'] is List) {
          final mutations = dataMap['Mutation'] as List;

          for (final mutation in mutations) {
            if (mutation is Map<String, dynamic>) {
              final separationData = SeparateConsultationModel.fromJson(mutation);
              _onSeparationEvent(event.eventType, separationData);
            }
          }
        } else {
          final separationData = SeparateConsultationModel.fromJson(dataMap);
          _onSeparationEvent(event.eventType, separationData);
        }
      }
    } catch (e, s) {
      developer.log('Erro ao processar evento de separação', error: e, stackTrace: s);
    }
  }

  void _onRawListEvent(BasicEventModel event) {
    if (_isDisposed() || event.data == null) return;

    try {
      _processListEventData(event);
    } catch (e, s) {
      developer.log('Erro ao processar evento de atualização de lista', error: e, stackTrace: s);
    }
  }

  void _processListEventData(BasicEventModel event) {
    final dataMap = event.data as Map<String, dynamic>;

    if (!dataMap.containsKey('Data') || dataMap['Data'] is! List) return;

    _onListResyncRequested();
  }
}
