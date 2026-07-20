import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';

final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();
bool _initialized = false;

Future<void> _initLocalNotif() async {
  if (_initialized) return;
  _initialized = true;

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

Future<void> _showNotification(String title, String body) async {
  try {
    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ganajec_default',
          'Notificaciones GANAJEC',
          channelDescription: 'Notificaciones de la aplicación GANAJEC',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
    debugPrint('[FCM] Notificación local mostrada: $title');
  } catch (e) {
    debugPrint('[FCM] Error mostrando notificación local: $e');
  }
}

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Mensaje en segundo plano: ${message.messageId}');
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
      debugPrint('[FCM] === Mensaje recibido en primer plano ===');
      debugPrint('[FCM] messageId: ${message.messageId}');
      debugPrint('[FCM] notification: ${message.notification?.title} / ${message.notification?.body}');
      debugPrint('[FCM] data keys: ${message.data.keys}');
      debugPrint('[FCM] data completo: ${message.data}');

      final title = message.notification?.title
          ?? message.data['title']
          ?? message.data['titulo']
          ?? 'GANAJEC';
      final body = message.notification?.body
          ?? message.data['body']
          ?? message.data['mensaje']
          ?? message.data['message']
          ?? '';

      _showNotification(title, body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Mensaje abierto desde background: ${message.notification?.title}');
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] App abierta desde estado terminado: ${initialMessage.notification?.title}');
    }
  }
}
