import 'package:provider/provider.dart';
import '../../features/auth/data/datasources/auth_remote_ds.dart';
import '../../features/auth/data/repositories/auth_repo_impl.dart';
import '../../features/auth/domain/usecase/login_usecase.dart';
import '../../features/auth/domain/usecase/logout_usecase.dart';
import '../../features/auth/domain/usecase/register_usecase.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';

List<ChangeNotifierProvider> authProviders = [
  ChangeNotifierProvider<AuthViewModel>(
    create: (_) => AuthViewModel(
      loginUseCase: LoginUseCase(
        AuthRepositoryImpl(
          AuthRemoteDataSourceImpl(),
        ),
      ),
      registerUseCase: RegisterUseCase(
        AuthRepositoryImpl(
          AuthRemoteDataSourceImpl(),
        ),
      ),
      logoutUseCase: LogoutUseCase(
        AuthRepositoryImpl(
          AuthRemoteDataSourceImpl(),
        ),
      ),
    ),
  ),
];