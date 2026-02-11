import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/utils/i_logger.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/di/locator.dart';
import '../../mocks/config_service_mock.dart';
import '../../mocks/fake_printer_preferences_repository.dart';

void main() {
  group('ConfigViewModel.testConnection', () {
    late ConfigServiceMock configService;
    late FakePrinterPreferencesRepository printerPrefs;
    late ConfigViewModel viewModel;

    setUp(() async {
      if (!locator.isRegistered<ILogger>()) {
        locator.registerSingleton<ILogger>(_SilentLogger());
      }

      configService = ConfigServiceMock();
      await configService.initialize();
      printerPrefs = FakePrinterPreferencesRepository();
      viewModel = ConfigViewModel(configService, printerPrefs);
    });

    test('deve aceitar handshake em portugues', () async {
      final server = await _startServer((request) async {
        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'message': 'Expedição API'}));
        await request.response.close();
      });
      addTearDown(server.close);

      final result = await _runConnectionTest(viewModel, server.port);

      expect(result, isTrue);
      expect(viewModel.errorMessage, isEmpty);
    });

    test('deve aceitar handshake em ingles', () async {
      final server = await _startServer((request) async {
        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'message': 'Expedition API'}));
        await request.response.close();
      });
      addTearDown(server.close);

      final result = await _runConnectionTest(viewModel, server.port);

      expect(result, isTrue);
      expect(viewModel.errorMessage, isEmpty);
    });

    test('deve rejeitar payload invalido', () async {
      final server = await _startServer((request) async {
        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'message': 'Servidor online'}));
        await request.response.close();
      });
      addTearDown(server.close);

      final result = await _runConnectionTest(viewModel, server.port);

      expect(result, isFalse);
      expect(viewModel.errorMessage, equals('Resposta inválida do servidor'));
    });

    test('deve aceitar handshake textual com frase maior', () async {
      final server = await _startServer((request) async {
        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType.text;
        request.response.write('Bem-vindo à Expedição API');
        await request.response.close();
      });
      addTearDown(server.close);

      final result = await _runConnectionTest(viewModel, server.port);

      expect(result, isTrue);
      expect(viewModel.errorMessage, isEmpty);
    });
  });
}

class _SilentLogger implements ILogger {
  @override
  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void info(String message, {String? tag}) {}

  @override
  void severe(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {}
}

Future<HttpServer> _startServer(
  Future<void> Function(HttpRequest request) handler,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

  server.listen((request) async {
    await handler(request);
  });

  return server;
}

Future<bool> _runConnectionTest(ConfigViewModel viewModel, int port) {
  return viewModel.testConnection(
    apiUrl: InternetAddress.loopbackIPv4.address,
    apiPort: '$port',
    useHttps: false,
  );
}
