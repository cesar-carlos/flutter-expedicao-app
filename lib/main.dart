import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exp/core/routing/app_router.dart';
import 'package:exp/core/theme/app_theme.dart';
import 'package:exp/core/network/dio_config.dart';
import 'package:exp/core/network/network_initializer.dart';
import 'package:exp/domain/viewmodels/scanner_viewmodel.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/domain/viewmodels/config_viewmodel.dart';
import 'package:exp/domain/viewmodels/register_viewmodel.dart';
import 'package:exp/domain/viewmodels/theme_viewmodel.dart';
import 'package:exp/domain/viewmodels/socket_viewmodel.dart';
import 'package:exp/data/datasources/config_service.dart';
import 'package:exp/data/datasources/user_preferences_service.dart';
import 'package:exp/di/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();

  final configService = locator<ConfigService>();
  await configService.initialize();

  final configViewModel = locator<ConfigViewModel>();
  await configViewModel.initialize();

  DioConfig.initialize(configViewModel.currentConfig);

  // Inicializar WebSocket
  await NetworkInitializer.initializeSocketService();

  // Inicializar SocketViewModel
  final socketViewModel = locator<SocketViewModel>();
  socketViewModel.initialize();

  // Inicializar UserPreferencesService e ThemeViewModel
  final userPreferencesService = locator<UserPreferencesService>();
  final themeViewModel = ThemeViewModel(userPreferencesService);
  await themeViewModel.initialize();

  runApp(
    MyApp(
      configViewModel: configViewModel,
      themeViewModel: themeViewModel,
      socketViewModel: socketViewModel,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ConfigViewModel configViewModel;
  final ThemeViewModel themeViewModel;
  final SocketViewModel socketViewModel;

  const MyApp({
    super.key,
    required this.configViewModel,
    required this.themeViewModel,
    required this.socketViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScannerViewModel()),
        ChangeNotifierProvider(create: (_) => locator<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<RegisterViewModel>()),
        ChangeNotifierProvider.value(value: configViewModel),
        ChangeNotifierProvider.value(value: themeViewModel),
        ChangeNotifierProvider.value(value: socketViewModel),
      ],
      child: Consumer2<AuthViewModel, ThemeViewModel>(
        builder: (context, authViewModel, themeViewModel, child) {
          final router = AppRouter.createRouter(authViewModel);

          return MaterialApp.router(
            title: 'Data7 Expedição',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeViewModel.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
