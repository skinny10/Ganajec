import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';

enum RanchoModalStatus { idle, loading, success, error }

/// ViewModel compartido para las dos acciones del modal sin rancho:
///   - Unirse a rancho con código de invitación
///   - Crear rancho nuevo (genera código)
class RanchoModalViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  RanchoModalStatus _status = RanchoModalStatus.idle;
  String? _error;
  String? _codigoGenerado; // código que devuelve la API al crear rancho

  RanchoModalStatus get status => _status;
  String? get error => _error;
  String? get codigoGenerado => _codigoGenerado;
  bool get isLoading => _status == RanchoModalStatus.loading;
  bool get isSuccess => _status == RanchoModalStatus.success;

  // Controladores
  final codigoCtrl = TextEditingController();
  final nombreRanchoCtrl = TextEditingController();
  final municipioCtrl = TextEditingController();
  final estadoCtrl = TextEditingController();

  // ── Unirse a rancho ────────────────────────────────────────────────────────
  Future<void> unirse() async {
    final codigo = codigoCtrl.text.trim().toUpperCase();
    if (codigo.isEmpty) {
      _setError('Ingresa el código de invitación');
      return;
    }
    _setLoading();
    try {
      final res = await _dio.post(
        ApiConstants.unirseRancho,
        data: {'codigo_invitacion': codigo},
      );
      // La API devuelve { rancho_id, nombre, ... } o similar
      final data = res.data as Map<String, dynamic>? ?? {};
      final rId = data['rancho_id'] as String? ??
          data['id'] as String? ??
          data['rancho']?['id'] as String? ??
          '';
      if (rId.isNotEmpty) await TokenStorage.saveRanchoId(rId);
      _status = RanchoModalStatus.success;
      notifyListeners();
    } on DioException catch (e) {
      _setError(e.response?.data?['detail']?.toString() ??
          e.message ??
          'Código inválido o ya usado');
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Crear rancho ───────────────────────────────────────────────────────────
  Future<void> crearRancho() async {
    final nombre = nombreRanchoCtrl.text.trim();
    final municipio = municipioCtrl.text.trim();
    final estado = estadoCtrl.text.trim();

    if (nombre.isEmpty || municipio.isEmpty || estado.isEmpty) {
      _setError('Completa todos los campos');
      return;
    }
    _setLoading();
    try {
      final res = await _dio.post(
        ApiConstants.crearRancho,
        data: {
          'nombre': nombre,
          'municipio': municipio,
          'estado': estado,
        },
      );
      final data = res.data as Map<String, dynamic>? ?? {};
      final rId = data['id'] as String? ?? '';
      _codigoGenerado = data['codigo_invitacion'] as String? ?? '';
      if (rId.isNotEmpty) await TokenStorage.saveRanchoId(rId);
      _status = RanchoModalStatus.success;
      notifyListeners();
    } on DioException catch (e) {
      _setError(e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al crear rancho');
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading() {
    _status = RanchoModalStatus.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _status = RanchoModalStatus.error;
    notifyListeners();
  }

  @override
  void dispose() {
    codigoCtrl.dispose();
    nombreRanchoCtrl.dispose();
    municipioCtrl.dispose();
    estadoCtrl.dispose();
    super.dispose();
  }
}
