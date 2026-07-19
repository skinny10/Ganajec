import 'package:flutter/material.dart';
import 'package:ganajec/features/admin/data/datasource/admin_remote_ds.dart';
import 'package:ganajec/features/admin/domain/entities/admin_sistema_estado.dart';

enum AdminDashboardStatus { idle, loading, success, error }

class AdminDashboardViewModel extends ChangeNotifier {
  final AdminRemoteDataSource _ds = AdminRemoteDataSource();

  AdminDashboardStatus _status = AdminDashboardStatus.idle;
  String? _error;
  SistemaEstado? _estado;

  AdminDashboardStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == AdminDashboardStatus.loading;
  SistemaEstado? get estado => _estado;

  Future<void> cargar() async {
    _status = AdminDashboardStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _estado = await _ds.getEstadoSistema();
      _status = AdminDashboardStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = AdminDashboardStatus.error;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
