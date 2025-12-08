import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/network/dio_config.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/register_viewmodel.dart';
import 'package:data7_expedicao/data/datasources/user_preferences_service.dart';
import 'package:data7_expedicao/domain/viewmodels/scanner_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/theme_viewmodel.dart';
import 'package:data7_expedicao/core/network/network_initializer.dart';
import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/theme/app_theme.dart';
import 'package:data7_expedicao/domain/viewmodels/app_update_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/app_update_dialog.dart';
import 'package:data7_expedicao/ui/widgets/app_update_progress_dialog.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  setupLocator();

  final configService = locator<ConfigService>();
  await configService.initialize();

  final configViewModel = locator<ConfigViewModel>();
  await configViewModel.initialize();

  DioConfig.initialize(configViewModel.currentConfig);

  await NetworkInitializer.initializeSocketService();

  final socketViewModel = locator<SocketViewModel>();
  socketViewModel.initialize();

  final userPreferencesService = locator<UserPreferencesService>();
  final themeViewModel = ThemeViewModel(userPreferencesService);
  await themeViewModel.initialize();

  runApp(MyApp(configViewModel: configViewModel, themeViewModel: themeViewModel, socketViewModel: socketViewModel));
}

class MyApp extends StatelessWidget {
  final ConfigViewModel configViewModel;
  final ThemeViewModel themeViewModel;
  final SocketViewModel socketViewModel;

  const MyApp({super.key, required this.configViewModel, required this.themeViewModel, required this.socketViewModel});

  @override
  Widget build(BuildContext context) {
    final appUpdateViewModel = locator<AppUpdateViewModel>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScannerViewModel()),
        ChangeNotifierProvider(create: (_) => locator<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<RegisterViewModel>()),
        ChangeNotifierProvider.value(value: configViewModel),
        ChangeNotifierProvider.value(value: themeViewModel),
        ChangeNotifierProvider.value(value: socketViewModel),
        ChangeNotifierProvider.value(value: appUpdateViewModel),
      ],
      child: Consumer3<AuthViewModel, ThemeViewModel, AppUpdateViewModel>(
        builder: (context, authViewModel, themeViewModel, appUpdateViewModel, child) {
          final router = AppRouter.createRouter(authViewModel);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (kReleaseMode) {
              appUpdateViewModel.checkForUpdate();
            }
          });

          if (appUpdateViewModel.hasUpdate && appUpdateViewModel.updateAvailable != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AppUpdateDialog(release: appUpdateViewModel.updateAvailable!),
              );
            });
          }

          if (appUpdateViewModel.isDownloading || appUpdateViewModel.isInstalling) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(context: context, barrierDismissible: false, builder: (_) => const AppUpdateProgressDialog());
            });
          }

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
