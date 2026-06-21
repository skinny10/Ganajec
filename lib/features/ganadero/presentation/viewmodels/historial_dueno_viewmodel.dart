import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';

// ── Modelos de datos ──────────────────────────────────────────────────────────

class HistDuenoRegistro {
  final String id;
  final String textoLibre;
  final double? temperatura;
  final DateTime registradoEn;
  final String? enfermedad;
  final double? confianza;
  final String? severidad;

  const HistDuenoRegistro({
    required this.id,
    required this.textoLibre,
    this.temperatura,
    required this.registradoEn,
    this.enfermedad,
    this.confianza,
    this.severidad,
  });

  bool get tienePrediccion => enfermedad != null && enfermedad!.isNotEmpty;

  int get confianzaPct => ((confianza ?? 0) * 100).round();

  factory HistDuenoRegistro.fromJson(Map<String, dynamic> j) {
    final pred = j['prediccion'] as Map<String, dynamic>?;
    return HistDuenoRegistro(
      id:           j['id']           as String? ?? '',
      textoLibre:   j['texto_libre']  as String? ?? '',
      temperatura:  (j['temperatura'] as num?)?.toDouble(),
      registradoEn: DateTime.tryParse(j['registrado_en'] as String? ?? '') ??
                    DateTime.now(),
      enfermedad:   pred?['enfermedad']  as String?,
      confianza:    (pred?['confianza'] as num?)?.toDouble(),
      severidad:    pred?['severidad']   as String?,
    );
  }
}

class HistDuenoBovino {
  final String id;
  final String nombre;
  final String categoria;
  final int totalRegistros;
  final List<HistDuenoRegistro> registros;

  const HistDuenoBovino({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.totalRegistros,
    required this.registros,
  });

  factory HistDuenoBovino.fromJson(Map<String, dynamic> j) => HistDuenoBovino(
        id:             j['id']             as String? ?? '',
        nombre:         j['nombre']         as String? ?? '',
        categoria:      j['categoria']      as String? ?? '',
        totalRegistros: (j['total_registros'] as num?)?.toInt() ?? 0,
        registros: (j['registros'] as List? ?? [])
            .map((r) =>
                HistDuenoRegistro.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}

class HistDuenoGanadero {
  final String ganaderoId;
  final String ganaderoNombre;
  final int totalBovinos;
  final List<HistDuenoBovino> bovinos;

  const HistDuenoGanadero({
    required this.ganaderoId,
    required this.ganaderoNombre,
    required this.totalBovinos,
    required this.bovinos,
  });

  factory HistDuenoGanadero.fromJson(Map<String, dynamic> j) =>
      HistDuenoGanadero(
        ganaderoId:     j['ganadero_id']     as String? ?? '',
        ganaderoNombre: j['ganadero_nombre'] as String? ?? '',
        totalBovinos:   (j['total_bovinos'] as num?)?.toInt() ?? 0,
        bovinos: (j['bovinos'] as List? ?? [])
            .map((b) =>
                HistDuenoBovino.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
}

class HistDuenoRancho {
  final String ranchoId;
  final String ranchoNombre;
  final int totalGanaderos;
  final List<HistDuenoGanadero> ganaderos;

  const HistDuenoRancho({
    required this.ranchoId,
    required this.ranchoNombre,
    required this.totalGanaderos,
    required this.ganaderos,
  });

  factory HistDuenoRancho.fromJson(Map<String, dynamic> j) => HistDuenoRancho(
        ranchoId:        j['rancho_id']       as String? ?? '',
        ranchoNombre:    j['rancho_nombre']   as String? ?? '',
        totalGanaderos:  (j['total_ganaderos'] as num?)?.toInt() ?? 0,
        ganaderos: (j['ganaderos'] as List? ?? [])
            .map((g) =>
                HistDuenoGanadero.fromJson(g as Map<String, dynamic>))
            .toList(),
      );
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

enum HistorialDuenoStatus { idle, loading, success, error }

class HistorialDuenoViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  HistorialDuenoStatus _status = HistorialDuenoStatus.idle;
  String? _error;
  List<HistDuenoRancho> _ranchos = [];
  String _busqueda = '';

  HistorialDuenoStatus get status => _status;
  bool get isLoading => _status == HistorialDuenoStatus.loading;
  String? get error => _error;
  String get busqueda => _busqueda;

  List<HistDuenoRancho> get ranchos {
    if (_busqueda.trim().isEmpty) return _ranchos;
    final q = _busqueda.toLowerCase().trim();
    // Filtra hasta nivel bovino/registro según la búsqueda
    return _ranchos
        .map((rancho) => HistDuenoRancho(
              ranchoId: rancho.ranchoId,
              ranchoNombre: rancho.ranchoNombre,
              totalGanaderos: rancho.totalGanaderos,
              ganaderos: rancho.ganaderos
                  .map((g) => HistDuenoGanadero(
                        ganaderoId: g.ganaderoId,
                        ganaderoNombre: g.ganaderoNombre,
                        totalBovinos: g.totalBovinos,
                        bovinos: g.bovinos
                            .where((b) =>
                                b.nombre.toLowerCase().contains(q) ||
                                g.ganaderoNombre.toLowerCase().contains(q) ||
                                rancho.ranchoNombre.toLowerCase().contains(q) ||
                                b.registros.any((r) =>
                                    (r.enfermedad ?? '').toLowerCase().contains(q)))
                            .toList(),
                      ))
                  .where((g) => g.bovinos.isNotEmpty)
                  .toList(),
            ))
        .where((r) => r.ganaderos.isNotEmpty)
        .toList();
  }

  bool get isEmpty => ranchos.every((r) => r.ganaderos.isEmpty);

  // Conteos rápidos sobre datos sin filtrar
  int get totalRegistros => _ranchos
      .expand((r) => r.ganaderos)
      .expand((g) => g.bovinos)
      .fold(0, (sum, b) => sum + b.totalRegistros);

  int get totalAlta => _ranchos
      .expand((r) => r.ganaderos)
      .expand((g) => g.bovinos)
      .expand((b) => b.registros)
      .where((r) => r.severidad == 'alta')
      .length;

  Future<void> cargar() async {
    _status = HistorialDuenoStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final res = await _dio.get(ApiConstants.historialDueno);
      final data = res.data as Map<String, dynamic>;
      final rawRanchos = data['ranchos'] as List? ?? [];
      _ranchos = rawRanchos
          .map((r) => HistDuenoRancho.fromJson(r as Map<String, dynamic>))
          .toList();
      _status = HistorialDuenoStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al cargar historial';
      _status = HistorialDuenoStatus.error;
    } catch (e) {
      _error = e.toString();
      _status = HistorialDuenoStatus.error;
    }
    notifyListeners();
  }

  void setBusqueda(String q) {
    _busqueda = q;
    notifyListeners();
  }
}
