import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/features/auth/presentation/screens/login/login_screen.dart';
import 'package:ganajec/features/auth/presentation/screens/register/register_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/home/home_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/registro_bovino/registro_bovino_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/detalle_bovino/detalle_bovino_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/editar_bovino/editar_bovino_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/perfil/perfil_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/registrar_sintomas/registrar_sintomas_screen.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/registrar_sintomas_viewmodel.dart';
import 'package:ganajec/features/ganadero/domain/usecase/registrar_sintomas_usecase.dart';
import 'package:ganajec/features/ganadero/presentation/screens/resultado_prediccion/resultado_prediccion_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/resultado_prediccion/resultado_prediccion_args.dart';
import 'package:ganajec/features/ganadero/presentation/screens/alertas/alertas_screen.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/alertas_viewmodel.dart';
import 'package:ganajec/features/ganadero/domain/usecase/get_alertas_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/marcar_alerta_leida_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/marcar_todas_alertas_leidas_usecase.dart';
import 'package:ganajec/features/suscripcion/presentation/screens/mi_plan/mi_plan_screen.dart';
import 'package:ganajec/features/suscripcion/presentation/screens/elegir_plan/elegir_plan_screen.dart';
import 'package:ganajec/features/suscripcion/presentation/viewmodels/mi_plan_viewmodel.dart';
import 'package:ganajec/features/suscripcion/presentation/viewmodels/elegir_plan_viewmodel.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/get_suscripcion_usecase.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/get_planes_usecase.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/suscribirse_usecase.dart';
import 'package:ganajec/features/suscripcion/data/repositories/suscripcion_repo_impl.dart';
import 'package:ganajec/features/suscripcion/data/datasource/suscripcion_remote_ds.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/detalle_bovino_viewmodel.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/editar_bovino_viewmodel.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/perfil_viewmodel.dart';
import 'package:ganajec/features/ganadero/domain/usecase/get_historial_animal_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/get_predicciones_animal_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/actualizar_animal_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/eliminar_animal_usecase.dart';
import 'package:ganajec/features/ganadero/data/repositories/ganadero_repo_impl.dart';
import 'package:ganajec/features/ganadero/data/datasource/ganadero_remote_ds.dart';
import 'package:ganajec/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:ganajec/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:ganajec/features/auth/domain/usecase/logout_usecase.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String registroBovino = '/registro-bovino';
  static const String detalleBovino = '/detalle-bovino';
  static const String editarBovino = '/editar-bovino';
  static const String perfil = '/perfil';
  static const String registrarSintomas = '/registrar-sintomas';
  static const String resultadoPrediccion = '/resultado-prediccion';
  static const String alertas = '/alertas';
  static const String miPlan = '/mi-plan';
  static const String elegirPlan = '/elegir-plan';
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
      GoRoute(
        path: AppRoutes.perfil,
        builder: (context, state) {
          final authDs = AuthRemoteDataSourceImpl();
          final authRepo = AuthRepositoryImpl(authDs);
          return ChangeNotifierProvider(
            create: (_) => PerfilViewModel(
              logoutUseCase: LogoutUseCase(authRepo),
            ),
            child: const PerfilScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.registrarSintomas,
        builder: (context, state) {
          final animal = state.extra as Animal;
          final ds = GanaderoRemoteDataSourceImpl();
          final repo = GanaderoRepositoryImpl(ds);
          return ChangeNotifierProvider(
            create: (_) => RegistrarSintomasViewModel(
              animal: animal,
              registrarSintomas: RegistrarSintomasUseCase(repo),
            ),
            child: const RegistrarSintomasScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.resultadoPrediccion,
        builder: (context, state) {
          final args = state.extra as ResultadoPrediccionArgs;
          return ResultadoPrediccionScreen(args: args);
        },
      ),
      GoRoute(
        path: AppRoutes.alertas,
        builder: (context, state) {
          final ds = GanaderoRemoteDataSourceImpl();
          final repo = GanaderoRepositoryImpl(ds);
          return ChangeNotifierProvider(
            create: (_) => AlertasViewModel(
              getAlertas: GetAlertasUseCase(repo),
              marcarLeida: MarcarAlertaLeidaUseCase(repo),
              marcarTodas: MarcarTodasAlertasLeidasUseCase(repo),
            ),
            child: const AlertasScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.miPlan,
        builder: (context, state) {
          final ds = SuscripcionRemoteDataSourceImpl();
          final repo = SuscripcionRepositoryImpl(ds);
          return ChangeNotifierProvider(
            create: (_) => MiPlanViewModel(
              getSuscripcion: GetSuscripcionUseCase(repo),
              getPlanes: GetPlanesUseCase(repo),
            ),
            child: const MiPlanScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.elegirPlan,
        builder: (context, state) {
          final planInicialStr = state.extra as String?;
          final planInicial = planInicialStr != null
              ? PlanTipo.values.firstWhere(
                  (p) => p.name == planInicialStr,
                  orElse: () => PlanTipo.basico,
                )
              : null;
          final ds = SuscripcionRemoteDataSourceImpl();
          final repo = SuscripcionRepositoryImpl(ds);
          return ChangeNotifierProvider(
            create: (_) => ElegirPlanViewModel(
              getSuscripcion: GetSuscripcionUseCase(repo),
              getPlanes: GetPlanesUseCase(repo),
              suscribirse: SuscribirseUseCase(repo),
              planInicial: planInicial,
            ),
            child: const ElegirPlanScreen(),
          );
        },
      ),
    ],
  );
}
