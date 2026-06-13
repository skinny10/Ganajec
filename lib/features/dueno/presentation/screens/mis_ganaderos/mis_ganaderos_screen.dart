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

  List<_GanaderoMock> _ganaderos = [
    _GanaderoMock(
      resumen: GanaderoResumen(
        id: '1',
        nombre: 'Juan Perez',
        iniciales: 'JP',
        totalBovinos: 8,
        alertasAltas: 1,
        animalesSanos: 7,
        activoHoy: true,
        ultimaActividad: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      email: 'juanperez@rancho.com',
      moderadas: 0,
    ),
    _GanaderoMock(
      resumen: GanaderoResumen(
        id: '2',
        nombre: 'Maria Lopez',
        iniciales: 'ML',
        totalBovinos: 7,
        alertasAltas: 1,
        animalesSanos: 6,
        activoHoy: true,
        ultimaActividad: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      email: 'marialopez@rancho.com',
      moderadas: 0,
    ),
    _GanaderoMock(
      resumen: GanaderoResumen(
        id: '3',
        nombre: 'Pedro Ruiz',
        iniciales: 'PR',
        totalBovinos: 9,
        alertasAltas: 0,
        animalesSanos: 8,
        activoHoy: true,
        ultimaActividad: DateTime.now().subtract(const Duration(days: 1)),
      ),
      email: 'pedroruiz@rancho.com',
      moderadas: 1,
    ),
  ];

  List<_GanaderoMock> get _filtrados => _ganaderos
      .where(
          (g) => g.resumen.nombre.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  void _showAddGanaderoSheet() {
    final disponibles = [
      _GanaderoMock(
        resumen: GanaderoResumen(
          id: '4',
          nombre: 'Carlos Hernandez',
          iniciales: 'CH',
          totalBovinos: 0,
          alertasAltas: 0,
          animalesSanos: 0,
          activoHoy: false,
        ),
        email: 'carloshernandez@rancho.com',
        moderadas: 0,
      ),
      _GanaderoMock(
        resumen: GanaderoResumen(
          id: '5',
          nombre: 'Ana Martinez',
          iniciales: 'AM',
          totalBovinos: 0,
          alertasAltas: 0,
          animalesSanos: 0,
          activoHoy: false,
        ),
        email: 'anamartinez@rancho.com',
        moderadas: 0,
      ),
      _GanaderoMock(
        resumen: GanaderoResumen(
          id: '6',
          nombre: 'Luis Garcia',
          iniciales: 'LG',
          totalBovinos: 0,
          alertasAltas: 0,
          animalesSanos: 0,
          activoHoy: false,
        ),
        email: 'luisgarcia@rancho.com',
        moderadas: 0,
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _AddGanaderoSheet(
          disponibles: disponibles,
          onAgregar: (mock) {
            setState(() {
              _ganaderos.add(mock);
            });
            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }

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
              backgroundColor: Colors.black,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                onPressed: _showAddGanaderoSheet,
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
              itemBuilder: (context, index) {
                final g = _filtrados[index];
                return GanaderoListTile(
                  ganadero: g.resumen,
                  email: g.email,
                  moderadas: g.moderadas,
                );
              },
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

class _AddGanaderoSheet extends StatefulWidget {
  final List<_GanaderoMock> disponibles;
  final void Function(_GanaderoMock) onAgregar;

  const _AddGanaderoSheet({
    required this.disponibles,
    required this.onAgregar,
  });

  @override
  State<_AddGanaderoSheet> createState() => _AddGanaderoSheetState();
}

class _AddGanaderoSheetState extends State<_AddGanaderoSheet> {
  int? _selectedIndex;

  Color _colorAvatar(String id) {
    switch (id) {
      case '4':
        return const Color(0xFF2E7D32);
      case '5':
        return const Color(0xFF1976D2);
      case '6':
        return const Color(0xFF6D4C41);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Agregar ganadero',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.disponibles.asMap().entries.map((entry) {
            final i = entry.key;
            final g = entry.value;
            final seleccionado = _selectedIndex == i;

            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: seleccionado
                      ? Colors.grey.shade100
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: seleccionado
                        ? Colors.black
                        : Colors.grey.shade200,
                    width: seleccionado ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _colorAvatar(g.resumen.id),
                      child: Text(
                        g.resumen.iniciales,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.resumen.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          g.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          if (_selectedIndex != null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    widget.onAgregar(widget.disponibles[_selectedIndex!]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Agregar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GanaderoMock {
  final GanaderoResumen resumen;
  final String email;
  final int moderadas;

  const _GanaderoMock({
    required this.resumen,
    required this.email,
    required this.moderadas,
  });
}
