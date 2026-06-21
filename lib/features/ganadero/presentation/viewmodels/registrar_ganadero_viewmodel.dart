import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';

enum RegistrarGanaderoStatus { idle, loading, success, error }

class RegistrarGanaderoViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  RegistrarGanaderoStatus _status = RegistrarGanaderoStatus.idle;
  String? _error;

  RegistrarGanaderoStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == RegistrarGanaderoStatus.loading;
  bool get isSuccess => _status == RegistrarGanaderoStatus.success;

  Future<void> registrar() async {
    final nombre = nombreCtrl.text.trim();
    final email = emailCtrl.text.trim().toLowerCase();
    if (nombre.isEmpty || email.isEmpty) {
      _error = 'Nombre y correo son obligatorios';
      _status = RegistrarGanaderoStatus.error;
      notifyListeners();
      return;
    }

    _status = RegistrarGanaderoStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final ranchoId = TokenStorage.ranchoId ?? '';
      final body = <String, dynamic>{
        'nombre': nombre,
        'email': email,
        if (ranchoId.isNotEmpty) 'rancho_id': ranchoId,
      };
      await _dio.post(ApiConstants.crearGanadero, data: body);
      _status = RegistrarGanaderoStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al registrar ganadero';
      _status = RegistrarGanaderoStatus.error;
    } catch (e) {
      _error = e.toString();
      _status = RegistrarGanaderoStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }
}
