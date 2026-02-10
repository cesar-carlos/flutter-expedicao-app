import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

/// Serviço para carregar o logo da empresa para impressão térmica
class CompanyLogoService {
  static const String _defaultLogoAsset = 'assets/images/log_se7e_black.png';

  /// Carrega o logo da empresa como Uint8List para uso em ESC/POS
  ///
  /// Retorna null se o asset não existir ou houver erro na leitura
  Future<Uint8List?> loadLogoBytes({String? assetPath}) async {
    final path = assetPath ?? _defaultLogoAsset;

    try {
      final byteData = await rootBundle.load(path);
      return byteData.buffer.asUint8List();
    } catch (e) {
      // Se falhar, retorna null silenciosamente (logo é opcional)
      return null;
    }
  }

  /// Carrega o logo padrão da empresa
  Future<Uint8List?> loadDefaultLogo() async {
    return loadLogoBytes(assetPath: _defaultLogoAsset);
  }

  /// Carrega logo branco (para fundo escuro)
  Future<Uint8List?> loadWhiteLogo() async {
    return loadLogoBytes(assetPath: 'assets/images/log_se7e_white.png');
  }

  /// Carrega logo preto (para fundo claro)
  Future<Uint8List?> loadBlackLogo() async {
    return loadLogoBytes(assetPath: 'assets/images/log_se7e_black.png');
  }
}
