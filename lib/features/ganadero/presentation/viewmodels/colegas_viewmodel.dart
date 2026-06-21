import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';

class ColegaItem {
  final String id;
  final String nombre;

  const ColegaItem({required this.id, required this.nombre});

  factory ColegaItem.fromJson(Map<String, dynamic> j) => ColegaItem(
        id: j['id'] as String? ?? '',
        nombre: j['nombre'] as String? ?? 'Sin nombre',
      );

  /// Iniciales para el avatar (máx 2 letras)
  String get iniciales {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }
}

enum ColegasStatus { idle, loading, success, error }

class ColegasViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;

  ColegasStatus _status = ColegasStatus.idle;
  String? _error;
  List<ColegaItem> _colegas = [];

  ColegasStatus get status => _status;
  bool get isLoading => _status == ColegasStatus.loading;
  String? get error => _error;
  List<ColegaItem> get colegas => _colegas;

  Future<void> cargar() async {
    _status = ColegasStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final res = await _dio.get(ApiConstants.colegasGanadero);
      final raw = res.data;
      final list = raw is List ? raw : (raw['ganaderos'] as List? ?? []);
      _colegas = list
          .map((e) => ColegaItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _status = ColegasStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al cargar colegas';
      _status = ColegasStatus.error;
    } catch (e) {
      _error = e.toString();
      _status = ColegasStatus.error;
    }
    notifyListeners();
  }
}
