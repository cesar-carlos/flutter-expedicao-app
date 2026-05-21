import 'dart:async';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/core/services/scanner_mode_coordinator.dart';

class ScannerPreferencesController {
  final ConfigViewModel _configViewModel;

  ScannerInputMode _scannerMode = ScannerInputMode.focus;
  String _broadcastAction = '';
  String _broadcastExtraKey = '';

  ScannerInputMode get mode => _scannerMode;
  String get broadcastAction => _broadcastAction;
  String get broadcastExtraKey => _broadcastExtraKey;
  ScannerModePreferences get modePreferences =>
      ScannerModePreferences(mode: _scannerMode, action: _broadcastAction, extraKey: _broadcastExtraKey);

  bool get isBroadcastConfigured =>
      _scannerMode == ScannerInputMode.broadcast && _broadcastAction.isNotEmpty && _broadcastExtraKey.isNotEmpty;

  ScannerPreferencesController({ConfigViewModel? configViewModel})
    : _configViewModel = configViewModel ?? locator<ConfigViewModel>();

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

  Future<ScannerModePreferences> loadModePreferences() async {
    await loadPreferences();
    return modePreferences;
  }

  /// Bug latente anterior: `loadPreferences()` retorna Future
  /// (porque e `async`) mas era descartado sem catch — se o load
  /// silenciosamente falhasse, a operacao de reload nao logava
  /// nada (apesar do `loadPreferences` ja ter try/catch interno
  /// que loga via AppLogger.warning, qualquer exception nao-tratada
  /// no proprio loadPreferences viraria "Unhandled Future error").
  /// Agora `unawaited` + catchError defensivo pelos lints.
  void reloadPreferences() {
    unawaited(
      loadPreferences().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao recarregar preferencias do scanner',
          tag: 'ScannerPreferencesController',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }
}
