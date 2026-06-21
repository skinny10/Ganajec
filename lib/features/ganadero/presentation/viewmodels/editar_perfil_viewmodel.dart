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

  // Controladores de texto
  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  EditarPerfilStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == EditarPerfilStatus.loading;
  bool get isSuccess => _status == EditarPerfilStatus.success;

  EditarPerfilViewModel() {
    // Pre-fill con datos actuales
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
      final uid = TokenStorage.userId ?? '';
      await _dio.patch(
        ApiConstants.actualizarPerfilGanadero(uid),
        data: {'nombre': nombre, 'email': email},
      );
      // Actualizar TokenStorage local
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
          'Error al guardar';
      _status = EditarPerfilStatus.error;
    } catch (e) {
      _error = e.toString();
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
