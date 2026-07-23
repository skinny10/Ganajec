import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/home_viewmodel.dart';
import 'package:ganajec/features/ganadero/presentation/screens/todos_bovinos/todos_bovinos_screen.dart';
import 'home_components.dart';
import 'package:ganajec/core/router/app_router.dart';

enum HomeTab { inicio, buscar, registrar, reportes, perfil }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    Future.microtask(_cargarDatos);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      AppRouter.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await context.read<HomeViewModel>().cargarDatos();
    if (mounted && context.read<HomeViewModel>().hasError) {
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<HomeViewModel>().errorMessage ?? 'Error al cargar datos',
          ),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool get _esDueno => TokenStorage.role == 'dueno';

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
        context.push(AppRoutes.registroBovino).then((_) {
          if (mounted) _cargarDatos();
        });
        break;
      case HomeTab.reportes:
        context.push(
          _esDueno ? AppRoutes.historialDueno : AppRoutes.historial,
        );
        break;
      case HomeTab.perfil:
        context.push(AppRoutes.perfil);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: cs.surface,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero header ──────────────────────────────────
                    _buildHero(context, vm, cs, tt),
                    // ── Main content ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeResumen(resumen: vm.resumen),
                          const SizedBox(height: 20),
                          HomeMiHato(
                            animales: vm.animales,
                            alertas: vm.alertas,
                            esDueno: _esDueno,
                            onVerTodos: () => context.push(
                              AppRoutes.todosBovinos,
                              extra: TodosBovinosArgs(
                                animales: vm.animales,
                                alertas: vm.alertas,
                              ),
                            ),
                            onVerRanchoTodos: (animalesRancho) =>
                                context.push(
                              AppRoutes.todosBovinos,
                              extra: TodosBovinosArgs(
                                animales: animalesRancho,
                                alertas: vm.alertas,
                              ),
                            ),
                            onAnimalTap: _esDueno
                                ? null
                                : (animal) => context.push(
                                      AppRoutes.detalleBovino,
                                      extra: animal,
                                    ),
                          ),
                          if (!_esDueno) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.onSurface,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => context
                                    .push(AppRoutes.registroBovino)
                                    .then((_) {
                                  if (mounted) _cargarDatos();
                                }),
                                icon: const Icon(Icons.add, size: 20),
                                label: Text(
                                  'Registrar bovino',
                                  style: tt.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          HomePredicciones(
                            predicciones: vm.predicciones,
                            onVerHistorial: () => context.push(
                              _esDueno
                                  ? AppRoutes.historialDueno
                                  : AppRoutes.historial,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    // ── Footer landscape (full-width) ─────────────────
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/footer.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: MediaQuery.of(context).size.width >= 768
          ? null
          : (_esDueno
              ? _buildDuenoNav(context, cs, tt)
              : _buildGanaderoNav(context, cs, tt)),
    );
  }

  // ── Hero ────────────────────────────────────────────────────────────────────

  Widget _buildHero(
      BuildContext context,
      HomeViewModel vm,
      ColorScheme cs,
      TextTheme tt,
      ) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      height: topPad + 178,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        image: DecorationImage(
          image: AssetImage('assets/images/cow_pattern.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Overlay para dar contraste al texto sobre el patrón
          Positioned.fill(
            child: ColoredBox(color: Color.fromRGBO(255, 255, 255, 0.55)),
          ),
          // Greeting content
          Positioned(
            left: 20,
            top: topPad + 20,
            right: 104,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.saludo,
                  style: tt.bodyMedium?.copyWith(
                    color: const Color(0xFF5C3820),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vm.userName,
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 34,
                    color: const Color(0xFF3d2b1f),
                    letterSpacing: -0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildRoleBadge(cs, tt),
              ],
            ),
          ),
          // Bell + avatar
          Positioned(
            top: topPad + 16,
            right: 16,
            child: Row(
              children: [
                _buildBellButton(context, vm, cs),
                const SizedBox(width: 8),
                _buildAvatar(vm, cs, tt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _esDueno ? Icons.storefront_rounded : Icons.agriculture_rounded,
            size: 15,
            color: _esDueno ? cs.secondary : cs.tertiary,
          ),
          const SizedBox(width: 6),
          Text(
            _esDueno ? 'Dueño' : 'Ganadero',
            style: tt.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _esDueno ? cs.secondary : cs.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBellButton(
      BuildContext context, HomeViewModel vm, ColorScheme cs) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.alertas),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.notifications_outlined,
                color: cs.onSurface, size: 20),
          ),
          if (vm.alertas.isNotEmpty)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: cs.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(HomeViewModel vm, ColorScheme cs, TextTheme tt) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          vm.userInitials,
          style: tt.labelMedium?.copyWith(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ── Bottom navs ─────────────────────────────────────────────────────────────

  Widget _buildGanaderoNav(
      BuildContext context, ColorScheme cs, TextTheme tt) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 6, 12, MediaQuery.of(context).padding.bottom + 6),
      color: Colors.transparent,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: cs.onSurface.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Inicio (active)
            Expanded(
              child: GestureDetector(
                onTap: () => _onTabSelected(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.home, color: cs.primary, size: 20),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Inicio',
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Alertas
            Expanded(
              child: GestureDetector(
                onTap: () => _onTabSelected(1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_outlined,
                        color: cs.onSurfaceVariant, size: 23),
                    const SizedBox(height: 3),
                    Text(
                      'Alertas',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Center FAB — Registrar
            GestureDetector(
              onTap: () => _onTabSelected(2),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: cs.onSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: cs.surface, size: 26),
                ),
              ),
            ),
            // Reportes
            Expanded(
              child: GestureDetector(
                onTap: () => _onTabSelected(3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_outlined,
                        color: cs.onSurfaceVariant, size: 23),
                    const SizedBox(height: 3),
                    Text(
                      'Reportes',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Perfil
            Expanded(
              child: GestureDetector(
                onTap: () => _onTabSelected(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline,
                        color: cs.onSurfaceVariant, size: 23),
                    const SizedBox(height: 3),
                    Text(
                      'Perfil',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuenoNav(BuildContext context, ColorScheme cs, TextTheme tt) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: _onTabSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: 'Alertas',
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
    );
  }
}
