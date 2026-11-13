import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/servidor_emergencia_aviso_model.dart';
import 'package:data7_expedicao/domain/services/i_servidor_emergencia_service.dart';
import 'package:data7_expedicao/domain/services/i_socket_connection_port.dart';
import 'package:data7_expedicao/presentation/viewmodels/servidor_emergencia_viewmodel.dart';

void main() {
  late _FakeEmergenciaService service;
  late _FakeSocketPort socket;
  late ServidorEmergenciaViewModel viewModel;

  setUp(() {
    service = _FakeEmergenciaService();
    socket = _FakeSocketPort();
    viewModel = ServidorEmergenciaViewModel(service: service, socket: socket);
  });

  tearDown(() {
    viewModel.dispose();
    service.dispose();
  });

  group('ServidorEmergenciaViewModel', () {
    test('should start listener and expose aviso with prazo', () async {
      viewModel.initialize();
      expect(service.started, isTrue);

      service.add(
        const ServidorEmergenciaAvisoModel(
          nivel: 'desconectar',
          codigo: 'SERVIDOR_DESCONECTAR',
          mensagem: 'Sessao sera encerrada.',
          acao: 'desconectar',
          prazoMs: 8000,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.pendingAviso, isNotNull);
      expect(viewModel.pendingAviso!.detalhe, contains('8 segundos'));
    });

    test('should skip pending aviso when disconnect is immediate', () async {
      viewModel.initialize();
      service.add(
        const ServidorEmergenciaAvisoModel(
          nivel: 'desconectar',
          codigo: 'SERVIDOR_DESCONECTAR',
          mensagem: 'Corte imediato.',
          acao: 'desconectar',
          prazoMs: 0,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.pendingAviso, isNull);
    });

    test('should clear pending aviso after consume', () async {
      viewModel.initialize();
      service.add(
        const ServidorEmergenciaAvisoModel(
          nivel: 'aviso',
          codigo: 'SERVIDOR_AVISO',
          mensagem: 'Manutencao.',
          acao: 'nenhuma',
          prazoMs: 0,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.pendingAviso, isNotNull);

      viewModel.consumePendingAviso();
      expect(viewModel.pendingAviso, isNull);
    });
  });
}

class _FakeEmergenciaService implements IServidorEmergenciaService {
  final StreamController<ServidorEmergenciaAvisoModel> _avisos =
      StreamController<ServidorEmergenciaAvisoModel>.broadcast();
  bool started = false;
  ServidorEmergenciaAvisoModel? _last;

  void add(ServidorEmergenciaAvisoModel aviso) {
    _last = aviso;
    _avisos.add(aviso);
  }

  @override
  Stream<ServidorEmergenciaAvisoModel> get avisos => _avisos.stream;

  @override
  ServidorEmergenciaAvisoModel? get lastAviso => _last;

  @override
  void start() => started = true;

  @override
  void stop() => started = false;

  void dispose() {
    unawaited(_avisos.close());
  }
}

class _FakeSocketPort implements ISocketConnectionPort {
  @override
  bool get isTrafficPaused => false;

  @override
  bool get isSessionEndedByServer => false;

  @override
  void pauseForServerDisconnect() {}

  @override
  Future<void> reconnectAfterServerEnd() async {}

  @override
  String? get userId => null;

  @override
  SocketConnectionState get connectionState => SocketConnectionState.disconnected;

  @override
  bool get isConnected => false;

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
