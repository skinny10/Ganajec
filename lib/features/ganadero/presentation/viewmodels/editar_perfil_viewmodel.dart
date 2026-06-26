import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';

enum EditarPerfilStatus { idle, loading, success, error }

class EditarPerfilViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  EditarPerfilStatus _status = EditarPerfilStatus.idle;
  String? _error;

  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  EditarPerfilStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == EditarPerfilStatus.loading;
  bool get isSuccess => _status == EditarPerfilStatus.success;

  EditarPerfilViewModel() {
    nombreCtrl.text = TokenStorage.userName ?? '';
    emailCtrl.text = TokenStorage.email ?? '';
  }

  Future<void> guardar() async {
    final nombre = nombreCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (nombre.isEmpty || email.isEmpty) {
      _error = 'Nombre y correo son obligatorios';
      _status = EditarPerfilStatus.error;
      notifyListeners();
      return;
    }

    _status = EditarPerfilStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final uid  = TokenStorage.userId ?? '';
      final role = TokenStorage.role ?? 'ganadero';
      final endpoint = role == 'dueno'
          ? ApiConstants.actualizarPerfilDueno(uid)
          : ApiConstants.actualizarPerfilGanaderoV2(uid);
      await _dio.put(endpoint, data: {'nombre': nombre, 'email': email});
      // Actualizar caché local
      await TokenStorage.saveSession(
        token: TokenStorage.token ?? '',
        userId: uid,
        role: TokenStorage.role ?? '',
        name: nombre,
        email: email,
      );
      _status = EditarPerfilStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al guardar perfil';
      _status = EditarPerfilStatus.error;
    } catch (e) {
      _error = 'Error inesperado';
      _status = EditarPerfilStatus.error;
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
