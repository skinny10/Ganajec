import 'package:flutter/material.dart';
import 'package:ganajec/features/admin/data/datasource/admin_remote_ds.dart';
import 'package:ganajec/features/admin/domain/entities/admin_sistema_estado.dart';
import 'package:ganajec/features/admin/domain/entities/admin_usuario.dart';

enum AdminDashboardStatus { idle, loading, success, error }

class AdminDashboardViewModel extends ChangeNotifier {
  final AdminRemoteDataSource _ds = AdminRemoteDataSource();

  AdminDashboardStatus _status = AdminDashboardStatus.idle;
  String? _error;
  SistemaEstado? _estado;
  int _totalGanaderos = 0;
  int _totalDuenos = 0;
  int _totalAdmins = 0;

  AdminDashboardStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == AdminDashboardStatus.loading;
  SistemaEstado? get estado => _estado;
  int get totalGanaderos => _totalGanaderos;
  int get totalDuenos => _totalDuenos;
  int get totalAdmins => _totalAdmins;

  Future<void> cargar() async {
    _status = AdminDashboardStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _ds.getEstadoSistema(),
        _ds.getUsuarios(),
      ]);

      _estado = results[0] as SistemaEstado;
      final usuarios = (results[1] as List<AdminUsuario>?) ?? [];

      _totalGanaderos = usuarios.where((u) => u.rol == 'ganadero').length;
      _totalDuenos = usuarios.where((u) => u.rol == 'dueno').length;
      _totalAdmins = usuarios.where((u) => u.rol == 'admin').length;

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
