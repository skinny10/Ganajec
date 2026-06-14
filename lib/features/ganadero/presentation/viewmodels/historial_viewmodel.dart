import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/historial_item.dart';
import 'package:ganajec/features/ganadero/domain/usecase/get_historial_ganadero_usecase.dart';

enum HistorialStatus { idle, loading, loaded, error }

enum HistorialFiltroTipo { todos, alta, moderada, leve }

class HistorialGrupo {
  final String titulo;
  final List<HistorialItem> items;
  const HistorialGrupo({required this.titulo, required this.items});
}

class HistorialViewModel extends ChangeNotifier {
  final GetHistorialGanaderoUseCase _getHistorial;

  HistorialViewModel({required GetHistorialGanaderoUseCase getHistorial})
      : _getHistorial = getHistorial;

  HistorialStatus _status = HistorialStatus.idle;
  List<HistorialItem> _allItems = [];
  HistorialFiltroTipo _filtroTipo = HistorialFiltroTipo.todos;
  String? _animalFiltro; // null = todos
  String _busqueda = '';
  String? _error;

  // ── Getters públicos ─────────────────────────────────────────────────────

  HistorialStatus get status => _status;
  bool get isLoading => _status == HistorialStatus.loading;
  String? get error => _error;
  HistorialFiltroTipo get filtroTipo => _filtroTipo;
  String? get animalFiltro => _animalFiltro;
  String get busqueda => _busqueda;

  /// Quick stats (sobre TODOS los items, sin filtrar)
  int get countAlta =>
      _allItems.where((i) => i.severidad == HistorialSeveridad.alta).length;

  int get countMes {
    final now = DateTime.now();
    return _allItems
        .where((i) => i.fecha.year == now.year && i.fecha.month == now.month)
        .length;
  }

  int get countSinEnfermedad =>
      _allItems.where((i) => i.esSinEnfermedad).length;

  /// Nombres únicos de animales para los chips de filtro
  List<String> get animalesDisponibles {
    final nombres = _allItems.map((i) => i.animalNombre).toSet().toList();
    nombres.sort();
    return nombres;
  }

  /// Lista filtrada y agrupada por fecha
  List<HistorialGrupo> get grupos {
    final filtered = _applyFilters();
    return _agrupar(filtered);
  }

  bool get isEmpty => _applyFilters().isEmpty;

  // ── Acciones ──────────────────────────────────────────────────────────────

  Future<void> cargar() async {
    _status = HistorialStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _allItems = await _getHistorial();
      _status = HistorialStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = HistorialStatus.error;
    }
    notifyListeners();
  }

  void setBusqueda(String q) {
    if (_busqueda == q) return;
    _busqueda = q;
    notifyListeners();
  }

  void setFiltroTipo(HistorialFiltroTipo tipo) {
    _filtroTipo = tipo;
    _animalFiltro = null; // mutuamente exclusivos
    notifyListeners();
  }

  void setAnimalFiltro(String nombre) {
    if (_animalFiltro == nombre) {
      // toggle off
      _animalFiltro = null;
      _filtroTipo = HistorialFiltroTipo.todos;
    } else {
      _animalFiltro = nombre;
      _filtroTipo = HistorialFiltroTipo.todos;
    }
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroTipo = HistorialFiltroTipo.todos;
    _animalFiltro = null;
    _busqueda = '';
    notifyListeners();
  }

  // ── Helpers privados ──────────────────────────────────────────────────────

  List<HistorialItem> _applyFilters() {
    return _allItems.where((item) {
      // Filtro por tipo de severidad
      final matchTipo = switch (_filtroTipo) {
        HistorialFiltroTipo.todos => true,
        HistorialFiltroTipo.alta => item.severidad == HistorialSeveridad.alta,
        HistorialFiltroTipo.moderada =>
          item.severidad == HistorialSeveridad.moderada,
        HistorialFiltroTipo.leve =>
          item.severidad == HistorialSeveridad.leve ||
              item.severidad == HistorialSeveridad.sinEnfermedad,
      };

      // Filtro por animal
      final matchAnimal =
          _animalFiltro == null || item.animalNombre == _animalFiltro;

      // Filtro por búsqueda de texto
      final q = _busqueda.toLowerCase().trim();
      final matchSearch = q.isEmpty ||
          item.animalNombre.toLowerCase().contains(q) ||
          item.enfermedad.toLowerCase().contains(q) ||
          item.animalIdExterno.toLowerCase().contains(q);

      return matchTipo && matchAnimal && matchSearch;
    }).toList();
  }

  List<HistorialGrupo> _agrupar(List<HistorialItem> items) {
    if (items.isEmpty) return [];

    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final ayer = hoy.subtract(const Duration(days: 1));
    final haceSieteDias = hoy.subtract(const Duration(days: 7));

    final Map<String, List<HistorialItem>> buckets = {};

    for (final item in items) {
      final d = DateTime(item.fecha.year, item.fecha.month, item.fecha.day);
      final String key;

      if (!d.isBefore(hoy)) {
        key = 'Hoy';
      } else if (!d.isBefore(ayer)) {
        key = 'Ayer';
      } else if (d.isAfter(haceSieteDias)) {
        key = 'Esta semana';
      } else {
        // "Enero 2026", "Diciembre 2025", etc.
        key = '${_mesNombre(item.fecha.month)} ${item.fecha.year}';
      }

      buckets.putIfAbsent(key, () => []).add(item);
    }

    // Ordenar grupos: Hoy → Ayer → Esta semana → mes más reciente primero
    const orden = ['Hoy', 'Ayer', 'Esta semana'];
    final grupos = <HistorialGrupo>[];

    for (final label in orden) {
      if (buckets.containsKey(label)) {
        grupos.add(HistorialGrupo(titulo: label, items: buckets[label]!));
      }
    }

    // Meses restantes ordenados por fecha descendente
    final mesKeys = buckets.keys
        .where((k) => !orden.contains(k))
        .toList()
      ..sort((a, b) {
        final aItem = buckets[a]!.first;
        final bItem = buckets[b]!.first;
        return bItem.fecha.compareTo(aItem.fecha);
      });

    for (final key in mesKeys) {
      grupos.add(HistorialGrupo(titulo: key, items: buckets[key]!));
    }

    return grupos;
  }

  static const _meses = [
    '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  String _mesNombre(int mes) => _meses[mes];
}
