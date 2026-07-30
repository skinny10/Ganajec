import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/core/services/fcm_service.dart';
import 'app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBgHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  firebaseBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseBgHandler);
    await FcmService.initHandlers();
  }
  await TokenStorage.init();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const GanajecApp(),
    ),
  );
}
