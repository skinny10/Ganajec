import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/core/services/fcm_service.dart';
import 'app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBgHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  firebaseBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseBgHandler);
  await Firebase.initializeApp();
  await TokenStorage.init();
  await FcmService.initHandlers();
  runApp(const GanajecApp());
}
