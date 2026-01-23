import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

/// Controller responsável por gerenciar preferências do scanner
///
/// Responsabilidades:
/// - Carregar preferências do scanner do ConfigViewModel
/// - Fornecer acesso às preferências (mode, action, extraKey)
/// - Validar configuração de broadcast
/// - Gerenciar valores padrão em caso de erro
class ScannerPreferencesController {
  final ConfigViewModel _configViewModel = locator<ConfigViewModel>();

  ScannerInputMode _scannerMode = ScannerInputMode.focus;
  String _broadcastAction = '';
  String _broadcastExtraKey = '';

  /// Modo de entrada do scanner (focus ou broadcast)
  ScannerInputMode get mode => _scannerMode;

  /// Action para broadcast listener
  String get broadcastAction => _broadcastAction;

  /// Extra key para broadcast listener
  String get broadcastExtraKey => _broadcastExtraKey;

  /// Verifica se o broadcast está configurado corretamente
  bool get isBroadcastConfigured =>
      _scannerMode == ScannerInputMode.broadcast &&
      _broadcastAction.isNotEmpty &&
      _broadcastExtraKey.isNotEmpty;

  /// Carrega as preferências do scanner do ConfigViewModel
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

  /// Recarrega as preferências do scanner
  void reloadPreferences() {
    loadPreferences();
  }
}
