/// Constantes relacionadas à interface do usuário
class UIConstants {
  UIConstants._();

  // Durações de animação e delays
  static const Duration shortDelay = Duration(milliseconds: 300);
  static const Duration mediumDelay = Duration(milliseconds: 500);
  static const Duration longDelay = Duration(milliseconds: 1000);

  // Durações de SnackBar
  static const Duration snackBarShortDuration = Duration(seconds: 2);
  static const Duration snackBarMediumDuration = Duration(seconds: 3);
  static const Duration snackBarLongDuration = Duration(seconds: 4);

  // Durações de animação
  static const Duration fadeInDuration = Duration(milliseconds: 200);
  static const Duration slideInDuration = Duration(milliseconds: 300);
  static const Duration scaleInDuration = Duration(milliseconds: 250);

  // Padding e espaçamentos
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border radius
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 20.0;

  // Tamanhos de ícones
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 20.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 64.0;

  // Alturas de componentes
  static const double defaultButtonHeight = 48.0;
  static const double smallButtonHeight = 40.0;
  static const double largeButtonHeight = 56.0;

  // Larguras de componentes
  static const double defaultButtonWidth = 120.0;
  static const double fullWidth = double.infinity;

  // Opacidades
  static const double lowOpacity = 0.1;
  static const double mediumOpacity = 0.3;
  static const double highOpacity = 0.5;
  static const double veryHighOpacity = 0.8;

  // Elevações
  static const double lowElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;

  // Tamanhos de fonte
  static const double smallFontSize = 12.0;
  static const double defaultFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 18.0;
  static const double extraLargeFontSize = 24.0;

  // Limites de caracteres
  static const int maxTextFieldLength = 255;
  static const int maxTextAreaLength = 1000;
  static const int maxSearchQueryLength = 100;

  // Limites de paginação
  static const int defaultPageSize = 20;
  static const int smallPageSize = 10;
  static const int largePageSize = 50;
  static const int extraLargePageSize = 100;

  // Timeouts de rede
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration shortNetworkTimeout = Duration(seconds: 10);
  static const Duration longNetworkTimeout = Duration(minutes: 2);

  // Intervalos de atualização
  static const Duration autoRefreshInterval = Duration(seconds: 30);
  static const Duration shortRefreshInterval = Duration(seconds: 10);
  static const Duration longRefreshInterval = Duration(minutes: 1);

  // Configurações de scroll
  static const double scrollThreshold = 200.0;
  static const double pullToRefreshThreshold = 80.0;

  // Configurações de cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration shortCacheExpiration = Duration(minutes: 15);
  static const Duration longCacheExpiration = Duration(days: 1);

  // Configurações de validação
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Configurações de arquivo
  static const int maxFileSizeMB = 10;
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx', 'txt'];

  // Configurações de notificação
  static const Duration notificationDuration = Duration(seconds: 3);
  static const Duration errorNotificationDuration = Duration(seconds: 5);
  static const Duration successNotificationDuration = Duration(seconds: 2);

  // Configurações de modal
  static const double defaultModalWidth = 400.0;
  static const double largeModalWidth = 600.0;
  static const double extraLargeModalWidth = 800.0;
  static const double defaultModalHeight = 300.0;
  static const double largeModalHeight = 500.0;
  static const double extraLargeModalHeight = 700.0;

  // Configurações de grid
  static const int defaultGridColumns = 2;
  static const int smallGridColumns = 1;
  static const int largeGridColumns = 3;
  static const int extraLargeGridColumns = 4;

  // Configurações de lista
  static const double defaultListItemHeight = 60.0;
  static const double smallListItemHeight = 40.0;
  static const double largeListItemHeight = 80.0;
  static const double extraLargeListItemHeight = 100.0;

  // Configurações de card
  static const double defaultCardElevation = 2.0;
  static const double smallCardElevation = 1.0;
  static const double largeCardElevation = 4.0;

  // Configurações de drawer
  static const double drawerWidth = 280.0;
  static const double smallDrawerWidth = 240.0;
  static const double largeDrawerWidth = 320.0;

  // Configurações de bottom sheet
  static const double defaultBottomSheetHeight = 300.0;
  static const double largeBottomSheetHeight = 500.0;
  static const double extraLargeBottomSheetHeight = 700.0;

  // Configurações de tab
  static const int defaultTabCount = 3;
  static const int smallTabCount = 2;
  static const int largeTabCount = 5;

  // Configurações de loading
  static const Duration loadingDelay = Duration(milliseconds: 500);
  static const Duration shortLoadingDelay = Duration(milliseconds: 200);
  static const Duration longLoadingDelay = Duration(milliseconds: 1000);

  // Configurações de retry
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration shortRetryDelay = Duration(seconds: 1);
  static const Duration longRetryDelay = Duration(seconds: 5);
}
