import 'package:go_router/go_router.dart';
import 'package:ganajec/features/auth/presentation/screens/login/login_screen.dart';
import 'package:ganajec/features/auth/presentation/screens/register/register_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/home/home_screen.dart';
import 'package:ganajec/features/ganadero/presentation/screens/registro_bovino/registro_bovino_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String registroBovino = '/registro-bovino';
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
    ],
  );
}