import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/home_viewmodel.dart';

class HomeRefreshObserver extends NavigatorObserver {
  void _refreshIfOnHomeRoute(Route? route, {String? from}) {
    final name = route?.settings.name;
    debugPrint('🔍 HomeRefreshObserver._refreshIfOnHomeRoute(from: $from) route?.settings.name: $name, target: ${AppRoutes.home}');
    if (name != AppRoutes.home) return;
    debugPrint('✅ HomeRefreshObserver: coincidió con /home, programando refresh');
    // Diferir al siguiente frame para evitar problemas de contexto
    // durante la transición de navegación (didPop/didReplace se disparan
    // mientras el Navigator aún está mutando el árbol de widgets).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔄 HomeRefreshObserver: ejecutando cargarDatos() post-frame');
      final context = navigator?.context;
      if (context == null) {
        debugPrint('❌ HomeRefreshObserver: navigator?.context es null');
        return;
      }
      try {
        context.read<HomeViewModel>().cargarDatos();
        debugPrint('✅ HomeRefreshObserver: cargarDatos() invocado exitosamente');
      } catch (e) {
        debugPrint('❌ HomeRefreshObserver: error al llamar cargarDatos(): $e');
      }
    });
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    debugPrint('🔙 didPop - route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
    _refreshIfOnHomeRoute(previousRoute, from: 'didPop');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    debugPrint('🔄 didReplace - newRoute: ${newRoute?.settings.name}, oldRoute: ${oldRoute?.settings.name}');
    _refreshIfOnHomeRoute(newRoute, from: 'didReplace');
  }
}
