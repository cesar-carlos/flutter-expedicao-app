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
  SoundType? _lastPlayedSoundType;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;

  Future<void> playSound(SoundType soundType) async {
    if (!_isEnabled) return;

    try {
      // Em alguns dispositivos Android, repetir o mesmo asset no mesmo
      // player lowLatency nao rearma o som corretamente. Isso aparecia
      // no picking como: primeiro scan toca, scans seguintes do mesmo
      // item ficam mudos ate outro som diferente ser reproduzido.
      // Forcamos stop apenas quando o mesmo som sera repetido em
      // sequencia, preservando a menor latencia para sons diferentes.
      if (_lastPlayedSoundType == soundType) {
        await _fxPlayer.stop();
      }

      await _fxPlayer.play(AssetSource(soundType.path));
      _lastPlayedSoundType = soundType;
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
      _lastPlayedSoundType = null;
    } catch (e, s) {
      AppLogger.debug('AudioService.stop falhou', tag: 'AudioService', error: e, stackTrace: s);
    }
  }

  Future<void> dispose() async {
    try {
      await _fxPlayer.dispose();
      _lastPlayedSoundType = null;
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
