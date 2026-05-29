import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/l10n/app_localizations.dart';
import 'package:data7_expedicao/ui/widgets/config/scanner_config_form.dart';

void main() {
  testWidgets('mostra aviso quando broadcast usa action e extraKey padrao', (tester) async {
    await tester.pumpWidget(
      _buildForm(
        const ApiConfig(
          apiUrl: 'localhost',
          apiPort: 3001,
          scannerInputMode: ScannerInputMode.broadcast,
          broadcastAction: 'com.scanner.BARCODE',
          broadcastExtraKey: 'data',
        ),
      ),
    );

    expect(find.textContaining('A action e a chave'), findsOneWidget);
  });
}

Widget _buildForm(ApiConfig config) {
  return MaterialApp(
    locale: const Locale('pt', 'BR'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ChangeNotifierProvider<ConfigViewModel>.value(
      value: _FakeConfigViewModel(config),
      child: const Scaffold(body: ScannerConfigForm()),
    ),
  );
}

class _FakeConfigViewModel extends ChangeNotifier implements ConfigViewModel {
  _FakeConfigViewModel(this._config);

  final ApiConfig _config;

  @override
  ApiConfig get currentConfig => _config;

  @override
  ScannerInputMode get scannerInputMode => _config.scannerInputMode;

  @override
  String get broadcastAction => _config.broadcastAction ?? '';

  @override
  String get broadcastExtraKey => _config.broadcastExtraKey ?? '';

  @override
  bool get isSaving => false;

  @override
  String get errorMessage => '';

  @override
  void loadConfigSilent() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
