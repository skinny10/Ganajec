import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/mis_ganaderos_viewmodel.dart';

enum EditarRanchoStatus { idle, loading, success, error }

class EditarRanchoViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient.instance;
  final RanchoInfo ranchoActual;

  EditarRanchoViewModel({required this.ranchoActual}) {
    nombreCtrl.text = ranchoActual.nombre;
    municipioCtrl.text = ranchoActual.municipio;
    estadoCtrl.text = ranchoActual.estado;
  }

  final nombreCtrl = TextEditingController();
  final municipioCtrl = TextEditingController();
  final estadoCtrl = TextEditingController();

  EditarRanchoStatus _status = EditarRanchoStatus.idle;
  String? _error;

  EditarRanchoStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == EditarRanchoStatus.loading;
  bool get isSuccess => _status == EditarRanchoStatus.success;

  Future<void> guardar() async {
    if (nombreCtrl.text.trim().isEmpty) {
      _error = 'El nombre del rancho es obligatorio';
      _status = EditarRanchoStatus.error;
      notifyListeners();
      return;
    }
    _status = EditarRanchoStatus.loading;
    _error = null;
    notifyListeners();
    try {
      await _dio.put(
        ApiConstants.ranchoDetalle(ranchoActual.id),
        data: {
          'nombre': nombreCtrl.text.trim(),
          'municipio': municipioCtrl.text.trim(),
          'estado': estadoCtrl.text.trim(),
        },
      );
      _status = EditarRanchoStatus.success;
    } on DioException catch (e) {
      _error = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Error al actualizar el rancho';
      _status = EditarRanchoStatus.error;
    } catch (e) {
      _error = e.toString();
      _status = EditarRanchoStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    municipioCtrl.dispose();
    estadoCtrl.dispose();
    super.dispose();
  }
}
