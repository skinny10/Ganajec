import 'package:dio/dio.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio = ApiClient.instance;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final token = response.data['access_token'] as String;
    final user = UserModel.fromJson(
      response.data['usuario'] as Map<String, dynamic>,
    );
    await TokenStorage.saveSession(token: token, userId: user.id, role: user.role, name: user.name, email: user.email);
    return user;
  }

  @override
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _dio.post(
      ApiConstants.preRegister,
      data: {
        'nombre': name,
        'email': email,
        'password': password,
        'rol': role,
      },
    );
    return null;
  }


  @override
  Future<void> logout() => TokenStorage.clear();
}
