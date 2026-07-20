import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';

final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

Future<void> _initLocalNotif() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  await _localNotif.initialize(
    const InitializationSettings(android: androidSettings, iOS: iosSettings),
  );
  const androidChannel = AndroidNotificationChannel(
    'ganajec_default',
    'Notificaciones GANAJEC',
    description: 'Notificaciones de la aplicación GANAJEC',
    importance: Importance.high,
  );
  await _localNotif.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(androidChannel);
}

class FcmService {
  final Dio _dio = ApiClient.instance;

  Future<String?> getToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      debugPrint('[FCM] Token obtenido: $token');
      return token;
    } catch (e) {
      debugPrint('[FCM] Error obteniendo token: $e');
      return null;
    }
  }

  Future<void> enviarTokenAlBackend(String token) async {
    try {
      await _dio.put(
        ApiConstants.actualizarFcmToken,
        data: {'fcm_token': token},
      );
      debugPrint('[FCM] Token enviado al backend');
    } catch (e) {
      debugPrint('[FCM] Error enviando token al backend: $e');
    }
  }

  Future<void> registrar() async {
    final notif = FirebaseMessaging.instance;
    await notif.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final token = await getToken();
    if (token != null) {
      await enviarTokenAlBackend(token);
    }
  }

  static Future<void> initHandlers() async {
    await _initLocalNotif();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'GANAJEC';
      final body = message.notification?.body ?? '';
      debugPrint('[FCM] Mensaje recibido en primer plano: $title');
      _localNotif.show(
        DateTime.now().millisecondsSinceEpoch,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ganajec_default',
            'Notificaciones GANAJEC',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Mensaje abierto: ${message.notification?.title}');
    });
  }
}
