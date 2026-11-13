import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/domain/models/servidor_emergencia_aviso_model.dart';
import 'package:data7_expedicao/domain/services/i_servidor_emergencia_service.dart';
import 'package:data7_expedicao/domain/services/i_socket_connection_port.dart';

class ServidorEmergenciaViewModel extends ChangeNotifier {
  final IServidorEmergenciaService _service;
  final ISocketConnectionPort _socket;

  StreamSubscription<ServidorEmergenciaAvisoModel>? _avisoSubscription;
  VoidCallback? _socketListener;
  ServidorEmergenciaAvisoModel? _pendingAviso;
  bool _initialized = false;

  ServidorEmergenciaViewModel({required IServidorEmergenciaService service, required ISocketConnectionPort socket})
    : _service = service,
      _socket = socket;

  ServidorEmergenciaAvisoModel? get lastAviso => _service.lastAviso ?? _pendingAviso;

  ServidorEmergenciaAvisoModel? get pendingAviso => _pendingAviso;

  bool get isSessionEndedByServer => _socket.isSessionEndedByServer;

  void initialize() {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _service.start();
    _avisoSubscription = _service.avisos.listen(_onAviso);
    _socketListener = notifyListeners;
    _socket.addListener(_socketListener!);
  }

  void consumePendingAviso() {
    _pendingAviso = null;
    notifyListeners();
  }

  Future<void> reconnectAfterServerEnd() {
    return _socket.reconnectAfterServerEnd();
  }

  void _onAviso(ServidorEmergenciaAvisoModel aviso) {
    final imediato = aviso.vaiDesconectar && aviso.prazoMs <= 0;
    if (imediato) {
      notifyListeners();
      return;
    }
    if (aviso.mensagem.trim().isEmpty && !aviso.vaiDesconectar) {
      return;
    }
    _pendingAviso = aviso;
    notifyListeners();
  }

  @override
  void dispose() {
    _avisoSubscription?.cancel();
    if (_socketListener != null) {
      _socket.removeListener(_socketListener!);
    }
    super.dispose();
  }
}
