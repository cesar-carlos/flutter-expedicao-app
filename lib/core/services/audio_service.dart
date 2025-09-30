import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sons disponíveis no sistema
enum SoundType {
  barcodeScan('som/BarcodeScan.wav'),
  success('som/Notification.wav'),
  error('som/Error.wav'),
  fail('som/Fail.wav'),
  alert('som/Alert.wav'),
  disconnected('som/Disconected.wav');

  const SoundType(this.path);
  final String path;
}

/// Serviço centralizado para gerenciar reprodução de áudios
/// Gerencia os sons de feedback do sistema (scan, erro, notificação, etc.)
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isEnabled = true;

  /// Habilita ou desabilita os sons do sistema
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Verifica se os sons estão habilitados
  bool get isEnabled => _isEnabled;

  /// Reproduz um som específico
  Future<void> playSound(SoundType soundType) async {
    if (!_isEnabled) return;

    try {
      await _audioPlayer.play(AssetSource(soundType.path));
    } catch (e) {
      if (kDebugMode) {
        // Erro ao reproduzir som
      }
    }
  }

  /// Reproduz som de scan de código de barras
  Future<void> playBarcodeScan() async {
    await playSound(SoundType.barcodeScan);
  }

  /// Reproduz som de sucesso/notificação
  Future<void> playSuccess() async {
    await playSound(SoundType.success);
  }

  /// Reproduz som de erro
  Future<void> playError() async {
    await playSound(SoundType.error);
  }

  /// Reproduz som de falha
  Future<void> playFail() async {
    await playSound(SoundType.fail);
  }

  /// Reproduz som de alerta
  Future<void> playAlert() async {
    await playSound(SoundType.alert);
  }

  /// Reproduz som de desconexão
  Future<void> playDisconnected() async {
    await playSound(SoundType.disconnected);
  }

  /// Para a reprodução atual
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        // Erro ao parar reprodução
      }
    }
  }

  /// Libera recursos do player
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      if (kDebugMode) {
        // Erro ao liberar recursos do AudioPlayer
      }
    }
  }

  /// Define o volume (0.0 a 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) {
        // Erro ao definir volume
      }
    }
  }

  /// Reproduz som com volume específico
  Future<void> playSoundWithVolume(SoundType soundType, double volume) async {
    if (!_isEnabled) return;

    try {
      await setVolume(volume);
      await playSound(soundType);
    } catch (e) {
      if (kDebugMode) {
        // Erro ao reproduzir som com volume
      }
    }
  }
}
