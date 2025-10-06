import 'package:exp/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:exp/data/repositories/event_repository/event_generic_repository_impl.dart';
import 'package:exp/domain/models/event_model/event_listener_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';

/// Implementação do repositório de eventos para carrinhos de separação de expedição
///
/// Esta implementação segue o padrão arquitetural do projeto:
/// - Interface no domínio (SeparateCartInternshipEventRepository)
/// - Implementação na camada de dados (SeparateCartInternshipEventRepositoryImpl)
/// - Delegação para implementação genérica (EventGenericRepositoryImpl)
class SeparateCartInternshipEventRepositoryImpl implements SeparateCartInternshipEventRepository {
  final EventGenericRepositoryImpl<ExpeditionCartRouteInternshipConsultationModel> _genericRepository;

  SeparateCartInternshipEventRepositoryImpl(
    EventGenericRepositoryImpl<ExpeditionCartRouteInternshipConsultationModel> genericRepository,
  ) : _genericRepository = genericRepository;

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
}
