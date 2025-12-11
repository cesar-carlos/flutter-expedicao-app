import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';

abstract class EventService {
  void subscribe(String eventName, EventListenerModel listener);

  void unsubscribe(String listenerId);

  void unsubscribeAll(String eventName);

  void unsubscribeAllListeners();

  bool isSubscribed(String listenerId);

  List<EventListenerModel> getListeners(String eventName);

  void dispose();
}
