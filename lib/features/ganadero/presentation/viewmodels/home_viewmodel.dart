import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
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
  final Dio _dio = ApiClient.instance;

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

  String get userName => TokenStorage.userName ?? 'Usuario';

  String get userInitials {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get saludo {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días,';
    if (h < 18) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  void reset() {
    debugPrint('🔴 HomeViewModel.reset() llamado');
    _animales = [];
    _alertas = [];
    _predicciones = [];
    _resumen = {};
    _errorMessage = null;
    _status = HomeStatus.idle;
    notifyListeners();
  }

  Future<void> cargarDatos() async {
    reset();
    debugPrint('🟡 HomeViewModel.cargarDatos() iniciando');
    _setStatus(HomeStatus.loading);
    _errorMessage = null;
    try {
      if (TokenStorage.role == 'dueno') {
        await _cargarDueno();
      } else {
        await _cargarGanadero();
      }
      _setStatus(HomeStatus.success);
      debugPrint('🟢 HomeViewModel.cargarDatos() completado - animales: ${_animales.length}');
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(HomeStatus.error);
    }
  }

  // ── Ganadero: usa los use cases existentes ────────────────────────────────
  Future<void> _cargarGanadero() async {
    final results = await Future.wait([
      _getAnimales(),
      _getAlertas(),
      _getPredicciones(),
    ]);
    _animales     = results[0] as List<Animal>;
    _alertas      = results[1] as List<Alerta>;
    _predicciones = results[2] as List<Prediccion>;
    _resumen = {
      'total':         _animales.length,
      'en_buen_estado': _animales.length,
      'con_alertas':   _alertas.where((a) => !a.leida).length,
    };
  }

  // ── Dueño: endpoints globales de la API ───────────────────────────────────
  Future<void> _cargarDueno() async {
    final results = await Future.wait([
      _dio.get(ApiConstants.bovinosDueno),
      _dio.get(ApiConstants.prediccionesDueno),
    ]);

    // Bovinos
    final bovinosData  = results[0].data as Map<String, dynamic>;
    final totalBovinos = (bovinosData['total_bovinos'] as num?)?.toInt() ?? 0;
    final rawBovinos   = bovinosData['bovinos'] as List? ?? [];
    _animales = rawBovinos
        .map((b) => _animalDesdeDueno(b as Map<String, dynamic>))
        .toList();

    // Predicciones (solo las 5 más recientes en home)
    final predsData = results[1].data as Map<String, dynamic>;
    final rawPreds  = predsData['predicciones'] as List? ?? [];
    _predicciones = rawPreds
        .take(5)
        .map((p) => _prediccionDesdeDueno(p as Map<String, dynamic>))
        .toList();

    _alertas = [];
    final conAlertas = _predicciones
        .where((p) => p.severidad == 'alta' || p.severidad == 'media')
        .length;
    _resumen = {
      'total':          totalBovinos,
      'en_buen_estado': totalBovinos - conAlertas,
      'con_alertas':    conAlertas,
    };
  }

  // ── Parsers ───────────────────────────────────────────────────────────────
  Animal _animalDesdeDueno(Map<String, dynamic> j) => Animal(
        id:              j['id']             as String? ?? '',
        ranchoId:        j['rancho_id']      as String? ?? '',
        ganaderoId:      j['ganadero_id']    as String? ?? '',
        nombre:          j['nombre']         as String? ?? '',
        raza:            j['raza']           as String? ?? '',
        sexo:            j['sexo']           as String? ?? '',
        categoria:       j['categoria']      as String? ?? '',
        proposito:       j['proposito']      as String? ?? '',
        fechaNacimiento: DateTime.tryParse(
                             j['fecha_nacimiento'] as String? ?? '') ??
                         DateTime(2020),
        pesoKg:          (j['peso_kg'] as num?)?.toDouble() ?? 0,
        idExterno:       j['id_externo']     as String? ?? '',
        creadoEn:        DateTime.tryParse(
                             j['creado_en'] as String? ?? '') ??
                         DateTime.now(),
        ranchoNombre:    j['rancho_nombre']  as String? ?? '',
        ganaderoNombre:  j['ganadero_nombre'] as String? ?? '',
      );

  Prediccion _prediccionDesdeDueno(Map<String, dynamic> j) => Prediccion(
        id:              j['id']                  as String? ?? '',
        animalId:        j['bovino_id']           as String? ?? '',
        animalNombre:    j['bovino_nombre']        as String? ?? '',
        animalIdExterno: j['bovino_id_externo']   as String? ?? '',
        enfermedad:      j['enfermedad']           as String? ?? '',
        confianza:       (j['confianza'] as num?)?.toDouble() ?? 0,
        fecha:           DateTime.tryParse(
                             j['generado_en'] as String? ?? '') ??
                         DateTime.now(),
        ranchoNombre:    j['rancho_nombre']        as String? ?? '',
        ganaderoNombre:  j['ganadero_nombre']      as String? ?? '',
        severidad:       j['severidad']            as String? ?? '',
      );

  void _setStatus(HomeStatus status) {
    _status = status;
    notifyListeners();
  }
}
