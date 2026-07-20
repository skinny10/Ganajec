import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/services/fcm_service.dart';
import 'package:ganajec/features/auth/domain/entities/user.dart';
import 'package:ganajec/features/auth/domain/usecase/login_usecase.dart';
import 'package:ganajec/features/auth/domain/usecase/logout_usecase.dart';
import 'package:ganajec/features/auth/domain/usecase/register_usecase.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase;

  AuthStatus _status = AuthStatus.idle;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      _user = await _loginUseCase(email: email, password: password);
      _setStatus(AuthStatus.success);
      unawaited(FcmService().registrar());
    } catch (e) {
      _errorMessage = _mapLoginError(e);
      _setStatus(AuthStatus.error);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      _user = await _registerUseCase(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _setStatus(AuthStatus.success);
    } catch (e) {
      _errorMessage = _mapRegisterError(e);
      _setStatus(AuthStatus.error);
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    _user = null;
    _setStatus(AuthStatus.idle);
  }

  void resetStatus() {
    _errorMessage = null;
    _setStatus(AuthStatus.idle);
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  // ── Mapeo de errores a mensajes legibles ─────────────────────────────────

  String _mapLoginError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      switch (status) {
        case 400: return 'Correo o contraseña incorrectos.';
        case 401: return 'Correo o contraseña incorrectos.';
        case 403: return 'Tu cuenta no tiene acceso. Verifica tu correo.';
        case 404: return 'No encontramos una cuenta con ese correo.';
        case 500:
        case 502:
        case 503: return 'El servidor no responde. Intenta más tarde.';
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return 'Sin conexión. Verifica tu internet e intenta de nuevo.';
      }
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'La conexión tardó demasiado. Intenta de nuevo.';
      }
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }

  String _mapRegisterError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      switch (status) {
        case 400: return 'Datos inválidos. Verifica la información ingresada.';
        case 409: return 'Ya existe una cuenta con ese correo. Usa otro correo o inicia sesión.';
        case 422: return 'Información incorrecta. Revisa los campos e intenta de nuevo.';
        case 500:
        case 502:
        case 503: return 'El servidor no responde. Intenta más tarde.';
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return 'Sin conexión. Verifica tu internet e intenta de nuevo.';
      }
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'La conexión tardó demasiado. Intenta de nuevo.';
      }
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}