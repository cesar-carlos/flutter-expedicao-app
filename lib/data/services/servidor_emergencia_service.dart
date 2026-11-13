import 'dart:async';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/servidor_emergencia_aviso_model.dart';
import 'package:data7_expedicao/domain/services/event_service.dart';
import 'package:data7_expedicao/domain/services/i_servidor_emergencia_service.dart';
import 'package:data7_expedicao/domain/services/i_socket_connection_port.dart';

class ServidorEmergenciaService implements IServidorEmergenciaService {
  final EventService _eventService;
  final ISocketConnectionPort _socket;
  final StreamController<ServidorEmergenciaAvisoModel> _avisos =
      StreamController<ServidorEmergenciaAvisoModel>.broadcast();

  ServidorEmergenciaAvisoModel? _lastAviso;
  bool _started = false;

  ServidorEmergenciaService({required EventService eventService, required ISocketConnectionPort socket})
    : _eventService = eventService,
      _socket = socket;

  @override
  Stream<ServidorEmergenciaAvisoModel> get avisos => _avisos.stream;

  @override
  ServidorEmergenciaAvisoModel? get lastAviso => _lastAviso;

  @override
  void start() {
    if (_started) {
      return;
    }
    _started = true;
    _eventService.subscribe(
      ServidorEmergenciaAvisoModel.channelName,
      EventListenerModel(
        id: ServidorEmergenciaAvisoModel.listenerId,
        event: Event.emergencia,
        allEvent: true,
        callback: _onEmergencia,
      ),
    );
  }

  @override
  void stop() {
    if (!_started) {
      return;
    }
    _started = false;
    _eventService.unsubscribe(ServidorEmergenciaAvisoModel.listenerId);
  }

  void _onEmergencia(BasicEventModel event) {
    final aviso = ServidorEmergenciaAvisoModel.fromPayload(event.data);
    if (aviso == null) {
      return;
    }

    _lastAviso = aviso;
    AppLogger.warning(
      'Aviso de emergencia codigo=${aviso.codigo} acao=${aviso.acao} prazoMs=${aviso.prazoMs}',
      tag: 'ServidorEmergenciaService',
    );

    if (aviso.vaiDesconectar) {
      _socket.pauseForServerDisconnect();
    }

    if (!_avisos.isClosed) {
      _avisos.add(aviso);
    }
  }

  void dispose() {
    stop();
    unawaited(_avisos.close());
  }
}
