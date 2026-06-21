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
  final String ranchoId;

  RanchoDashboardViewModel({required this.ranchoId});

  RanchoDashboardStatus _status = RanchoDashboardStatus.idle;
  String? _error;
  RanchoInfo? _rancho;
  List<Animal> _bovinos = [];

  RanchoDashboardStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == RanchoDashboardStatus.loading;
  RanchoInfo? get rancho => _rancho;
  List<Animal> get bovinos => _bovinos;

  Future<void> cargar() async {
    _status = RanchoDashboardStatus.loading;
    _error = null;
    notifyListeners();

    try {
      // 1. Detalle del rancho
      final rRes = await _dio.get(ApiConstants.ranchoDetalle(ranchoId));
      _rancho = RanchoInfo.fromJson(rRes.data as Map<String, dynamic>);

      // 2. Bovinos del rancho
      try {
        final bRes =
            await _dio.get(ApiConstants.bovinosDeRancho(ranchoId));
        final raw = bRes.data;
        final list =
            raw is List ? raw : (raw['bovinos'] as List? ?? []);
        _bovinos = list
            .map((e) => AnimalModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _bovinos = [];
      }

      _status = RanchoDashboardStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al cargar el rancho';
      _status = RanchoDashboardStatus.error;
    } catch (e) {
      _error = e.toString();
      _status = RanchoDashboardStatus.error;
    }
    notifyListeners();
  }

  void actualizarRancho(RanchoInfo actualizado) {
    _rancho = actualizado;
    notifyListeners();
  }
}
