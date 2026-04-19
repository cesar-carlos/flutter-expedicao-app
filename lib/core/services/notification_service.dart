import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Bug ZZ: lock para evitar inicializacao paralela (race entre 2 chamadas
  // simultaneas em telas diferentes na partida do app).
  Completer<void>? _initializing;

  Future<void> initialize() async {
    if (_initialized) return;
    // Se ja em curso, aguarda a inicializacao em andamento.
    if (_initializing != null) return _initializing!.future;

    _initializing = Completer<void>();
    try {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

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
      _initializing!.complete();
    } catch (e, s) {
      AppLogger.error('Falha ao inicializar NotificationService', tag: 'NotificationService', error: e, stackTrace: s);
      _initializing!.completeError(e, s);
      _initializing = null;
      rethrow;
    }
  }

  Future<void> showNewSeparationNotification({
    required int codSepararEstoque,
    required String nomeEntidade,
    required List<int>? codSetoresEstoque,
  }) async {
    if (!_initialized) {
      try {
        await initialize();
      } catch (e) {
        // Notificacao eh "nice to have" — nao bloqueia o fluxo principal.
        AppLogger.warning('Notificacao ignorada: falha na inicializacao', tag: 'NotificationService', error: e);
        return;
      }
    }

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

      try {
        await _notificationsPlugin.show(
          codSepararEstoque,
          'Nova Separação Disponível',
          '$nomeEntidade - Setor: ${codSetoresEstoque?.join(", ") ?? "Todos"}',
          notificationDetails,
        );
      } catch (e, s) {
        AppLogger.warning('Falha ao mostrar notificacao', tag: 'NotificationService', error: e, stackTrace: s);
      }
    }
  }
}
