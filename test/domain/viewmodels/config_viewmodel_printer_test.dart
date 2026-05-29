import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/infrastructure/services/printer_discovery_service.dart';
import '../../mocks/config_service_mock.dart';
import '../../mocks/fake_printer_preferences_repository.dart';

void main() {
  group('ConfigViewModel printers', () {
    late ConfigServiceMock configService;
    late FakePrinterPreferencesRepository printerPrefs;
    late ConfigViewModel viewModel;

    setUp(() async {
      configService = ConfigServiceMock();
      await configService.initialize();
      printerPrefs = FakePrinterPreferencesRepository();
      viewModel = ConfigViewModel(configService, printerPrefs, const PrinterDiscoveryService());
      await viewModel.loadConfig();
    });

    test('deve impedir cadastro duplicado por endpoint (ip:porta)', () async {
      await viewModel.addPrinter(name: 'IMP-1', ip: '192.168.0.10', port: 9100);
      await viewModel.addPrinter(name: 'IMP-2', ip: '192.168.0.10', port: 9100);

      expect(viewModel.printers.length, equals(1));
      expect(viewModel.errorMessage, contains('Ja existe uma impressora cadastrada'));
    });

    test('deve impedir atualizacao para endpoint ja cadastrado em outra impressora', () async {
      await viewModel.addPrinter(name: 'IMP-1', ip: '192.168.0.10', port: 9100);
      await viewModel.addPrinter(name: 'IMP-2', ip: '192.168.0.11', port: 9100);

      final secondPrinter = viewModel.printers.last;
      await viewModel.updatePrinter(secondPrinter.copyWith(ip: '192.168.0.10', port: 9100));

      expect(viewModel.printers.length, equals(2));
      expect(viewModel.errorMessage, contains('Ja existe outra impressora cadastrada'));
      expect(viewModel.printers.last.ip, equals('192.168.0.11'));
    });
  });
}
