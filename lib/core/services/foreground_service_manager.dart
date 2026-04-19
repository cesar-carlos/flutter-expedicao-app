import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {}
}

class ForegroundServiceManager {
  static final ForegroundServiceManager _instance = ForegroundServiceManager._internal();
  factory ForegroundServiceManager() => _instance;
  ForegroundServiceManager._internal();

  bool _isRunning = false;

  // Bug CCC: lock para start (evita race entre 2 chamadas simultaneas que
  // podiam disparar `startService` duas vezes — gerando notificacoes
  // duplicadas e potencialmente AppOpsManager errors).
  Completer<void>? _starting;

  Future<void> startForegroundService() async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (_isRunning) return;
    if (_starting != null) return _starting!.future;

    _starting = Completer<void>();
    try {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'separation_monitor_channel',
          channelName: 'Monitoramento de Separações',
          channelDescription: 'Monitora novas separações em tempo real',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
        ),
        iosNotificationOptions: const IOSNotificationOptions(showNotification: false),
        foregroundTaskOptions: ForegroundTaskOptions(eventAction: ForegroundTaskEventAction.once()),
      );

      await FlutterForegroundTask.startService(
        notificationTitle: 'Data7 Expedição',
        notificationText: 'Monitorando novas separações...',
        callback: startCallback,
      );

      _isRunning = true;
      _starting!.complete();
    } catch (e, s) {
      // Bug BBB: substitui `print()` por AppLogger (centraliza telemetria).
      AppLogger.error('Erro ao iniciar foreground service', tag: 'ForegroundServiceManager', error: e, stackTrace: s);
      _starting!.completeError(e, s);
      _starting = null;
      rethrow;
    }
  }

  Future<void> stopForegroundService() async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      await FlutterForegroundTask.stopService();
      // Bug DDD: so seta isRunning=false se o stop sucedeu.
      // Antes era setado fora do try, gerando estado inconsistente:
      // manager achava que parou mas o servico continuava ativo.
      _isRunning = false;
    } catch (e, s) {
      AppLogger.error('Erro ao parar foreground service', tag: 'ForegroundServiceManager', error: e, stackTrace: s);
      rethrow;
    }
  }

  bool get isRunning => _isRunning;
}
