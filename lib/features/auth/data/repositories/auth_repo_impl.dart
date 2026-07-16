import 'package:ganajec/features/auth/domain/entities/user.dart';
import 'package:ganajec/features/auth/domain/repositories/auth_repository.dart';
import 'package:ganajec/features/auth/data/datasources/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login({required String email, required String password}) {
    return remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<void> logout() => remoteDataSource.logout();
}