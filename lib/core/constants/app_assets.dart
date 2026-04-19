class AppAssets {
  AppAssets._();

  // === ICONS ===
  static const String _iconsPath = 'assets/icons/';
  static const String appIcon = '${_iconsPath}app_icon.png';
  static const String cartInFullJson = '${_iconsPath}cart_in_full.json';
  static const String playStoreIcon = '${_iconsPath}play_store.png';

  // === IMAGES ===
  static const String _imagesPath = 'assets/images/';
  static const String background = '${_imagesPath}background.png';
  static const String data7Icon = '${_imagesPath}data7-Icon.png';
  static const String globoGif = '${_imagesPath}icons8-globo.gif';
  static const String logBlackIcon = '${_imagesPath}log_black_icon.png';
  static const String logSe7eBlack = '${_imagesPath}log_se7e_black.png';
  static const String logSe7eWhite = '${_imagesPath}log_se7e_white.png';
  static const String logWhite = '${_imagesPath}log_white.png';
  static const String logWhite32px = '${_imagesPath}log_white32px.png';
  static const String produtoSemFoto = '${_imagesPath}produto-sem-foto.jpg';

  // NOTA HISTORICA:
  // * Removido `logBlackIconIco` (`log_black_icon.ico`): asset .ico
  //   nunca foi usado em runtime do Flutter (formato Windows-only
  //   para o icone do executavel; carregado pelo build do
  //   windows/runner/Runner.rc, nao via AssetImage).
  // * Removido `allAssets` (lista de todos os paths): nenhum
  //   chamador. Era apenas um vetor frageis: facil de esquecer ao
  //   adicionar novo asset. A fonte canonica de assets continua
  //   sendo o `pubspec.yaml`.
}
