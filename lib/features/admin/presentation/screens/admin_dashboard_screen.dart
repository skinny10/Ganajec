import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import '../viewmodels/admin_dashboard_viewmodel.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminDashboardViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDashboardViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.go(AppRoutes.home),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.chevron_left_rounded,
                color: cs.onSurface, size: 20),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Panel de administración',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminDashboardViewModel>().cargar(),
            icon: Icon(Icons.refresh_outlined,
                color: cs.onSurfaceVariant, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outlineVariant),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<AdminDashboardViewModel>().cargar(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (vm.estado != null) ...[
                    _MetricasGrid(
                      estado: vm.estado!,
                      totalGanaderos: vm.totalGanaderos,
                      totalDuenos: vm.totalDuenos,
                      totalAdmins: vm.totalAdmins,
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Accesos rápidos',
                    style: tt.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AccesoRapido(
                    icon: Icons.people_outline,
                    titulo: 'Gestionar usuarios',
                    subtitulo: 'Ver, editar y eliminar usuarios',
                    onTap: () => context.push(AppRoutes.adminUsuarios),
                  ),
                  const SizedBox(height: 10),
                  _AccesoRapido(
                    icon: Icons.landscape_outlined,
                    titulo: 'Gestionar ranchos',
                    subtitulo: 'Ver todos los ranchos registrados',
                    onTap: () => context.push(AppRoutes.adminRanchos),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MetricasGrid extends StatelessWidget {
  final dynamic estado;
  final int totalGanaderos;
  final int totalDuenos;
  final int totalAdmins;

  const _MetricasGrid({
    required this.estado,
    required this.totalGanaderos,
    required this.totalDuenos,
    required this.totalAdmins,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final items = [
      _Metrica(
        titulo: 'Usuarios',
        valor: '${estado.totalUsuarios}',
        icono: Icons.people_outline,
        color: cs.primary,
      ),
      _Metrica(
        titulo: 'Activos',
        valor: '${estado.usuariosActivos}',
        icono: Icons.check_circle_outline,
        color: cs.tertiary,
      ),
      _Metrica(
        titulo: 'Ranchos',
        valor: '${estado.totalRanchos}',
        icono: Icons.landscape_outlined,
        color: cs.secondary,
      ),
      _Metrica(
        titulo: 'Bovinos',
        valor: '${estado.totalBovinos}',
        icono: Icons.pets_outlined,
        color: cs.error,
      ),
      _Metrica(
        titulo: 'Ganaderos',
        valor: '$totalGanaderos',
        icono: Icons.agriculture_outlined,
        color: const Color(0xFF6D4C41),
      ),
      _Metrica(
        titulo: 'Dueños',
        valor: '$totalDuenos',
        icono: Icons.business_center_outlined,
        color: const Color(0xFF00796B),
      ),
      _Metrica(
        titulo: 'Admins',
        valor: '$totalAdmins',
        icono: Icons.admin_panel_settings_outlined,
        color: const Color(0xFFC62828),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: items.map((m) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: m.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(m.icono, color: m.color, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.valor,
                    style: tt.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    m.titulo,
                    style: tt.bodySmall?.copyWith(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Metrica {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _Metrica({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });
}

class _AccesoRapido extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _AccesoRapido({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: cs.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: tt.bodySmall?.copyWith(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
