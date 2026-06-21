import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/features/dueno/data/models/estadisticas_model.dart';
import 'package:ganajec/features/ganadero/data/models/animal_model.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/mis_ganaderos_viewmodel.dart';
import 'package:ganajec/share/domain/entities/animal.dart';

enum RanchoDashboardStatus { idle, loading, success, error, unassigned }

class RanchoDashboardViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  RanchoDashboardViewModel();

  RanchoDashboardStatus _status = RanchoDashboardStatus.idle;
  String? _error;
  RanchoInfo? _rancho;
  List<Animal> _bovinos = [];
  EstadisticasModel? _estadisticas;

  RanchoDashboardStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == RanchoDashboardStatus.loading;
  bool get isUnassigned => _status == RanchoDashboardStatus.unassigned;
  RanchoInfo? get rancho => _rancho;
  List<Animal> get bovinos => _bovinos;
  EstadisticasModel? get estadisticas => _estadisticas;

  Future<void> cargar() async {
    String? ranchoId = TokenStorage.ranchoId;

    if (ranchoId == null || ranchoId.isEmpty) {
      final userId = TokenStorage.userId;
      if (userId != null && userId.isNotEmpty) {
        try {
          final res = await _dio.get(ApiConstants.perfilDueno(userId));
          final ranchos = res.data['ranchos'] as List? ?? [];
          if (ranchos.isNotEmpty) {
            final first = ranchos.first as Map<String, dynamic>;
            ranchoId = first['id'] as String?;
            if (ranchoId != null && ranchoId.isNotEmpty) {
              await TokenStorage.saveRanchoId(ranchoId);
            }
          }
        } catch (_) {
          // fall through to unassigned
        }
      }
    }

    if (ranchoId == null || ranchoId.isEmpty) {
      _status = RanchoDashboardStatus.unassigned;
      _rancho = null;
      _bovinos = [];
      _estadisticas = null;
      _error = null;
      notifyListeners();
      return;
    }

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

      // 3. Estadísticas del rancho
      try {
        final eRes =
            await _dio.get(ApiConstants.estadisticasRancho(ranchoId));
        _estadisticas = EstadisticasModel.fromJson(
            eRes.data as Map<String, dynamic>);
      } catch (_) {
        _estadisticas = null;
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
