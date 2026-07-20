import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/core/services/fcm_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FcmService.initHandlers();
  await TokenStorage.init();
  runApp(const GanajecApp());
}
