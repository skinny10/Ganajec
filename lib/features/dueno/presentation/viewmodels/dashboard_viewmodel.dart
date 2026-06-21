import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/features/dueno/data/models/estadisticas_model.dart';

enum DashboardStatus { idle, loading, success, error }

class DashboardViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  DashboardStatus _status = DashboardStatus.idle;
  String? _error;
  EstadisticasModel? _estadisticas;

  DashboardStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == DashboardStatus.loading;
  bool get isEmpty =>
      _status == DashboardStatus.success && _estadisticas == null;
  EstadisticasModel? get estadisticas => _estadisticas;

  Future<void> cargar() async {
    final ranchoId = TokenStorage.ranchoId;
    if (ranchoId == null || ranchoId.isEmpty) {
      _status = DashboardStatus.idle;
      _estadisticas = null;
      notifyListeners();
      return;
    }

    _status = DashboardStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final res = await _dio.get(ApiConstants.estadisticasRancho(ranchoId));
      _estadisticas =
          EstadisticasModel.fromJson(res.data as Map<String, dynamic>);
      _status = DashboardStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al cargar estadísticas';
      _status = DashboardStatus.error;
    } catch (e) {
      _error = e.toString();
      _status = DashboardStatus.error;
    }
    notifyListeners();
  }
}
