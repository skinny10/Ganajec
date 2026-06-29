import 'package:dio/dio.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';

abstract class PaymentRemoteDataSource {
  Future<String> createPaymentIntent(int amount, String currency);
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
}