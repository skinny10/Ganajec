import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/historial_productivo.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import '../../domain/usecase/get_historial_animal_usecase.dart';
import '../../domain/usecase/get_predicciones_animal_usecase.dart';

enum DetalleBovinoStatus { idle, loading, success, error }

class DetalleBovinoViewModel extends ChangeNotifier {
  final GetHistorialAnimalUseCase _getHistorialAnimal;
  final GetPrediccionesAnimalUseCase _getPrediccionesAnimal;

  DetalleBovinoViewModel({
    required GetHistorialAnimalUseCase getHistorialAnimal,
    required GetPrediccionesAnimalUseCase getPrediccionesAnimal,
  })  : _getHistorialAnimal = getHistorialAnimal,
        _getPrediccionesAnimal = getPrediccionesAnimal;

  DetalleBovinoStatus _status = DetalleBovinoStatus.idle;
  List<HistorialProductivo> _historial = [];
  List<Prediccion> _predicciones = [];
  String? _errorMessage;

  DetalleBovinoStatus get status => _status;
  List<HistorialProductivo> get historial => _historial;
  List<Prediccion> get predicciones => _predicciones;
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
      _setStatus(DetalleBovinoStatus.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(DetalleBovinoStatus.error);
    }
  }

  void _setStatus(DetalleBovinoStatus s) {
    _status = s;
    notifyListeners();
  }
}
