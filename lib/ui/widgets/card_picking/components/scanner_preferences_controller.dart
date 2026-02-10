import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class ScannerPreferencesController {
  final ConfigViewModel _configViewModel = locator<ConfigViewModel>();

  ScannerInputMode _scannerMode = ScannerInputMode.focus;
  String _broadcastAction = '';
  String _broadcastExtraKey = '';

  ScannerInputMode get mode => _scannerMode;
  String get broadcastAction => _broadcastAction;
  String get broadcastExtraKey => _broadcastExtraKey;

  bool get isBroadcastConfigured =>
      _scannerMode == ScannerInputMode.broadcast && _broadcastAction.isNotEmpty && _broadcastExtraKey.isNotEmpty;

  Future<void> loadPreferences() async {
    try {
      _configViewModel.loadConfigSilent();
      final config = _configViewModel.currentConfig;
      _scannerMode = config.scannerInputMode;
      _broadcastAction = (config.broadcastAction ?? '').trim();
      _broadcastExtraKey = (config.broadcastExtraKey ?? '').trim();
      AppLogger.debug(
        'Scanner preferences loaded: mode=$_scannerMode action=$_broadcastAction extra=$_broadcastExtraKey',
        tag: 'ScannerPreferencesController',
      );
    } catch (e, stackTrace) {
      _scannerMode = ScannerInputMode.focus;
      _broadcastAction = '';
      _broadcastExtraKey = '';
      AppLogger.warning(
        'Failed to load scanner preferences, using defaults',
        tag: 'ScannerPreferencesController',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void reloadPreferences() {
    loadPreferences();
  }
}
