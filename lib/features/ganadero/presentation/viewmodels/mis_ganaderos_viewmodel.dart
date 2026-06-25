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

  /// Todos los ranchos del dueño.
  List<RanchoInfo> _todosRanchos = [];

  /// Rancho actualmente seleccionado en la pantalla.
  RanchoInfo? _ranchoActivo;

  /// Indica que se están cargando ganaderos de un rancho recién seleccionado.
  bool _cargandoGanaderos = false;

  MisGanaderosStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == MisGanaderosStatus.loading;
  bool get cargandoGanaderos => _cargandoGanaderos;
  List<GanaderoItem> get ganaderos => _ganaderos;
  List<RanchoInfo> get todosRanchos => _todosRanchos;
  RanchoInfo? get ranchoActivo => _ranchoActivo;

  /// Alias para compatibilidad con código existente (p.ej. _RanchoHeaderCard).
  RanchoInfo? get rancho => _ranchoActivo;

  /// Ranchos disponibles como destino al mover (excluye el activo).
  List<RanchoInfo> get otrosRanchos =>
      _todosRanchos.where((r) => r.id != _ranchoActivo?.id).toList();

  // ── Carga inicial ────────────────────────────────────────────────────────────

  Future<void> cargar() async {
    _status = MisGanaderosStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final ranchoId = TokenStorage.ranchoId ?? '';
      final uid = TokenStorage.userId ?? '';
      final role = TokenStorage.role ?? 'ganadero';

      // 1. Perfil → obtener lista de ranchos del dueño.
      final perfilEndpoint = role == 'dueno'
          ? ApiConstants.perfilDueno(uid)
          : ApiConstants.perfilGanadero(uid);
      final perfilRes = await _dio.get(perfilEndpoint);
      final ranchosEnPerfil = perfilRes.data['ranchos'] as List?;

      if (ranchosEnPerfil != null && ranchosEnPerfil.isNotEmpty) {
        _todosRanchos = ranchosEnPerfil
            .map((r) => RanchoInfo.fromJson(r as Map<String, dynamic>))
            .toList();

        // Seleccionar el rancho del token como activo (o el primero).
        _ranchoActivo = ranchoId.isNotEmpty
            ? _todosRanchos.firstWhere(
                (r) => r.id == ranchoId,
                orElse: () => _todosRanchos.first,
              )
            : _todosRanchos.first;
      }

      // 2. Cargar ganaderos del rancho activo.
      if (_ranchoActivo != null) {
        await _cargarGanaderosDeRancho(_ranchoActivo!.id, notificar: false);
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

  // ── Cambiar rancho activo ────────────────────────────────────────────────────

  Future<void> seleccionarRancho(RanchoInfo r) async {
    if (_ranchoActivo?.id == r.id) return;
    _ranchoActivo = r;
    notifyListeners();
    await _cargarGanaderosDeRancho(r.id);
  }

  Future<void> _cargarGanaderosDeRancho(
    String ranchoId, {
    bool notificar = true,
  }) async {
    if (notificar) {
      _cargandoGanaderos = true;
      notifyListeners();
    }
    try {
      final res = await _dio.get(ApiConstants.ganaderosDeRancho(ranchoId));
      final raw = res.data;
      final lista = raw is List ? raw : (raw['ganaderos'] as List? ?? []);
      _ganaderos = lista
          .map((e) => GanaderoItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _ganaderos = [];
    }
    if (notificar) {
      _cargandoGanaderos = false;
      notifyListeners();
    }
  }

  // ── Operaciones sobre ganaderos ──────────────────────────────────────────────

  Future<bool> eliminarGanadero(String ganaderoId) async {
    final ranchoId = _ranchoActivo?.id ?? TokenStorage.ranchoId ?? '';
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

  Future<bool> moverGanadero(String ganaderoId, String nuevoRanchoId) async {
    final ranchoId = _ranchoActivo?.id ?? TokenStorage.ranchoId ?? '';
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
