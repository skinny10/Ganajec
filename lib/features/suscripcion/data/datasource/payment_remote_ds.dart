import 'package:dio/dio.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';

abstract class PaymentRemoteDataSource {
  Future<String> createPaymentIntent(int amount, String currency);
  Future<List<Map<String, dynamic>>> fetchPlanes();
  Future<Map<String, dynamic>> confirmarSuscripcion({
    required String duenoId,
    required String paymentIntentId,
    required String planId,
    required int monto,
    required String moneda,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio _dio = ApiClient.instance;

  @override
  Future<String> createPaymentIntent(int amount, String currency) async {
    final res = await _dio.post(
      ApiConstants.createPaymentIntent,
      data: {'amount': amount, 'currency': currency},
    );
    return res.data['clientSecret'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPlanes() async {
    final res = await _dio.get(ApiConstants.planesBackend);
    final data = res.data;
    if (data is Map && data.containsKey('planes')) {
      return (data['planes'] as List).cast<Map<String, dynamic>>();
    }
    return (data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> confirmarSuscripcion({
    required String duenoId,
    required String paymentIntentId,
    required String planId,
    required int monto,
    required String moneda,
  }) async {
    final res = await _dio.post(
      ApiConstants.confirmarSuscripcion(duenoId),
      data: {
        'payment_intent_id': paymentIntentId,
        'plan_id': planId,
        'monto': monto,
        'moneda': moneda,
      },
    );
    return res.data as Map<String, dynamic>;
  }
}
