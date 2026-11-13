import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/data/services/servidor_emergencia_service.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/servidor_emergencia_aviso_model.dart';
import 'package:data7_expedicao/domain/services/event_service.dart';
import 'package:data7_expedicao/domain/services/i_socket_connection_port.dart';

void main() {
  late _FakeEventService events;
  late _FakeSocketPort socket;
  late ServidorEmergenciaService service;

  setUp(() {
    events = _FakeEventService();
    socket = _FakeSocketPort();
    service = ServidorEmergenciaService(eventService: events, socket: socket);
  });

  tearDown(() {
    service.dispose();
  });

  group('ServidorEmergenciaService', () {
    test('should subscribe with allEvent true on the literal channel', () {
      service.start();

      expect(events.subscribedName, ServidorEmergenciaAvisoModel.channelName);
      expect(events.listener?.allEvent, isTrue);
      expect(events.listener?.event, Event.emergencia);
      expect(events.listener?.id, ServidorEmergenciaAvisoModel.listenerId);
    });

    test('should pause socket traffic when Acao is desconectar', () async {
      final received = <ServidorEmergenciaAvisoModel>[];
      final sub = service.avisos.listen(received.add);
      service.start();

      events.emit({
        'Data': [
          {
            'Nivel': 'desconectar',
            'Codigo': 'SERVIDOR_DESCONECTAR',
            'Mensagem': 'Sessao encerrada pelo operador.',
            'Acao': 'desconectar',
            'PrazoMs': 5000,
          },
        ],
      });

      await Future<void>.delayed(Duration.zero);

      expect(socket.paused, isTrue);
      expect(received, hasLength(1));
      expect(received.single.vaiDesconectar, isTrue);
      expect(service.lastAviso?.codigo, 'SERVIDOR_DESCONECTAR');
      await sub.cancel();
    });

    test('should not pause traffic for Acao nenhuma', () async {
      service.start();

      events.emit({
        'Data': [
          {'Nivel': 'aviso', 'Mensagem': 'Manutencao em 10 minutos.', 'Acao': 'nenhuma', 'PrazoMs': 0},
        ],
      });

      await Future<void>.delayed(Duration.zero);

      expect(socket.paused, isFalse);
      expect(service.lastAviso?.vaiDesconectar, isFalse);
    });
  });
}

class _FakeEventService implements EventService {
  EventListenerModel? listener;
  String? subscribedName;

  void emit(Map<String, dynamic> payload) {
    listener?.callback(
      BasicEventModel(session: null, data: payload, timestamp: DateTime.now(), eventType: Event.emergencia),
    );
  }

  @override
  void subscribe(String eventName, EventListenerModel listener) {
    subscribedName = eventName;
    this.listener = listener;
  }

  @override
  void unsubscribe(String listenerId) {
    if (listener?.id == listenerId) {
      listener = null;
      subscribedName = null;
    }
  }

  @override
  void unsubscribeAll(String eventName) {}

  @override
  void unsubscribeAllListeners() {}

  @override
  bool isSubscribed(String listenerId) => listener?.id == listenerId;

  @override
  List<EventListenerModel> getListeners(String eventName) {
    final current = listener;
    return current == null ? const <EventListenerModel>[] : <EventListenerModel>[current];
  }

  @override
  void dispose() {}
}

class _FakeSocketPort implements ISocketConnectionPort {
  bool paused = false;
  bool ended = false;

  @override
  bool get isTrafficPaused => paused;

  @override
  bool get isSessionEndedByServer => ended;

  @override
  void pauseForServerDisconnect() {
    paused = true;
  }

  @override
  Future<void> reconnectAfterServerEnd() async {
    paused = false;
    ended = false;
  }

  @override
  String? get userId => null;

  @override
  SocketConnectionState get connectionState => SocketConnectionState.connected;

  @override
  bool get isConnected => true;

  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  Future<void> reconnect() async {}

  @override
  Stream<dynamic> on(String eventName) => const Stream.empty();

  @override
  void off(String eventName) {}

  @override
  void emit(String eventName, dynamic data) {}

  @override
  void addListener(void Function() listener) {}

  @override
  void removeListener(void Function() listener) {}
}
