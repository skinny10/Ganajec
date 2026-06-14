import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Inyecta el Bearer token en cada petición autenticada.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = TokenStorage.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Podrías manejar 401 (token expirado) aquí en el futuro.
    handler.next(err);
  }
}
