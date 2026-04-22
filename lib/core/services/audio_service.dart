import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';

enum SoundType {
  barcodeScan('som/BarcodeScan.wav'),
  success('som/finishi.mp3'),
  notification('som/Notification.wav'),
  shelfScanSuccess('som/new-notification.mp3'),
  cartAddSuccess('som/new-notification-campainha.mp3'),
  itemCompleted('som/success.wav'),
  error('som/Error.wav'),
  fail('som/Fail.wav'),
  alert('som/Alert.wav'),
  alertComplete('som/AlertFalha.wav'),
  disconnected('som/Disconected.wav');

  const SoundType(this.path);
  final String path;
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _fxPlayer = AudioPlayer(playerId: 'fx_player')
    ..setPlayerMode(PlayerMode.lowLatency)
    ..setReleaseMode(ReleaseMode.stop);

  bool _isEnabled = true;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;

  Future<void> playSound(SoundType soundType) async {
    if (!_isEnabled) return;

    try {
      // Bug VV: removido `await _fxPlayer.stop()` antes do play.
      // Adicionava 5-50ms de latencia entre bip do scanner e o som de
      // confirmacao — perceptivel em coletor rapido. O `play()` ja
      // interrompe o som anterior em modo lowLatency, sem necessidade
      // de stop explicito.
      await _fxPlayer.play(AssetSource(soundType.path));
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Erro ao reproduzir som: ${soundType.path}',
        tag: 'AudioService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> playBarcodeScan() async {
    await playSound(SoundType.barcodeScan);
  }

  Future<void> playSuccess() async {
    await playSound(SoundType.success);
  }

  Future<void> playNotification() async {
    if (kDebugMode) {
      AppLogger.debug(
        'playNotification (enabled: $_isEnabled, asset: ${SoundType.notification.path})',
        tag: 'AudioService',
      );
    }
    await playSound(SoundType.notification);
  }

  Future<void> playItemCompleted() async {
    await playSound(SoundType.itemCompleted);
  }

  Future<void> playShelfScanSuccess() async {
    await playSound(SoundType.shelfScanSuccess);
  }

  Future<void> playCartAddSuccess() async {
    await playSound(SoundType.cartAddSuccess);
  }

  Future<void> playError() async {
    await playSound(SoundType.error);
  }

  Future<void> playFail() async {
    await playSound(SoundType.fail);
  }

  Future<void> playAlert() async {
    await playSound(SoundType.alert);
  }

  Future<void> playAlertComplete() async {
    await playSound(SoundType.alertComplete);
  }

  Future<void> playDisconnected() async {
    await playSound(SoundType.disconnected);
  }

  Future<void> stop() async {
    try {
      await _fxPlayer.stop();
    } catch (e, s) {
      // Bug YY: antes era bloco vazio. Agora ao menos loga em debug.
      AppLogger.debug('AudioService.stop falhou', tag: 'AudioService', error: e, stackTrace: s);
    }
  }

  Future<void> dispose() async {
    try {
      await _fxPlayer.dispose();
    } catch (e, s) {
      AppLogger.debug('AudioService.dispose falhou', tag: 'AudioService', error: e, stackTrace: s);
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _fxPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e, s) {
      AppLogger.debug('AudioService.setVolume falhou', tag: 'AudioService', error: e, stackTrace: s);
    }
  }

  Future<void> playSoundWithVolume(SoundType soundType, double volume) async {
    if (!_isEnabled) return;

    try {
      await setVolume(volume);
      await playSound(soundType);
    } catch (e, s) {
      AppLogger.debug('AudioService.playSoundWithVolume falhou', tag: 'AudioService', error: e, stackTrace: s);
    }
  }
}
