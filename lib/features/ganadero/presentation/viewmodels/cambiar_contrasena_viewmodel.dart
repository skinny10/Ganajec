import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';

enum CambiarContrasenaStatus { idle, loading, success, error }

class CambiarContrasenaViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  final actualCtrl = TextEditingController();
  final nuevaCtrl = TextEditingController();
  final confirmarCtrl = TextEditingController();

  CambiarContrasenaStatus _status = CambiarContrasenaStatus.idle;
  String? _error;

  CambiarContrasenaStatus get status => _status;
  bool get isLoading => _status == CambiarContrasenaStatus.loading;
  bool get isSuccess => _status == CambiarContrasenaStatus.success;
  String? get error => _error;

  Future<void> cambiar() async {
    _error = null;

    // Validación local
    if (actualCtrl.text.trim().isEmpty ||
        nuevaCtrl.text.trim().isEmpty ||
        confirmarCtrl.text.trim().isEmpty) {
      _error = 'Completa todos los campos';
      _status = CambiarContrasenaStatus.error;
      notifyListeners();
      return;
    }
    if (nuevaCtrl.text != confirmarCtrl.text) {
      _error = 'Las contraseñas nuevas no coinciden';
      _status = CambiarContrasenaStatus.error;
      notifyListeners();
      return;
    }
    if (nuevaCtrl.text.length < 6) {
      _error = 'La nueva contraseña debe tener al menos 6 caracteres';
      _status = CambiarContrasenaStatus.error;
      notifyListeners();
      return;
    }

    _status = CambiarContrasenaStatus.loading;
    notifyListeners();

    try {
      await _dio.post(
        ApiConstants.cambiarContrasena,
        data: {
          'password_actual': actualCtrl.text.trim(),
          'nueva_password': nuevaCtrl.text.trim(),
        },
      );
      _status = CambiarContrasenaStatus.success;
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] as String? ??
          e.response?.data?['message'] as String? ??
          'Error al cambiar contraseña';
      _error = msg;
      _status = CambiarContrasenaStatus.error;
    } catch (e) {
      _error = 'Error inesperado';
      _status = CambiarContrasenaStatus.error;
    }
    notifyListeners();
  }

  void resetStatus() {
    if (_status == CambiarContrasenaStatus.error ||
        _status == CambiarContrasenaStatus.success) {
      _status = CambiarContrasenaStatus.idle;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    actualCtrl.dispose();
    nuevaCtrl.dispose();
    confirmarCtrl.dispose();
    super.dispose();
  }
}
