import 'package:flutter/material.dart';
import 'package:ganajec/features/dueno/domain/entities/dueno_dashboard.dart';
import '../../widgets/ganadero_list_tile.dart';
import 'mis_ganaderos_components.dart';

class MisGanaderosScreen extends StatefulWidget {
  const MisGanaderosScreen({super.key});

  @override
  State<MisGanaderosScreen> createState() => _MisGanaderosScreenState();
}

class _MisGanaderosScreenState extends State<MisGanaderosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<GanaderoResumen> _ganaderos = [
    GanaderoResumen(
      id: '1',
      nombre: 'Juan Perez',
      iniciales: 'JP',
      totalBovinos: 8,
      alertasAltas: 1,
      animalesSanos: 7,
      activoHoy: true,
      ultimaActividad: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    GanaderoResumen(
      id: '2',
      nombre: 'Maria Lopez',
      iniciales: 'ML',
      totalBovinos: 7,
      alertasAltas: 1,
      animalesSanos: 6,
      activoHoy: true,
      ultimaActividad: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    GanaderoResumen(
      id: '3',
      nombre: 'Pedro Ruiz',
      iniciales: 'PR',
      totalBovinos: 9,
      alertasAltas: 0,
      animalesSanos: 8,
      activoHoy: true,
      ultimaActividad: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<GanaderoResumen> get _filtrados => _ganaderos
      .where((g) => g.nombre.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mis ganaderos',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          GanaderoSearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
          ),
          Expanded(
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filtrados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  GanaderoListTile(ganadero: _filtrados[index]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: colors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}
