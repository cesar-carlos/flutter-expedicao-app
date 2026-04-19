import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/core/network/dio_config.dart';
import 'package:data7_expedicao/core/network/network_initializer.dart';
import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/data/datasources/user_preferences_service.dart';
import 'package:data7_expedicao/domain/viewmodels/app_update_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/theme_viewmodel.dart';
import 'package:data7_expedicao/infrastructure/services/logger_service.dart';

class BootstrapResult {
  const BootstrapResult({
    required this.configViewModel,
    required this.themeViewModel,
    required this.socketViewModel,
    required this.appUpdateViewModel,
  });

  final ConfigViewModel configViewModel;
  final ThemeViewModel themeViewModel;
  final SocketViewModel socketViewModel;
  final AppUpdateViewModel appUpdateViewModel;
}

Future<BootstrapResult> bootstrap() async {
  const isIntegrationTest = bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false);

  // Bug AAAAAAAAAA: dotenv era await sem catch — se .env estivesse
  // ausente/corrompido, app crashava sem feedback util. Agora
  // logamos e continuamos com env vazio (caller pode validar
  // configuracoes obrigatorias e mostrar tela de config se faltar).
  try {
    await dotenv.load(fileName: isIntegrationTest ? 'integration_test/.env' : '.env');
  } catch (e, s) {
    AppLogger.warning(
      'Falha ao carregar .env (continuando com env vazio)',
      tag: 'Bootstrap',
      error: e,
      stackTrace: s,
    );
  }

  // setupLocator e LoggerService SAO criticos — se falharem, nada
  // funciona. Mantemos sem catch para fail-fast com stack util.
  setupLocator();
  LoggerService.initialize(level: kDebugMode ? Level.ALL : Level.INFO);

  // Bug BBBBBBBBBB: MetricsCollector nao e critico para o app
  // funcionar — falha aqui (storage cheio, permissao) bloqueava
  // toda inicializacao. Agora apenas logamos.
  try {
    await locator<MetricsCollector>().init();
  } catch (e, s) {
    AppLogger.warning('MetricsCollector falhou em init', tag: 'Bootstrap', error: e, stackTrace: s);
  }

  // Bug CCCCCCCCCC: Hive corrompido bloqueava o app. Agora capturamos
  // e seguimos com config default — usuario pode reconfigurar via UI.
  final configService = locator<ConfigService>();
  try {
    await configService.initialize();
  } catch (e, s) {
    AppLogger.error('ConfigService.initialize falhou', tag: 'Bootstrap', error: e, stackTrace: s);
    // Se config nao inicializa, ConfigViewModel.initialize tambem vai
    // falhar — mas tratamos abaixo. Nao rethrow aqui.
  }

  final configViewModel = locator<ConfigViewModel>();
  try {
    await configViewModel.initialize();
  } catch (e, s) {
    AppLogger.error('ConfigViewModel.initialize falhou (usando default)', tag: 'Bootstrap', error: e, stackTrace: s);
  }

  // DioConfig.initialize e sincrono e deve ter currentConfig sempre
  // (config default ou carregado). Mantemos sem catch — falha aqui e
  // bug no ConfigViewModel.currentConfig que merece fail-fast.
  DioConfig.initialize(configViewModel.currentConfig);

  // Bug DDDDDDDDDD: socket pode nao conectar (servidor fora do ar).
  // App deve iniciar mesmo assim — usuario ve indicador de
  // desconectado e pode reconectar via drawer.
  if (!isIntegrationTest) {
    try {
      await NetworkInitializer.initializeSocketService();
    } catch (e, s) {
      AppLogger.warning(
        'Falha ao inicializar socket service (app continua, usuario pode reconectar)',
        tag: 'Bootstrap',
        error: e,
        stackTrace: s,
      );
    }
  }

  final socketViewModel = locator<SocketViewModel>();
  if (!isIntegrationTest) {
    try {
      socketViewModel.initialize();
    } catch (e, s) {
      AppLogger.warning('SocketViewModel.initialize falhou', tag: 'Bootstrap', error: e, stackTrace: s);
    }
  }

  // Bug EEEEEEEEEE: theme tem fallback para system mode.
  final userPreferencesService = locator<UserPreferencesService>();
  final themeViewModel = ThemeViewModel(userPreferencesService);
  try {
    await themeViewModel.initialize();
  } catch (e, s) {
    AppLogger.warning('ThemeViewModel.initialize falhou (usando default)', tag: 'Bootstrap', error: e, stackTrace: s);
  }

  // Bug FFFFFFFFFF: getAsync pode falhar se alguma dependencia async
  // do AppUpdateViewModel nao estiver pronta. Sem catch, app nao
  // inicia. Como AppUpdateViewModel nao e critico (so checagem de
  // updates), tentamos pegar a versao sync como fallback.
  late final AppUpdateViewModel appUpdateViewModel;
  try {
    appUpdateViewModel = await locator.getAsync<AppUpdateViewModel>();
  } catch (e, s) {
    AppLogger.error(
      'getAsync<AppUpdateViewModel> falhou — tentando get sync como fallback',
      tag: 'Bootstrap',
      error: e,
      stackTrace: s,
    );
    appUpdateViewModel = locator<AppUpdateViewModel>();
  }

  return BootstrapResult(
    configViewModel: configViewModel,
    themeViewModel: themeViewModel,
    socketViewModel: socketViewModel,
    appUpdateViewModel: appUpdateViewModel,
  );
}
