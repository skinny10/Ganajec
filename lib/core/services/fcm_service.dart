import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';

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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Mensaje recibido en primer plano: ${message.notification?.title}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Mensaje abierto: ${message.notification?.title}');
    });
  }
}
