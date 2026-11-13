import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/bootstrap.dart';
import 'package:data7_expedicao/core/errors/global_error_handlers.dart';
import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/theme/app_theme.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/l10n/app_localizations.dart';
import 'package:data7_expedicao/presentation/viewmodels/app_update_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/register_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/scanner_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/servidor_emergencia_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/theme_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/app_update_dialog.dart';
import 'package:data7_expedicao/ui/widgets/app_update_progress_dialog.dart';
import 'package:data7_expedicao/ui/widgets/common/servidor_emergencia_host.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      installGlobalErrorHandlers();

      final boot = await bootstrap();

      runApp(
        MyApp(
          configViewModel: boot.configViewModel,
          themeViewModel: boot.themeViewModel,
          socketViewModel: boot.socketViewModel,
          appUpdateViewModel: boot.appUpdateViewModel,
          servidorEmergenciaViewModel: boot.servidorEmergenciaViewModel,
        ),
      );
    },
    (error, stack) {
      AppLogger.error('Erro não tratado na zona', tag: 'Zone', error: error, stackTrace: stack);
    },
  );
}

class MyApp extends StatefulWidget {
  final ConfigViewModel configViewModel;
  final ThemeViewModel themeViewModel;
  final SocketViewModel socketViewModel;
  final AppUpdateViewModel appUpdateViewModel;
  final ServidorEmergenciaViewModel servidorEmergenciaViewModel;

  const MyApp({
    super.key,
    required this.configViewModel,
    required this.themeViewModel,
    required this.socketViewModel,
    required this.appUpdateViewModel,
    required this.servidorEmergenciaViewModel,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_warmUpAudio());
    });
  }

  Future<void> _warmUpAudio() async {
    try {
      await locator<AudioService>().warmUp();
    } catch (error, stackTrace) {
      AppLogger.warning('Falha ao preparar AudioService', tag: 'MyApp', error: error, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.detached) return;

    try {
      locator<MetricsCollector>().disposeCollector();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Falha ao finalizar MetricsCollector no encerramento do app',
        tag: 'MyApp',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  GoRouter _ensureRouter(AuthViewModel authViewModel) {
    return _router ??= AppRouter.createRouter(authViewModel, navigatorKey: _navigatorKey);
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
        ChangeNotifierProvider.value(value: widget.servidorEmergenciaViewModel),
      ],
      child: Builder(
        builder: (context) {
          final router = _ensureRouter(context.read<AuthViewModel>());
          return Consumer<ThemeViewModel>(
            builder: (context, themeViewModel, _) {
              return MaterialApp.router(
                title: 'Data7 Expedição',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeViewModel.themeMode,
                routerConfig: router,
                builder: (context, child) {
                  return ServidorEmergenciaHost(
                    navigatorKey: _navigatorKey,
                    child: _AppUpdateHost(navigatorKey: _navigatorKey, child: child ?? const SizedBox.shrink()),
                  );
                },
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
          );
        },
      ),
    );
  }
}

class _AppUpdateHost extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _AppUpdateHost({required this.navigatorKey, required this.child});

  @override
  State<_AppUpdateHost> createState() => _AppUpdateHostState();
}

class _AppUpdateHostState extends State<_AppUpdateHost> {
  AppUpdateViewModel? _viewModel;
  bool _checkScheduled = false;
  bool _syncScheduled = false;
  bool _updateDialogVisible = false;
  bool _progressDialogVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = context.read<AppUpdateViewModel>();
    if (identical(_viewModel, viewModel)) return;

    _viewModel?.removeListener(_syncDialogs);
    _viewModel = viewModel;
    viewModel.addListener(_syncDialogs);
    _scheduleInitialCheck(viewModel);
    _syncDialogs();
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_syncDialogs);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _scheduleInitialCheck(AppUpdateViewModel viewModel) {
    if (_checkScheduled || !kReleaseMode) return;
    _checkScheduled = true;
    unawaited(_runInitialCheck(viewModel));
  }

  Future<void> _runInitialCheck(AppUpdateViewModel viewModel) async {
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      final owner = dotenv.env['GITHUB_OWNER']?.trim();
      final repo = dotenv.env['GITHUB_REPO']?.trim();
      await viewModel.checkForUpdate(owner: owner, repo: repo, forceCheck: false);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Falha na verificação automática de atualização',
        tag: 'AppUpdateHost',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _syncDialogs() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;
      _presentPendingDialogs();
    });
  }

  void _presentPendingDialogs() {
    final viewModel = _viewModel;
    final dialogContext = widget.navigatorKey.currentContext;
    if (viewModel == null || dialogContext == null || !dialogContext.mounted) return;

    final release = viewModel.updateAvailable;
    if (viewModel.hasUpdate && release != null && !_updateDialogVisible) {
      _updateDialogVisible = true;
      unawaited(_showUpdateDialog(dialogContext, release));
    } else if (!viewModel.hasUpdate && _updateDialogVisible) {
      _updateDialogVisible = false;
    }

    final showProgress = viewModel.isDownloading || viewModel.isInstalling;
    if (showProgress && !_progressDialogVisible) {
      _progressDialogVisible = true;
      unawaited(_showProgressDialog(dialogContext));
    } else if (!showProgress && _progressDialogVisible) {
      _progressDialogVisible = false;
    }
  }

  Future<void> _showUpdateDialog(BuildContext dialogContext, GitHubRelease release) async {
    try {
      await showDialog<void>(
        context: dialogContext,
        barrierDismissible: false,
        builder: (_) => AppUpdateDialog(release: release),
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Falha ao exibir dialog de atualização do app',
        tag: 'AppUpdateHost',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _updateDialogVisible = false;
    }
  }

  Future<void> _showProgressDialog(BuildContext dialogContext) async {
    try {
      await showDialog<void>(
        context: dialogContext,
        barrierDismissible: false,
        builder: (_) => const AppUpdateProgressDialog(),
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Falha ao exibir dialog de progresso de atualização',
        tag: 'AppUpdateHost',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _progressDialogVisible = false;
    }
  }
}
