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
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
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
    });
  }

  bool get _esDueno => TokenStorage.role == 'dueno';

  // Tabs visibles según rol
  List<HomeTab> get _tabs => _esDueno
      ? [HomeTab.inicio, HomeTab.buscar, HomeTab.reportes, HomeTab.perfil]
      : HomeTab.values;

  void _onTabSelected(int index) {
    final tab = _tabs[index];
    switch (tab) {
      case HomeTab.inicio:
        break;
      case HomeTab.buscar:
        context.push(AppRoutes.alertas);
        break;
      case HomeTab.registrar:
        context.push(AppRoutes.registroBovino);
        break;
      case HomeTab.reportes:
        context.push(AppRoutes.historial);
        break;
      case HomeTab.perfil:
        context.push(AppRoutes.perfil);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => context.read<HomeViewModel>().cargarDatos(),
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
                                  Text(
                                    vm.userName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.push(AppRoutes.alertas),
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
                            onVerTodos: () {},
                            onAnimalTap: (animal) => context.push(
                              AppRoutes.detalleBovino,
                              extra: animal,
                            ),
                          ),
                          if (TokenStorage.role != 'dueno') ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.push(AppRoutes.registroBovino),
                              icon: const Icon(Icons.add),
                              label: const Text('Registrar bovino'),
                            ),
                          ],
                          const SizedBox(height: 16),
                          HomePredicciones(
                            predicciones: vm.predicciones,
                            onVerHistorial: () =>
                                context.push(AppRoutes.historial),
                          ),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                ),
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
