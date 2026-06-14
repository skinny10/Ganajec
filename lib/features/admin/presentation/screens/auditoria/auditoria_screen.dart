import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auditoria_viewmodel.dart';
import '../../widgets/auditoria_timeline_tile.dart';

class AuditoriaScreen extends StatefulWidget {
  const AuditoriaScreen({super.key});

  @override
  State<AuditoriaScreen> createState() => _AuditoriaScreenState();
}

class _AuditoriaScreenState extends State<AuditoriaScreen> {
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditoriaViewModel>().cargarAuditoria();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuditoriaViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      body: SafeArea(
        child: _buildBody(vm),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody(AuditoriaViewModel vm) {
    if (vm.state == AuditoriaState.loading ||
        vm.state == AuditoriaState.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.state == AuditoriaState.error) {
      return const Center(child: Text('Error al cargar auditor\u00eda'));
    }

    final stats = vm.stats!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu, size: 28),
              Icon(Icons.filter_list, size: 28, color: Colors.grey.shade600),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Auditoria de Accesos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Registro de actividades en el sistema',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _kpiCard('${stats.totalAccesos}', 'Totales', Icons.bar_chart),
              const SizedBox(width: 10),
              _kpiCard(stats.periodo, 'Periodo', Icons.calendar_today),
              const SizedBox(width: 10),
              _kpiCard('${stats.usuariosActivos}', 'Usuarios\nactivos', Icons.people_outline),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Actividad reciente',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...vm.registros.asMap().entries.map((entry) {
            final index = entry.key;
            final registro = entry.value;
            return AuditoriaTimelineTile(
              registro: registro,
              isLast: index == vm.registros.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _kpiCard(String valor, String etiqueta, IconData icono) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            Icon(icono, size: 28, color: Colors.grey.shade400),
          ],
        ),
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
        BottomNavigationBarItem(
            icon: Icon(Icons.people_outline), label: 'Usuarios'),
        BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined), label: 'Roles'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined), label: 'Auditor\u00eda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), label: 'Config'),
      ],
    );
  }
}
