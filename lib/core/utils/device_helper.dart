import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper para obter informações do dispositivo
class DeviceHelper {
  /// Obtém um identificador único do dispositivo baseado na plataforma
  ///
  /// Retorna uma string que identifica o tipo de dispositivo e plataforma:
  /// - Android: "Android-[hostname]"
  /// - iOS: "iOS-[hostname]"
  /// - Web: "Web-[hostname]"
  /// - Desktop: "[OS]-[hostname]"
  static String getDeviceIdentifier() {
    try {
      if (kIsWeb) return 'Web-${_getHostname()}';
      if (Platform.isAndroid) return 'Android-${_getHostname()}';
      if (Platform.isIOS) return 'iOS-${_getHostname()}';
      if (Platform.isWindows) return 'Windows-${_getHostname()}';
      if (Platform.isMacOS) return 'MacOS-${_getHostname()}';
      if (Platform.isLinux) return 'Linux-${_getHostname()}';
      return 'Unknown-${_getHostname()}';
    } catch (e) {
      return 'Unknown-Device';
    }
  }

  /// Obtém o nome do host do dispositivo
  static String _getHostname() {
    try {
      if (kIsWeb) return 'Browser';
      return Platform.localHostname.isNotEmpty ? Platform.localHostname : 'Device';
    } catch (e) {
      return 'Device';
    }
  }

  /// Obtém o nome da plataforma
  static String getPlatformName() {
    try {
      if (kIsWeb) return 'Web';
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'MacOS';
      if (Platform.isLinux) return 'Linux';
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Verifica se está rodando em um dispositivo móvel
  static bool isMobile() {
    try {
      return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    } catch (e) {
      return false;
    }
  }

  /// Verifica se está rodando em um desktop
  static bool isDesktop() {
    try {
      return !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    } catch (e) {
      return false;
    }
  }
}
