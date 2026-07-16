import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    Stripe.publishableKey =
        'pk_test_51Tn0A7TpZVzLqUn7gkDK2KO7IISMne8hXTvU5psJ5R8zpZXjxMCSrvoH5ogjgcyJ8OvCspxNih4RroIqXE4iIhi00mLliLyj3';
    await Stripe.instance.applySettings();
  }

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (_) => const GanajecApp(),
    ),
  );
}