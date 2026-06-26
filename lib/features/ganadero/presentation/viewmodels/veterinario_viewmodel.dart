import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';

// ── Entidad ──────────────────────────────────────────────────────────────────

class VetRanchoRef {
  final String id;
  final String nombre;
  const VetRanchoRef({required this.id, required this.nombre});
  factory VetRanchoRef.fromJson(Map<String, dynamic> j) => VetRanchoRef(
        id: j['id'] as String? ?? '',
        nombre: j['nombre'] as String? ?? '—',
      );
}

class VeterinarioInfo {
  final String id;
  final String nombre;
  final String telefono;
  final String ubicacion;
  final String lugar;
  final String? notas;
  final List<VetRanchoRef> ranchos;

  const VeterinarioInfo({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.ubicacion,
    required this.lugar,
    this.notas,
    this.ranchos = const [],
  });

  factory VeterinarioInfo.fromJson(Map<String, dynamic> j) => VeterinarioInfo(
        id: j['id'] as String? ?? '',
        nombre: j['nombre'] as String? ?? '—',
        telefono: j['telefono'] as String? ?? '—',
        ubicacion: j['ubicacion'] as String? ?? '',
        lugar: j['lugar'] as String? ?? '',
        notas: j['notas'] as String?,
        ranchos: (j['ranchos'] as List? ?? [])
            .map((r) => VetRanchoRef.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}

// ── ViewModel ────────────────────────────────────────────────────────────────

enum VeterinarioStatus { idle, loading, success, error }

class VeterinarioViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  VeterinarioStatus _status = VeterinarioStatus.idle;
  String? _error;
  List<VeterinarioInfo> _vets = [];
  List<VetRanchoRef> _ranchosDisponibles = [];
  bool _guardando = false;

  VeterinarioStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == VeterinarioStatus.loading;
  bool get guardando => _guardando;
  List<VeterinarioInfo> get vets => _vets;
  List<VetRanchoRef> get ranchosDisponibles => _ranchosDisponibles;

  // ── Cargar todos los veterinarios del dueño (incluye ranchos por vet) ────

  Future<void> cargar({String? ranchoIdOverride}) async {
    _status = VeterinarioStatus.loading;
    _error = null;
    notifyListeners();

    try {
      // Cargar ranchos disponibles para el dropdown de creación
      await _cargarRanchos();

      // GET /dueno/veterinarios — devuelve todos los vets con sus ranchos asociados
      final res = await _dio.get(ApiConstants.listarVeterinarios);
      final data = res.data;
      final lista = data is Map
          ? (data['veterinarios'] as List? ?? [])
          : (data as List? ?? []);
      _vets = lista
          .map((e) => VeterinarioInfo.fromJson(e as Map<String, dynamic>))
          .toList();
      _status = VeterinarioStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al cargar veterinarios';
      _status = VeterinarioStatus.error;
      _vets = [];
    } catch (e) {
      _error = e.toString();
      _status = VeterinarioStatus.error;
      _vets = [];
    }
    notifyListeners();
  }

  Future<void> _cargarRanchos() async {
    final uid = TokenStorage.userId ?? '';
    if (uid.isEmpty) return;
    try {
      final res = await _dio.get(ApiConstants.perfilDueno(uid));
      final raw = res.data['ranchos'] as List? ?? [];
      _ranchosDisponibles = raw
          .map((r) => VetRanchoRef.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  // ── Crear veterinario y asociarlo al rancho ───────────────────────────────

  Future<String?> crear({
    required String nombre,
    required String telefono,
    required String ubicacion,
    required String lugar,
    String? notas,
    String? ranchoId,
  }) async {
    final rid = ranchoId ?? TokenStorage.ranchoId ?? '';
    _guardando = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Crear el vet
      final createRes = await _dio.post(
        ApiConstants.crearVeterinario,
        data: {
          'nombre': nombre,
          'telefono': telefono,
          'ubicacion': ubicacion,
          'lugar': lugar,
          if (notas != null && notas.isNotEmpty) 'notas': notas,
        },
      );
      final vetId = createRes.data['id'] as String? ?? '';

      // 2. Asociar al rancho seleccionado
      if (rid.isNotEmpty && vetId.isNotEmpty) {
        await _dio.post(ApiConstants.asociarVeterinario(rid, vetId));
      }

      // 3. Recargar lista completa con ranchos
      await cargar();
      _guardando = false;
      notifyListeners();
      return null;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al crear veterinario';
      _guardando = false;
      notifyListeners();
      return _error;
    } catch (e) {
      _error = e.toString();
      _guardando = false;
      notifyListeners();
      return _error;
    }
  }

  // ── Editar veterinario ────────────────────────────────────────────────────

  Future<String?> editar(
    String vetId, {
    required String nombre,
    required String telefono,
    required String ubicacion,
    required String lugar,
    String? notas,
  }) async {
    _guardando = true;
    _error = null;
    notifyListeners();

    try {
      await _dio.put(
        ApiConstants.veterinario(vetId),
        data: {
          'nombre': nombre,
          'telefono': telefono,
          'ubicacion': ubicacion,
          'lugar': lugar,
          'notas': notas,
        },
      );
      await cargar();
      _guardando = false;
      notifyListeners();
      return null;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al editar veterinario';
      _guardando = false;
      notifyListeners();
      return _error;
    } catch (e) {
      _error = e.toString();
      _guardando = false;
      notifyListeners();
      return _error;
    }
  }

  // ── Eliminar veterinario completamente ────────────────────────────────────

  Future<String?> eliminar(String vetId) async {
    _guardando = true;
    _error = null;
    notifyListeners();

    try {
      await _dio.delete(ApiConstants.veterinario(vetId));
      _vets.removeWhere((v) => v.id == vetId);
      _guardando = false;
      notifyListeners();
      return null;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al eliminar veterinario';
      _guardando = false;
      notifyListeners();
      return _error;
    } catch (e) {
      _error = e.toString();
      _guardando = false;
      notifyListeners();
      return _error;
    }
  }

  // ── Listar todos los veterinarios del dueño (para asociar existente) ─────────

  Future<List<VeterinarioInfo>> listarTodos() async {
    try {
      final res = await _dio.get(ApiConstants.listarVeterinarios);
      final data = res.data;
      final lista = data is Map
          ? (data['veterinarios'] as List? ?? [])
          : (data as List? ?? []);
      return lista
          .map((e) => VeterinarioInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Asociar veterinario ya existente al rancho actual ─────────────────────────

  Future<String?> asociarExistente(String vetId) async {
    final ranchoId = TokenStorage.ranchoId ?? '';
    if (ranchoId.isEmpty) return 'No hay rancho activo';

    _guardando = true;
    _error = null;
    notifyListeners();

    try {
      await _dio.post(ApiConstants.asociarVeterinario(ranchoId, vetId));
      await cargar();
      _guardando = false;
      notifyListeners();
      return null;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al asociar veterinario';
      _guardando = false;
      notifyListeners();
      return _error;
    } catch (e) {
      _error = e.toString();
      _guardando = false;
      notifyListeners();
      return _error;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
