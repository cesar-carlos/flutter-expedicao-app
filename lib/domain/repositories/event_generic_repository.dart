import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';

abstract class EventGenericRepository<T> {
  void addListener(EventListenerModel listener);
  void removeListener(String listenerId);
  void removeListeners(List<String> listenerIds);
  void removeAllListeners();
  bool hasListener(String listenerId);
  EventListenerModel? getListenerById(String listenerId);
  List<EventListenerModel> get listeners;
  void dispose();
}
