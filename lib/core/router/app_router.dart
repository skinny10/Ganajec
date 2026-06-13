import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/features/auth/presentation/screens/login/login_screen.dart';
import 'package:ganajec/features/auth/presentation/screens/register/register_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/home/home_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/registro_bovino/registro_bovino_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/detalle_bovino/detalle_bovino_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/editar_bovino/editar_bovino_screen.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/detalle_bovino_viewmodel.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/editar_bovino_viewmodel.dart';
import 'package:ganajec/features/ganadero/domain/usecase/get_historial_animal_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/get_predicciones_animal_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/actualizar_animal_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/eliminar_animal_usecase.dart';
import 'package:ganajec/features/ganadero/data/repositories/ganadero_repo_impl.dart';
import 'package:ganajec/features/ganadero/data/datasource/ganadero_remote_ds.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String registroBovino = '/registro-bovino';
  static const String detalleBovino = '/detalle-bovino';
  static const String editarBovino = '/editar-bovino';
}

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.registroBovino,
        builder: (context, state) => const RegistroBovinoScreen(),
      ),
      GoRoute(
        path: AppRoutes.detalleBovino,
        builder: (context, state) {
          final animal = state.extra as Animal;
          final ds = GanaderoRemoteDataSourceImpl();
          final repo = GanaderoRepositoryImpl(ds);
          return ChangeNotifierProvider(
            create: (_) => DetalleBovinoViewModel(
              getHistorialAnimal: GetHistorialAnimalUseCase(repo),
              getPrediccionesAnimal: GetPrediccionesAnimalUseCase(repo),
            ),
            child: DetalleBovinoScreen(animal: animal),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editarBovino,
        builder: (context, state) {
          final animal = state.extra as Animal;
          final ds = GanaderoRemoteDataSourceImpl();
          final repo = GanaderoRepositoryImpl(ds);
          return ChangeNotifierProvider(
            create: (_) => EditarBovinoViewModel(
              actualizarAnimal: ActualizarAnimalUseCase(repo),
              eliminarAnimal: EliminarAnimalUseCase(repo),
            ),
            child: EditarBovinoScreen(animal: animal),
          );
        },
      ),
    ],
  );
}
