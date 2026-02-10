import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    _initialized = true;
  }

  Future<void> showNewSeparationNotification({
    required int codSepararEstoque,
    required String nomeEntidade,
    required List<int>? codSetoresEstoque,
  }) async {
    if (!_initialized) await initialize();

    if (!kIsWeb && Platform.isAndroid) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'separations_channel',
        'Novas Separações',
        channelDescription: 'Notificações de novas separações disponíveis',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        codSepararEstoque,
        'Nova Separação Disponível',
        '$nomeEntidade - Setor: ${codSetoresEstoque?.join(", ") ?? "Todos"}',
        notificationDetails,
      );
    }
  }
}
