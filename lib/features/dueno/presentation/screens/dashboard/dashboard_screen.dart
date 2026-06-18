import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
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
  bool _hasShownCreateDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().cargarDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
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

    if (dashboard.nombreRancho == 'Sin rancho asignado' && !_hasShownCreateDialog) {
      _hasShownCreateDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarDialogoCrearRancho());
    }

    final criticos =
        dashboard.casosCriticos.where((c) => c.severidad == 'alta').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            nombreDueno: dashboard.nombreDueno,
            nombreRancho: dashboard.nombreRancho,
            iniciales: dashboard.nombreDueno.isNotEmpty
                ? dashboard.nombreDueno.split(' ').map((w) => w[0]).take(2).join().toUpperCase()
                : '??',
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

  Future<void> _mostrarDialogoCrearRancho() {
    final nombreCtrl = TextEditingController();
    final municipioCtrl = TextEditingController();
    final estadoCtrl = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Crea tu rancho'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Para comenzar, ingresa los datos de tu rancho'),
            const SizedBox(height: 12),
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                hintText: 'Nombre del rancho',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: municipioCtrl,
              decoration: const InputDecoration(
                hintText: 'Municipio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: estadoCtrl,
              decoration: const InputDecoration(
                hintText: 'Estado',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final municipio = municipioCtrl.text.trim();
              final estado = estadoCtrl.text.trim();
              if (nombre.isEmpty || municipio.isEmpty || estado.isEmpty) return;

              try {
                final dio = ApiClient.instance;
                final res = await dio.post('/dueno/ranchos', data: {
                  'nombre': nombre,
                  'municipio': municipio,
                  'estado': estado,
                });
                final ranchoId = res.data['id'] as String;
                await TokenStorage.saveRanchoId(ranchoId);
                if (ctx.mounted) Navigator.of(ctx).pop();
                context.read<DashboardViewModel>().cargarDashboard();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error al crear rancho: $e')),
                  );
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
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
