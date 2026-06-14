import 'package:dio/dio.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'auth_interceptor.dart';

/// Singleton de Dio configurado con baseUrl y AuthInterceptor.
/// Usa [ApiClient.instance] para hacer peticiones HTTP.
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
    dio.interceptors.add(AuthInterceptor());
    return dio;
  }
}
