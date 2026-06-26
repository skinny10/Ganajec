import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_providers.dart';
import 'core/providers/ganadero_providers.dart';

class GanajecApp extends StatelessWidget {
  const GanajecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...authProviders,
        ...ganaderoProviders,
      ],
      child: MaterialApp.router(
        title: 'GANAJEC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(context),
        darkTheme: AppTheme.dark(context),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}