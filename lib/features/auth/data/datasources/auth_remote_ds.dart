import 'package:ganajec/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Aquí irá Dio cuando conectes la API
  // final Dio dio;
  // AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Mock — simula delay de red
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '1',
      name: 'Carlos Ramos',
      email: email,
      role: 'ganadero',
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '2',
      name: name,
      email: email,
      role: role,
    );
  }
}