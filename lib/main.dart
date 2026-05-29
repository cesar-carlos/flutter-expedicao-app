import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/bootstrap.dart';
import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/theme/app_theme.dart';
import 'package:data7_expedicao/presentation/viewmodels/app_update_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/register_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/scanner_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/theme_viewmodel.dart';
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static bool _hasScheduledUpdateCheck = false;
  bool _updateDialogShown = false;
  bool _progressDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Ao encerrar o app, cancela o timer periódico e dispara o save final
    // das métricas (até então perdíamos as métricas acumuladas desde o
    // último save automático). Resolvido via locator com try/catch porque
    // MetricsCollector não é crítico e pode não estar registrado.
    if (state == AppLifecycleState.detached) {
      try {
        locator<MetricsCollector>().disposeCollector();
      } catch (e, s) {
        AppLogger.warning(
          'Falha ao finalizar MetricsCollector no encerramento do app',
          tag: 'MyApp',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

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
                unawaited(
                  Future<void>.delayed(const Duration(seconds: 2), () {
                    final owner = dotenv.env['GITHUB_OWNER']?.trim();
                    final repo = dotenv.env['GITHUB_REPO']?.trim();
                    unawaited(
                      appUpdateViewModel.checkForUpdate(owner: owner, repo: repo, forceCheck: false).catchError((
                        Object e,
                        StackTrace s,
                      ) {
                        AppLogger.warning(
                          'Falha na verificação automática de atualização',
                          tag: 'MyApp',
                          error: e,
                          stackTrace: s,
                        );
                      }),
                    );
                  }).catchError((Object e, StackTrace s) {
                    AppLogger.warning(
                      'Falha no atraso da verificação automática de atualização',
                      tag: 'MyApp',
                      error: e,
                      stackTrace: s,
                    );
                  }),
                );
              }
            });
          }

          if (appUpdateViewModel.hasUpdate && appUpdateViewModel.updateAvailable != null && !_updateDialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_updateDialogShown) {
                _updateDialogShown = true;
                unawaited(
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AppUpdateDialog(release: appUpdateViewModel.updateAvailable!),
                  ).then((_) {
                    _updateDialogShown = false;
                  }).catchError((Object e, StackTrace s) {
                    _updateDialogShown = false;
                    AppLogger.warning(
                      'Falha ao exibir dialog de atualização do app',
                      tag: 'MyApp',
                      error: e,
                      stackTrace: s,
                    );
                  }),
                );
              }
            });
          } else if (!appUpdateViewModel.hasUpdate && _updateDialogShown) {
            _updateDialogShown = false;
          }

          if ((appUpdateViewModel.isDownloading || appUpdateViewModel.isInstalling) && !_progressDialogShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_progressDialogShown) {
                _progressDialogShown = true;
                unawaited(
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const AppUpdateProgressDialog(),
                  ).then((_) {
                    _progressDialogShown = false;
                  }).catchError((Object e, StackTrace s) {
                    _progressDialogShown = false;
                    AppLogger.warning(
                      'Falha ao exibir dialog de progresso de atualização',
                      tag: 'MyApp',
                      error: e,
                      stackTrace: s,
                    );
                  }),
                );
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
