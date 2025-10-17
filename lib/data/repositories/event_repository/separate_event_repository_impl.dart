import 'package:data7_expedicao/domain/repositories/separate_event_repository.dart';
import 'package:data7_expedicao/data/repositories/event_repository/event_generic_repository_impl.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/services/event_service.dart';

/// Implementação do repositório de eventos para separação de expedição
///
/// Esta implementação segue o padrão arquitetural do projeto:
/// - Interface no domínio (SeparateEventRepository)
/// - Implementação na camada de dados (SeparateEventRepositoryImpl)
/// - Delegação para implementação genérica (EventGenericRepositoryImpl)
class SeparateEventRepositoryImpl implements SeparateEventRepository {
  // Constantes de eventos customizados
  static const String _consultationEventName = 'separar.consulta.listen';
  static const String _updateListEventName = 'separar.update.listen';

  final EventGenericRepositoryImpl<SeparateConsultationModel> _genericRepository;
  final EventService _eventService;

  SeparateEventRepositoryImpl(
    EventGenericRepositoryImpl<SeparateConsultationModel> genericRepository,
    EventService eventService,
  ) : _genericRepository = genericRepository,
      _eventService = eventService;

  // === Delegação para repositório genérico ===

  @override
  void addListener(EventListenerModel listener) => _genericRepository.addListener(listener);

  @override
  void removeListener(String listenerId) => _genericRepository.removeListener(listenerId);

  @override
  void removeListeners(List<String> listenerIds) => _genericRepository.removeListeners(listenerIds);

  @override
  void removeAllListeners() => _genericRepository.removeAllListeners();

  @override
  bool hasListener(String listenerId) => _genericRepository.hasListener(listenerId);

  @override
  EventListenerModel? getListenerById(String listenerId) => _genericRepository.getListenerById(listenerId);

  @override
  List<EventListenerModel> get listeners => _genericRepository.listeners;

  @override
  void dispose() => _genericRepository.dispose();

  // === Listeners customizados para eventos de lista ===

  @override
  void addConsultationListener(EventListenerModel listener) {
    _eventService.subscribe(_consultationEventName, listener);
  }

  @override
  void removeConsultationListener(String listenerId) {
    _eventService.unsubscribe(listenerId);
  }

  @override
  void addUpdateListener(EventListenerModel listener) {
    _eventService.subscribe(_updateListEventName, listener);
  }

  @override
  void removeUpdateListener(String listenerId) {
    _eventService.unsubscribe(listenerId);
  }
}
