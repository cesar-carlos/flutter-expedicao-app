import 'dart:async';

import 'package:data7_expedicao/core/services/barcode_broadcast_service.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';

/// Snapshot imutável das preferências de scanner.
/// Geralmente vem do `ConfigViewModel.currentConfig`.
class ScannerModePreferences {
  final ScannerInputMode mode;
  final String action;
  final String extraKey;

  const ScannerModePreferences({
    required this.mode,
    required this.action,
    required this.extraKey,
  });

  /// Indica se o modo broadcast está totalmente configurado
  /// (modo selecionado + action + extraKey não vazios).
  bool get isBroadcastConfigured =>
      mode == ScannerInputMode.broadcast && action.isNotEmpty && extraKey.isNotEmpty;

  static const empty = ScannerModePreferences(
    mode: ScannerInputMode.focus,
    action: '',
    extraKey: '',
  );
}

/// Coordenador único para o boilerplate de "modo de scanner" repetido
/// em várias telas (S4).
///
/// Cobre:
/// - Iniciar/parar a subscription de broadcast Intent (Android).
/// - Permitir override manual (usuário ligou teclado → para broadcast).
/// - Limpeza determinística no dispose.
///
/// **NÃO** lida com `FocusNode` ou `TextEditingController` da UI —
/// isso continua responsabilidade da tela, porque envolve `BuildContext`
/// e timing visual. O coordinator é puro Dart e testável sem widgets.
///
/// Uso típico:
/// ```dart
/// final coord = ScannerModeCoordinator(
///   broadcastService: locator<BarcodeBroadcastService>(),
///   onBarcode: (code) => _handleBarcode(code),
/// );
/// await coord.start(prefs);              // a partir de currentConfig
/// coord.setManualOverride(true);          // teclado ligado
/// coord.setManualOverride(false);         // teclado desligado
/// coord.dispose();                        // libera subscription
/// ```
class ScannerModeCoordinator {
  static const _logTag = 'ScannerModeCoordinator';

  final BarcodeBroadcastService _broadcastService;
  final void Function(String code) _onBarcode;

  ScannerModePreferences _prefs = ScannerModePreferences.empty;
  StreamSubscription<String>? _subscription;
  bool _manualOverride = false;
  bool _disposed = false;

  ScannerModeCoordinator({
    required BarcodeBroadcastService broadcastService,
    required void Function(String code) onBarcode,
  })  : _broadcastService = broadcastService,
        _onBarcode = onBarcode;

  ScannerModePreferences get preferences => _prefs;

  /// Verdadeiro quando broadcast está configurado e nenhum override
  /// manual desligou-o (ex.: usuário usando teclado).
  bool get isBroadcastActive =>
      _prefs.isBroadcastConfigured && !_manualOverride && _subscription != null;

  /// Inicia (ou re-inicia) o coordinator com novas preferências.
  /// Idempotente: chamar com as mesmas prefs e mesmo override é seguro.
  Future<void> start(ScannerModePreferences prefs) async {
    if (_disposed) return;
    _prefs = prefs;
    await _resync();
  }

  /// Atualiza as preferências sem precisar re-instanciar.
  Future<void> updatePreferences(ScannerModePreferences prefs) async {
    if (_disposed) return;
    _prefs = prefs;
    await _resync();
  }

  /// Define o override manual (teclado ligado/desligado).
  /// Quando `true`, o broadcast é desligado mesmo se as prefs estiverem
  /// configuradas. Quando `false`, volta a ouvir.
  Future<void> setManualOverride(bool override) async {
    if (_disposed || _manualOverride == override) return;
    _manualOverride = override;
    await _resync();
  }

  Future<void> _resync() async {
    if (_disposed) return;
    final shouldListen = _prefs.isBroadcastConfigured && !_manualOverride;
    if (shouldListen) {
      await _startListener();
    } else {
      await _stopListener();
    }
  }

  Future<void> _startListener() async {
    await _stopListener();
    if (_disposed) return;
    try {
      _subscription = _broadcastService
          .listen(action: _prefs.action, extraKey: _prefs.extraKey)
          .listen(
            (code) {
              if (_disposed) return;
              final trimmed = code.trim();
              if (trimmed.isEmpty) return;
              try {
                _onBarcode(trimmed);
              } catch (e, s) {
                AppLogger.error(
                  'Falha no callback onBarcode (broadcast)',
                  tag: _logTag,
                  error: e,
                  stackTrace: s,
                );
              }
            },
            onError: (Object e, StackTrace s) {
              AppLogger.error('Broadcast listener error', tag: _logTag, error: e, stackTrace: s);
            },
            cancelOnError: false,
          );
      AppLogger.debug(
        'Broadcast listener started: action=${_prefs.action} extraKey=${_prefs.extraKey}',
        tag: _logTag,
      );
    } catch (e, s) {
      AppLogger.error('Failed to start broadcast listener', tag: _logTag, error: e, stackTrace: s);
      _subscription = null;
    }
  }

  Future<void> _stopListener() async {
    final sub = _subscription;
    _subscription = null;
    if (sub == null) return;
    try {
      await sub.cancel();
    } catch (e, s) {
      AppLogger.warning('Error canceling broadcast subscription', tag: _logTag, error: e, stackTrace: s);
    }
  }

  /// Libera a subscription. Idempotente.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _stopListener();
  }
}
