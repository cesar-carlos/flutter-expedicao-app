import 'package:exp/domain/repositories/event_generic_repository.dart';
import 'package:exp/data/repositories/event_repository/event_generic_repository_impl.dart';
import 'package:exp/domain/models/event_model/event_listener_model.dart';
import 'package:exp/domain/models/separate_model.dart';

/// Implementação do repositório de eventos para separação de expedição
class SeparateEventRepositoryImpl implements EventGenericRepository<SeparateModel> {
  final EventGenericRepositoryImpl<SeparateModel> _genericRepository;

  SeparateEventRepositoryImpl(EventGenericRepositoryImpl<SeparateModel> genericRepository)
    : _genericRepository = genericRepository;

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
