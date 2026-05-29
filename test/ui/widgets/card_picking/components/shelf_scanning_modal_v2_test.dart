import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/barcode_broadcast_service.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/l10n/app_localizations.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/shelf_scanning_modal_v2.dart';

void main() {
  late _FakeCardPickingViewModel viewModel;
  late _FakeBroadcastService broadcastService;
  late _FakeAudioService audioService;

  setUp(() {
    viewModel = _FakeCardPickingViewModel();
    broadcastService = _FakeBroadcastService();
    audioService = _FakeAudioService();
  });

  tearDown(() async {
    await broadcastService.dispose();
    await locator.popScope();
  });

  testWidgets('preserva hifen no scan por foco', (tester) async {
    _setupLocator(
      config: const ApiConfig(apiUrl: 'localhost', apiPort: 3001, scannerInputMode: ScannerInputMode.focus),
      broadcastService: broadcastService,
      audioService: audioService,
    );

    await _pumpDialog(tester, viewModel);

    await tester.enterText(find.byType(TextField), '01-A-2');
    await tester.pump(const Duration(milliseconds: 500));

    expect(viewModel.lastScannedAddress, equals('01-A-2'));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('preserva hifen no scan por broadcast', (tester) async {
    _setupLocator(
      config: const ApiConfig(
        apiUrl: 'localhost',
        apiPort: 3001,
        scannerInputMode: ScannerInputMode.broadcast,
        broadcastAction: 'com.scanner.BARCODE',
        broadcastExtraKey: 'data',
      ),
      broadcastService: broadcastService,
      audioService: audioService,
    );

    await _pumpDialog(tester, viewModel);
    await tester.pump(const Duration(milliseconds: 300));

    broadcastService.emit('01-A-2\n');
    await tester.pump(const Duration(milliseconds: 500));

    expect(viewModel.lastScannedAddress, equals('01-A-2'));
    await tester.pump(const Duration(seconds: 1));
  });
}

void _setupLocator({
  required ApiConfig config,
  required _FakeBroadcastService broadcastService,
  required AudioService audioService,
}) {
  locator.pushNewScope(
    init: (GetIt scope) {
      scope.registerSingleton<ShelfScanningService>(ShelfScanningService());
      scope.registerSingleton<AudioService>(audioService);
      scope.registerSingleton<BarcodeBroadcastService>(broadcastService);
      scope.registerSingleton<ConfigViewModel>(_FakeConfigViewModel(config));
    },
  );
}

Future<void> _pumpDialog(WidgetTester tester, CardPickingViewModel viewModel) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: ElevatedButton(
              onPressed: () {
                unawaited(
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => ShelfScanningModalV2(
                      expectedAddress: '01-A-2',
                      expectedAddressDescription: 'Prateleira 01-A-2',
                      viewModel: viewModel,
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

class _FakeCardPickingViewModel extends Fake implements CardPickingViewModel {
  @override
  String? lastScannedAddress;

  @override
  void updateScannedAddress(String address) {
    lastScannedAddress = address;
  }
}

class _FakeAudioService extends Fake implements AudioService {
  @override
  Future<void> playShelfScanSuccess() async {}

  @override
  Future<void> playError() async {}
}

class _FakeConfigViewModel extends Fake implements ConfigViewModel {
  _FakeConfigViewModel(this._config);

  final ApiConfig _config;

  @override
  ApiConfig get currentConfig => _config;

  @override
  void loadConfigSilent() {}
}

class _FakeBroadcastService implements BarcodeBroadcastService {
  final StreamController<String> _controller = StreamController<String>.broadcast();

  @override
  Stream<String> listen({required String action, required String extraKey}) {
    return _controller.stream;
  }

  void emit(String code) {
    _controller.add(code);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
