import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
    Future.microtask(
      () => context.read<HomeViewModel>().cargarDatos(),
    );
  }

  void _onTabSelected(int index) {
    final tab = HomeTab.values[index];
    switch (tab) {
      case HomeTab.inicio:
        break;
      case HomeTab.buscar:
        // context.push('/buscar');
        break;
      case HomeTab.registrar:
        context.push(AppRoutes.registroBovino);
      case HomeTab.reportes:
        // context.push('/reportes');
        break;
      case HomeTab.perfil:
        // context.push('/perfil');
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
                                    'Buenos días,',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                  Text(
                                    'Juan Pérez',
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
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_outlined),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: colors.primaryContainer,
                              child: Text(
                                'JP',
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
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                              onPressed: () => context.push(AppRoutes.registroBovino),
                            icon: const Icon(Icons.add),
                            label: const Text('Registrar bovino'),
                          ),
                          const SizedBox(height: 16),
                          HomePredicciones(
                            predicciones: vm.predicciones,
                            onVerHistorial: () {},
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Registrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}