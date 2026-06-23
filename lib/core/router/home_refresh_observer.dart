import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/home_viewmodel.dart';

class HomeRefreshObserver extends NavigatorObserver {
  void _refreshIfOnHomeRoute(Route? route) {
    if (route?.settings.name != AppRoutes.home) return;
    final context = navigator?.context;
    if (context == null) return;
    try {
      context.read<HomeViewModel>().cargarDatos();
    } catch (_) {}
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _refreshIfOnHomeRoute(previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _refreshIfOnHomeRoute(newRoute);
  }
}
