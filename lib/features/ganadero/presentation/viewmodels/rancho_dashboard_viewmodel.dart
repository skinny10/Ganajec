import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/features/ganadero/data/models/animal_model.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/mis_ganaderos_viewmodel.dart';
import 'package:ganajec/share/domain/entities/animal.dart';

enum RanchoDashboardStatus { idle, loading, success, error }

class RanchoDashboardViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  /// Se inicializa con el RanchoInfo completo que ya tenemos del perfil.
  /// Así nunca mostramos "—" por un endpoint de detalle con formato distinto.
  RanchoInfo initialRancho;

  RanchoDashboardViewModel({required this.initialRancho});

  RanchoDashboardStatus _status = RanchoDashboardStatus.idle;
  String? _error;
  late RanchoInfo _rancho = initialRancho;
  List<Animal> _bovinos = [];

  RanchoDashboardStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == RanchoDashboardStatus.loading;
  RanchoInfo get rancho => _rancho;
  List<Animal> get bovinos => _bovinos;

  Future<void> cargar() async {
    _status = RanchoDashboardStatus.loading;
    _error = null;
    notifyListeners();

    try {
      // Solo cargamos los bovinos — los datos del rancho vienen del perfil
      final bRes = await _dio.get(
          ApiConstants.bovinosDeRancho(initialRancho.id));
      final raw = bRes.data;
      final list = raw is List ? raw : (raw['bovinos'] as List? ?? []);
      _bovinos = list
          .map((e) => AnimalModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _status = RanchoDashboardStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al cargar bovinos';
      _status = RanchoDashboardStatus.error;
    } catch (e) {
      _error = e.toString();
      _status = RanchoDashboardStatus.error;
    }
    notifyListeners();
  }

  void actualizarRancho(RanchoInfo actualizado) {
    _rancho = actualizado;
    initialRancho = actualizado;
    notifyListeners();
  }
}
