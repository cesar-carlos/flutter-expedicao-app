import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/bootstrap.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/theme/app_theme.dart';
import 'package:data7_expedicao/domain/viewmodels/app_update_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/register_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/scanner_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/theme_viewmodel.dart';
import 'package:data7_expedicao/l10n/app_localizations.dart';
import 'package:data7_expedicao/ui/widgets/app_update_dialog.dart';
import 'package:data7_expedicao/ui/widgets/app_update_progress_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final boot = await bootstrap();

  runApp(
    MyApp(
      configViewModel: boot.configViewModel,
      themeViewModel: boot.themeViewModel,
      socketViewModel: boot.socketViewModel,
      appUpdateViewModel: boot.appUpdateViewModel,
    ),
  );
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

  /// Bug AAAAAAAAAAA: cache do GoRouter para nao recriar a cada
  /// rebuild do Consumer3 (que dispara em qualquer notify de
  /// auth/theme/appUpdate viewmodels). Antes, recriar custava:
  /// * Perda de state interno de navegacao
  /// * Criacao de nova instancia de GoRouter (caro)
  /// * Re-avaliacao de redirects desnecessaria
  ///
  /// Combinado com `refreshListenable: authViewModel` no router,
  /// o redirect ainda re-avalia automaticamente quando auth muda,
  /// mas sem recriar o router.
  late final GoRouter _router;
  bool _routerInitialized = false;

  GoRouter _getOrCreateRouter(AuthViewModel authViewModel) {
    if (!_routerInitialized) {
      _router = AppRouter.createRouter(authViewModel);
      _routerInitialized = true;
    }
    return _router;
  }

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
          final router = _getOrCreateRouter(authViewModel);

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
            supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
            locale: const Locale('pt', 'BR'),
          );
        },
      ),
    );
  }
}
