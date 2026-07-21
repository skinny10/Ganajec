import 'package:dio/dio.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'auth_interceptor.dart';

// SSL Pinning solo en plataformas nativas (Android/iOS/Desktop)
// En Flutter Web dart:io no existe, así que el pinning se omite.
import 'api_client_stub.dart'
    if (dart.library.io) 'api_client_native.dart';

/// Singleton de Dio configurado con baseUrl y AuthInterceptor.
/// En Android/iOS además aplica SSL Certificate Pinning.
class ApiClient {
  ApiClient._();

  static final Dio _dio = _build();
  static Dio get instance => _dio;

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Aplica el adaptador con pinning si estamos en plataforma nativa
    configurarPinning(dio);

    dio.interceptors.add(AuthInterceptor());
    return dio;
  }
}
