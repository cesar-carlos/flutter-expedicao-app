import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

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

  Future<void> startForegroundService() async {
    if (!kIsWeb && Platform.isAndroid) {
      if (_isRunning) return;

      try {
        FlutterForegroundTask.init(
          androidNotificationOptions: AndroidNotificationOptions(
            channelId: 'separation_monitor_channel',
            channelName: 'Monitoramento de Separações',
            channelDescription: 'Monitora novas separações em tempo real',
            channelImportance: NotificationChannelImportance.LOW,
            priority: NotificationPriority.LOW,
          ),
          iosNotificationOptions: const IOSNotificationOptions(
            showNotification: false,
          ),
          foregroundTaskOptions: ForegroundTaskOptions(
            eventAction: ForegroundTaskEventAction.once(),
          ),
        );

        await FlutterForegroundTask.startService(
          notificationTitle: 'Data7 Expedição',
          notificationText: 'Monitorando novas separações...',
          callback: startCallback,
        );

        _isRunning = true;
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao iniciar foreground service: $e');
        }
      }
    }
  }

  Future<void> stopForegroundService() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await FlutterForegroundTask.stopService();
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao parar foreground service: $e');
        }
      }
      _isRunning = false;
    }
  }

  bool get isRunning => _isRunning;
}
