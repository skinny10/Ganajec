import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.init();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const GanajecApp(),
    ),
  );
}
