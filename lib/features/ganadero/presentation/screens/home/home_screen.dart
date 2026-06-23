import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/home_viewmodel.dart';
import 'home_components.dart';
import 'package:ganajec/core/router/app_router.dart';

enum HomeTab { inicio, buscar, registrar, reportes, perfil }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoRouter? _router;
  String? _previousLocation;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final router = GoRouter.of(context);
      _router = router;
      final provider = router.routeInformationProvider;
      _previousLocation = provider.value.uri.toString();
      _cargarDatos();
      _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (mounted) _cargarDatos();
      });
      provider.addListener(_onRouteChanged);
    });
  }

  void _onRouteChanged() {
    final r = _router;
    if (r == null) return;
    final provider = r.routeInformationProvider;
    final location = provider.value.uri.toString();
    if (location == _previousLocation) return;
    _previousLocation = location;
    if (location == AppRoutes.home && mounted) {
      debugPrint('🏠 HomeScreen detectó regreso a /home, refrescando...');
      _cargarDatos();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    final r = _router;
    if (r != null) {
      r.routeInformationProvider.removeListener(_onRouteChanged);
    }
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    await context.read<HomeViewModel>().cargarDatos();
    if (mounted && context.read<HomeViewModel>().hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<HomeViewModel>().errorMessage ?? 'Error al cargar datos',
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool get _esDueno => TokenStorage.role == 'dueno';

  // Tabs visibles según rol
  List<HomeTab> get _tabs => _esDueno
      ? [HomeTab.inicio, HomeTab.buscar, HomeTab.reportes, HomeTab.perfil]
      : HomeTab.values;

  Future<void> _onTabSelected(int index) async {
    final tab = _tabs[index];
    switch (tab) {
      case HomeTab.inicio:
        break;
      case HomeTab.buscar:
        await context.push(AppRoutes.alertas);
        if (mounted) await _cargarDatos();
        break;
      case HomeTab.registrar:
        await context.push(AppRoutes.registroBovino);
        if (mounted) await _cargarDatos();
        break;
      case HomeTab.reportes:
        await context.push(
          _esDueno ? AppRoutes.historialDueno : AppRoutes.historial,
        );
        if (mounted) await _cargarDatos();
        break;
      case HomeTab.perfil:
        await context.push(AppRoutes.perfil);
        if (mounted) await _cargarDatos();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
                onRefresh: _cargarDatos,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vm.saludo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          vm.userName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _esDueno
                                              ? const Color(0xFFFEF9E7)
                                              : const Color(0xFFE8F5EF),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _esDueno
                                                ? const Color(0xFFD4AC0D)
                                                : const Color(0xFF2E7D32),
                                          ),
                                        ),
                                        child: Text(
                                          _esDueno ? 'Dueño' : 'Ganadero',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: _esDueno
                                                ? const Color(0xFF9A7D0A)
                                                : const Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await context.push(AppRoutes.alertas);
                                if (mounted) await _cargarDatos();
                              },
                              icon: const Icon(Icons.notifications_outlined),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: colors.primaryContainer,
                              child: Text(
                                vm.userInitials,
                                style: TextStyle(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          HomeResumen(resumen: vm.resumen),
                          const SizedBox(height: 16),
                          HomeAlertas(alertas: vm.alertas),
                          const SizedBox(height: 8),
                          HomeMiHato(
                            animales: vm.animales,
                            alertas: vm.alertas,
                            esDueno: _esDueno,
                            onVerTodos: () async {
                              await context.push(AppRoutes.historial);
                              if (mounted) await _cargarDatos();
                            },
                            onAnimalTap: _esDueno
                                ? null
                                : (animal) => context.push(
                                      AppRoutes.detalleBovino,
                                      extra: animal,
                                    ),
                          ),
                          if (!_esDueno) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await context.push(AppRoutes.registroBovino);
                                if (mounted) await _cargarDatos();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Registrar bovino'),
                            ),
                          ],
                          const SizedBox(height: 16),
                          HomePredicciones(
                            predicciones: vm.predicciones,
                            onVerHistorial: () async {
                              await context.push(
                                _esDueno
                                    ? AppRoutes.historialDueno
                                    : AppRoutes.historial,
                              );
                              if (mounted) await _cargarDatos();
                            },
                          ),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            if (vm.isLoading)
              const LinearProgressIndicator(),
            if (vm.hasError)
              MaterialBanner(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                content: Text(
                  vm.errorMessage ?? 'Error al cargar datos',
                  style: const TextStyle(fontSize: 13),
                ),
                leading: const Icon(Icons.error_outline, color: Colors.red),
                backgroundColor: Colors.red.shade50,
                actions: [
                  TextButton(
                    onPressed: _cargarDatos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: _onTabSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          if (!_esDueno)
            const NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Registrar',
            ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
