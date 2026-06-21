import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';

enum CambiarContrasenaStatus { idle, loading, success, error }

class CambiarContrasenaViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

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

    if (nuevaCtrl.text.trim().isEmpty || confirmarCtrl.text.trim().isEmpty) {
      _error = 'Completa todos los campos';
      _status = CambiarContrasenaStatus.error;
      notifyListeners();
      return;
    }
    if (nuevaCtrl.text != confirmarCtrl.text) {
      _error = 'Las contraseñas no coinciden';
      _status = CambiarContrasenaStatus.error;
      notifyListeners();
      return;
    }
    if (nuevaCtrl.text.length < 6) {
      _error = 'La contraseña debe tener al menos 6 caracteres';
      _status = CambiarContrasenaStatus.error;
      notifyListeners();
      return;
    }

    _status = CambiarContrasenaStatus.loading;
    notifyListeners();

    try {
      final uid = TokenStorage.userId ?? '';
      await _dio.put(
        ApiConstants.actualizarPerfilGanaderoV2(uid),
        data: {'password': nuevaCtrl.text.trim()},
      );
      _status = CambiarContrasenaStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al cambiar contraseña';
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
    nuevaCtrl.dispose();
    confirmarCtrl.dispose();
    super.dispose();
  }
}
