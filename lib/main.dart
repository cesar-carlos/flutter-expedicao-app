import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/l10n/app_localizations.dart';
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
import 'package:data7_expedicao/infrastructure/services/logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  setupLocator();

  LoggerService.initialize(level: kDebugMode ? Level.ALL : Level.INFO);

  await locator<MetricsCollector>().init();

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

  final appUpdateViewModel = await locator.getAsync<AppUpdateViewModel>();

  runApp(MyApp(
    configViewModel: configViewModel,
    themeViewModel: themeViewModel,
    socketViewModel: socketViewModel,
    appUpdateViewModel: appUpdateViewModel,
  ));
}

class MyApp extends StatefulWidget {
  final ConfigViewModel configViewModel;
  final ThemeViewModel themeViewModel;
  final SocketViewModel socketViewModel;
  final AppUpdateViewModel appUpdateViewModel;

  const MyApp({
    super.key,
    required this.configViewModel,
    required this.themeViewModel,
    required this.socketViewModel,
    required this.appUpdateViewModel,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static bool _hasScheduledUpdateCheck = false;
  bool _updateDialogShown = false;
  bool _progressDialogShown = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScannerViewModel()),
        ChangeNotifierProvider(create: (_) => locator<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<RegisterViewModel>()),
        ChangeNotifierProvider.value(value: widget.configViewModel),
        ChangeNotifierProvider.value(value: widget.themeViewModel),
        ChangeNotifierProvider.value(value: widget.socketViewModel),
        ChangeNotifierProvider.value(value: widget.appUpdateViewModel),
      ],
      child: Consumer3<AuthViewModel, ThemeViewModel, AppUpdateViewModel>(
        builder: (context, authViewModel, themeViewModel, appUpdateViewModel, child) {
          final router = AppRouter.createRouter(authViewModel);

          if (!_hasScheduledUpdateCheck) {
            _hasScheduledUpdateCheck = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (kReleaseMode) {
                Future.delayed(const Duration(seconds: 2), () {
                  final owner = dotenv.env['GITHUB_OWNER']?.trim();
                  final repo = dotenv.env['GITHUB_REPO']?.trim();
                  appUpdateViewModel.checkForUpdate(owner: owner, repo: repo, forceCheck: false);
                });
              }
            });
          }

          if (appUpdateViewModel.hasUpdate && appUpdateViewModel.updateAvailable != null && !_updateDialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_updateDialogShown) {
                _updateDialogShown = true;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AppUpdateDialog(release: appUpdateViewModel.updateAvailable!),
                ).then((_) {
                  _updateDialogShown = false;
                });
              }
            });
          } else if (!appUpdateViewModel.hasUpdate && _updateDialogShown) {
            _updateDialogShown = false;
          }

          if ((appUpdateViewModel.isDownloading || appUpdateViewModel.isInstalling) && !_progressDialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_progressDialogShown) {
                _progressDialogShown = true;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const AppUpdateProgressDialog(),
                ).then((_) {
                  _progressDialogShown = false;
                });
              }
            });
          } else if (!appUpdateViewModel.isDownloading && !appUpdateViewModel.isInstalling && _progressDialogShown) {
            _progressDialogShown = false;
          }

          return MaterialApp.router(
            title: 'Data7 Expedição',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeViewModel.themeMode,
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('pt', 'BR'),
              Locale('en', 'US'),
            ],
            locale: const Locale('pt', 'BR'),
          );
        },
      ),
    );
  }
}
