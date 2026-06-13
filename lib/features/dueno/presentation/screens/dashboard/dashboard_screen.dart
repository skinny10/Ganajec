import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/alerta_critica_banner.dart';
import '../../widgets/produccion_leche_card.dart';
import 'dashboard_components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().cargarDashboard('dueno-001');
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.3),
      body: SafeArea(
        child: _buildBody(vm),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody(DashboardViewModel vm) {
    if (vm.state == DashboardState.loading || vm.state == DashboardState.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.state == DashboardState.error) {
      return Center(child: Text('Error: ${vm.errorMessage}'));
    }

    final dashboard = vm.dashboard!;
    final criticos =
        dashboard.casosCriticos.where((c) => c.severidad == 'alta').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(
            nombreDueno: 'Carlos Mendoza',
            nombreRancho: 'Rancho La Esmeralda',
            iniciales: 'CM',
          ),
          const SizedBox(height: 16),
          if (criticos.isNotEmpty)
            AlertaCriticaBanner(
              totalCriticos: criticos.length,
              descripcion: criticos
                  .map((c) => c.nombreAnimal)
                  .take(2)
                  .join(' y '),
              onTap: () {},
            ),
          const SizedBox(height: 16),
          const KpiGrid(),
          const SizedBox(height: 16),
          ProduccionLecheCard(
            litrosHoy: dashboard.produccionLecheHoy,
            porcentajeCambio: dashboard.porcentajeCambioLeche,
          ),
          const SizedBox(height: 20),
          const SeccionCasosCriticos(),
          const SizedBox(height: 20),
          const SeccionGanaderos(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: ''),
        BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      ],
    );
  }
}
