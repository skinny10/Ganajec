import 'package:flutter/material.dart';
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
    } catch (e) {
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
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
}