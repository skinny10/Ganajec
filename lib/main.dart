import 'package:flutter/material.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.init();
  runApp(const GanajecApp());
}