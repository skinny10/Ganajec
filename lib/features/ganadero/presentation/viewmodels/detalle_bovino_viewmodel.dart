import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/share/domain/entities/historial_productivo.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import '../../domain/usecase/get_historial_animal_usecase.dart';
import '../../domain/usecase/get_predicciones_animal_usecase.dart';

// ── Modelo de un punto en la gráfica ─────────────────────────────────────────

class GraficaPunto {
  final DateTime fecha;
  final double valor;
  const GraficaPunto({required this.fecha, required this.valor});
}

enum DetalleBovinoStatus { idle, loading, success, error }

class DetalleBovinoViewModel extends ChangeNotifier {
  final GetHistorialAnimalUseCase _getHistorialAnimal;
  final GetPrediccionesAnimalUseCase _getPrediccionesAnimal;
  final Dio _dio = ApiClient.instance;

  DetalleBovinoViewModel({
    required GetHistorialAnimalUseCase getHistorialAnimal,
    required GetPrediccionesAnimalUseCase getPrediccionesAnimal,
  })  : _getHistorialAnimal = getHistorialAnimal,
        _getPrediccionesAnimal = getPrediccionesAnimal;

  DetalleBovinoStatus _status = DetalleBovinoStatus.idle;
  List<HistorialProductivo> _historial = [];
  List<Prediccion> _predicciones = [];
  Map<String, List<GraficaPunto>> _graficas = {};
  String? _errorMessage;

  DetalleBovinoStatus get status => _status;
  List<HistorialProductivo> get historial => _historial;
  List<Prediccion> get predicciones => _predicciones;
  /// Mapa métrica → puntos. Solo incluye métricas con al menos 1 dato.
  Map<String, List<GraficaPunto>> get graficas => _graficas;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == DetalleBovinoStatus.loading;

  /// Litros del registro más reciente
  double get produccionHoy =>
      _historial.isNotEmpty ? _historial.last.litrosLeche : 0.0;

  /// Hay anomalía en el último registro
  bool get tieneAnomaliaActiva =>
      _historial.isNotEmpty && _historial.last.anomaliaDetectada;

  /// Etiqueta de severidad derivada del historial
  String get severidadLabel {
    if (!tieneAnomaliaActiva) return 'Saludable';
    final normales = _historial.where((h) => !h.anomaliaDetectada).toList();
    if (normales.isEmpty) return 'Severidad media';
    final promedio =
        normales.map((h) => h.litrosLeche).reduce((a, b) => a + b) /
            normales.length;
    if (produccionHoy < promedio * 0.5) return 'Severidad alta';
    return 'Severidad media';
  }

  /// ¿El historial tiene al menos un punto anómalo?
  bool get hayAnomaliaEnHistorial =>
      _historial.any((h) => h.anomaliaDetectada);

  Future<void> cargarDatos(String animalId) async {
    _setStatus(DetalleBovinoStatus.loading);
    try {
      final results = await Future.wait([
        _getHistorialAnimal(animalId),
        _getPrediccionesAnimal(animalId),
      ]);
      _historial = results[0] as List<HistorialProductivo>;
      _predicciones = results[1] as List<Prediccion>;
      // Las gráficas se cargan en paralelo pero su fallo no bloquea el resto
      await _cargarGraficas(animalId);
      _setStatus(DetalleBovinoStatus.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(DetalleBovinoStatus.error);
    }
  }

  Future<void> _cargarGraficas(String animalId) async {
    try {
      final res = await _dio.get(ApiConstants.graficasBovino(animalId));
      final data = res.data as Map<String, dynamic>;
      final rawGraficas =
          data['graficas'] as Map<String, dynamic>? ?? {};
      final parsed = <String, List<GraficaPunto>>{};
      rawGraficas.forEach((key, value) {
        final lista = value as List? ?? [];
        if (lista.isEmpty) return; // omite métricas sin datos
        parsed[key] = lista
            .map((p) {
              final map = p as Map<String, dynamic>;
              return GraficaPunto(
                fecha: DateTime.tryParse(
                        map['fecha'] as String? ?? '') ??
                    DateTime.now(),
                valor: (map['valor'] as num?)?.toDouble() ?? 0,
              );
            })
            .toList()
          ..sort((a, b) => a.fecha.compareTo(b.fecha));
      });
      _graficas = parsed;
    } catch (_) {
      _graficas = {};
    }
  }

  void _setStatus(DetalleBovinoStatus s) {
    _status = s;
    notifyListeners();
  }
}
