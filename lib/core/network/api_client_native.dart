// Implementación nativa (Android/iOS/Desktop) con SSL Certificate Pinning.
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:ganajec/core/security/ssl_pinning.dart';

void configurarPinning(Dio dio) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      return client;
    },
    validateCertificate: SslPinning.validar,
  );
}
