import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/core/router/app_router.dart';
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
  List<_GanaderoItem> _ganaderos = [];
  bool _isLoading = true;
  String? _error;
  String _codigoInvitacion = '';

  @override
  void initState() {
    super.initState();
    _cargarGanaderos();
    _cargarCodigoInvitacion();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarCodigoInvitacion() async {
    final duenoId = TokenStorage.userId;
    if (duenoId == null || duenoId.isEmpty) return;

    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/dueno/$duenoId');
      final ranchos = res.data['ranchos'] as List?;
      if (ranchos != null && ranchos.isNotEmpty) {
        final codigo = ranchos[0]['codigo_invitacion'] as String?;
        if (codigo != null && codigo.isNotEmpty) {
          setState(() => _codigoInvitacion = codigo);
        }
      }
    } catch (_) {}
  }

  Future<void> _cargarGanaderos() async {
    final ranchoId = TokenStorage.ranchoId;
    if (ranchoId == null || ranchoId.isEmpty) {
      setState(() {
        _error = 'Rancho no identificado. Inicia sesi\u00f3n nuevamente.';
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/dueno/ranchos/$ranchoId/ganaderos');
      final ganaderosList = res.data['ganaderos'] as List;

      setState(() {
        _ganaderos = ganaderosList.map((g) {
          final nombre = g['nombre'] as String;
          final partes = nombre.split(' ');
          final iniciales = partes.length >= 2
              ? '${partes[0][0]}${partes[1][0]}'.toUpperCase()
              : nombre.substring(0, 2).toUpperCase();

          return _GanaderoItem(
            resumen: GanaderoResumen(
              id: g['id'] as String,
              nombre: nombre,
              iniciales: iniciales,
              totalBovinos: 0,
              alertasAltas: 0,
              animalesSanos: 0,
              activoHoy: true,
            ),
            email: g['email'] as String? ?? '',
            moderadas: 0,
          );
        }).toList();
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar ganaderos: $e';
        _isLoading = false;
      });
    }
  }

  List<_GanaderoItem> get _filtrados => _ganaderos
      .where(
          (g) => g.resumen.nombre.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  void _showAddGanaderoSheet() {
    final disponibles = [
      _GanaderoItem(
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
      _GanaderoItem(
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
      _GanaderoItem(
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
          onAgregar: (item) {
            setState(() {
              _ganaderos.add(item);
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
            onPressed: () => context.go(AppRoutes.dashboardDueno),
          ),
        title: const Text(
          'Mis ganaderos',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          if (_codigoInvitacion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4423),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _codigoInvitacion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: _codigoInvitacion));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Código copiado'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.copy_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _buildBody(),
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _cargarGanaderos,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
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
    );
  }
}

class _AddGanaderoSheet extends StatefulWidget {
  final List<_GanaderoItem> disponibles;
  final void Function(_GanaderoItem) onAgregar;

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

class _GanaderoItem {
  final GanaderoResumen resumen;
  final String email;
  final int moderadas;

  const _GanaderoItem({
    required this.resumen,
    required this.email,
    required this.moderadas,
  });
}
