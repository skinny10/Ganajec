import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';

class GanaderoItem {
  final String id;
  final String nombre;
  final String email;
  final int totalBovinos;

  const GanaderoItem({
    required this.id,
    required this.nombre,
    required this.email,
    required this.totalBovinos,
  });

  factory GanaderoItem.fromJson(Map<String, dynamic> j) => GanaderoItem(
        id: j['id'] as String? ?? '',
        nombre: j['nombre'] as String? ?? 'Sin nombre',
        email: j['email'] as String? ?? '',
        totalBovinos: (j['total_bovinos'] as num?)?.toInt() ??
            (j['bovinos_count'] as num?)?.toInt() ??
            0,
      );
}

class RanchoInfo {
  final String id;
  final String nombre;
  final String municipio;
  final String estado;
  final String codigoInvitacion;

  const RanchoInfo({
    required this.id,
    required this.nombre,
    required this.municipio,
    required this.estado,
    required this.codigoInvitacion,
  });

  factory RanchoInfo.fromJson(Map<String, dynamic> j) => RanchoInfo(
        id: j['id'] as String? ?? '',
        nombre: j['nombre'] as String? ?? '—',
        municipio: j['municipio'] as String? ?? '—',
        estado: j['estado'] as String? ?? '—',
        codigoInvitacion: j['codigo_invitacion'] as String? ?? '—',
      );
}

enum MisGanaderosStatus { idle, loading, success, error }

class MisGanaderosViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  MisGanaderosStatus _status = MisGanaderosStatus.idle;
  String? _error;
  List<GanaderoItem> _ganaderos = [];
  RanchoInfo? _rancho;

  /// Todos los ranchos del dueño — para el selector "mover a otro rancho"
  List<RanchoInfo> _otrosRanchos = [];

  MisGanaderosStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == MisGanaderosStatus.loading;
  List<GanaderoItem> get ganaderos => _ganaderos;
  RanchoInfo? get rancho => _rancho;

  /// Ranchos disponibles como destino al mover (excluye el actual)
  List<RanchoInfo> get otrosRanchos => _otrosRanchos;

  Future<void> cargar() async {
    _status = MisGanaderosStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final ranchoId = TokenStorage.ranchoId ?? '';
      final uid = TokenStorage.userId ?? '';

      // 1. Perfil para obtener datos del rancho actual.
      //    Si el usuario es dueño usamos GET /dueno/{id}; si es ganadero, GET /ganadero/{id}
      final role = TokenStorage.role ?? 'ganadero';
      final perfilEndpoint = role == 'dueno'
          ? ApiConstants.perfilDueno(uid)
          : ApiConstants.perfilGanadero(uid);
      final perfilRes = await _dio.get(perfilEndpoint);
      final ranchosEnPerfil = perfilRes.data['ranchos'] as List?;
      if (ranchosEnPerfil != null && ranchosEnPerfil.isNotEmpty) {
        final rData = ranchoId.isNotEmpty
            ? (ranchosEnPerfil.firstWhere(
                (r) => r['id'] == ranchoId,
                orElse: () => ranchosEnPerfil.first,
              ) as Map<String, dynamic>)
            : (ranchosEnPerfil.first as Map<String, dynamic>);
        _rancho = RanchoInfo.fromJson(rData);
      }

      // 2. Lista completa de ranchos del dueño → GET /dueno/{id}/ranchos
      //    Usamos try separado para que no falle toda la carga si el endpoint no está disponible.
      try {
        final ranchosRes =
            await _dio.get(ApiConstants.ranchosDueno(uid));
        final rawR = ranchosRes.data;
        final listaR =
            rawR is List ? rawR : (rawR['ranchos'] as List? ?? []);
        final todos = listaR
            .map((e) => RanchoInfo.fromJson(e as Map<String, dynamic>))
            .toList();
        // Excluimos el rancho actual del selector de destino
        _otrosRanchos = todos
            .where((r) => r.id != (_rancho?.id ?? ranchoId))
            .toList();
      } catch (_) {
        // El endpoint puede no existir en todas las versiones del servidor
        _otrosRanchos = [];
      }

      // 3. Ganaderos del rancho actual → GET /dueno/ranchos/{id}/ganaderos
      final actualRanchoId = _rancho?.id ?? ranchoId;
      if (actualRanchoId.isNotEmpty) {
        final ganaderosRes =
            await _dio.get(ApiConstants.ganaderosDeRancho(actualRanchoId));
        final raw = ganaderosRes.data;
        final list = raw is List ? raw : (raw['ganaderos'] as List? ?? []);
        _ganaderos = list
            .map((e) => GanaderoItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      _status = MisGanaderosStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al cargar ganaderos';
      _status = MisGanaderosStatus.error;
    } catch (e) {
      _error = e.toString();
      _status = MisGanaderosStatus.error;
    }
    notifyListeners();
  }

  Future<bool> eliminarGanadero(String ganaderoId) async {
    final ranchoId = _rancho?.id ?? TokenStorage.ranchoId ?? '';
    try {
      await _dio.delete(ApiConstants.ganaderoEnRancho(ranchoId, ganaderoId));
      _ganaderos.removeWhere((g) => g.id == ganaderoId);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'No se pudo eliminar';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Mover ganadero a otro rancho: PATCH /dueno/ranchos/{rancho_id}/ganaderos/{ganadero_id}
  Future<bool> moverGanadero(String ganaderoId, String nuevoRanchoId) async {
    final ranchoId = _rancho?.id ?? TokenStorage.ranchoId ?? '';
    try {
      await _dio.patch(
        ApiConstants.ganaderoEnRancho(ranchoId, ganaderoId),
        data: {'nuevo_rancho_id': nuevoRanchoId},
      );
      _ganaderos.removeWhere((g) => g.id == ganaderoId);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'No se pudo mover';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
