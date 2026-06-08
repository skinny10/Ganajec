import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login/login_screen.dart';
import '../../features/auth/presentation/screens/register/register_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
}