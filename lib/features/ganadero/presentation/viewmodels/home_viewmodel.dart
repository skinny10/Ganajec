import 'package:flutter/material.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/alerta.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import '../../domain/usecase/get_animales_usecase.dart';
import '../../domain/usecase/get_alertas_usecase.dart';
import '../../domain/usecase/get_predicciones_usecase.dart';

enum HomeStatus { idle, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  final GetAnimalesUseCase _getAnimales;
  final GetAlertasUseCase _getAlertas;
  final GetPredicionesUseCase _getPredicciones;

  HomeViewModel({
    required GetAnimalesUseCase getAnimales,
    required GetAlertasUseCase getAlertas,
    required GetPredicionesUseCase getPredicciones,
  })  : _getAnimales = getAnimales,
        _getAlertas = getAlertas,
        _getPredicciones = getPredicciones;

  HomeStatus _status = HomeStatus.idle;
  List<Animal> _animales = [];
  List<Alerta> _alertas = [];
  List<Prediccion> _predicciones = [];
  Map<String, int> _resumen = {};
  String? _errorMessage;

  HomeStatus get status => _status;
  List<Animal> get animales => _animales;
  List<Alerta> get alertas => _alertas;
  List<Prediccion> get predicciones => _predicciones;
  Map<String, int> get resumen => _resumen;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == HomeStatus.loading;
  bool get hasError => _status == HomeStatus.error;

  /// Nombre real del usuario desde TokenStorage.
  String get userName => TokenStorage.userName ?? 'Usuario';

  /// Iniciales para el avatar (ej. "Juan Pérez" → "JP").
  String get userInitials {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Saludo según la hora del día.
  String get saludo {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días,';
    if (h < 18) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  Future<void> cargarDatos() async {
    _setStatus(HomeStatus.loading);
    _errorMessage = null;
    try {
      // Cargamos animales y predicciones de la API real;
      // alertas sigue en mock hasta que se conecten.
      final results = await Future.wait([
        _getAnimales(),
        _getAlertas(),
        _getPredicciones(),
      ]);
      _animales = results[0] as List<Animal>;
      _alertas = results[1] as List<Alerta>;
      _predicciones = results[2] as List<Prediccion>;
      _resumen = {
        'total': _animales.length,
        'en_buen_estado': _animales.where((a) => true).length,
        'con_alertas': _alertas.where((a) => !a.leida).length,
      };
      _setStatus(HomeStatus.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(HomeStatus.error);
    }
  }

  void _setStatus(HomeStatus status) {
    _status = status;
    notifyListeners();
  }
}
