import 'package:flutter/material.dart';
import 'package:ganajec/features/admin/data/datasource/admin_remote_ds.dart';
import 'package:ganajec/features/admin/domain/entities/admin_usuario.dart';

enum AdminUsuariosStatus { idle, loading, success, error }

class AdminUsuariosViewModel extends ChangeNotifier {
  final AdminRemoteDataSource _ds = AdminRemoteDataSource();

  AdminUsuariosStatus _status = AdminUsuariosStatus.idle;
  String? _error;
  List<AdminUsuario> _usuarios = [];
  bool _guardando = false;

  AdminUsuariosStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == AdminUsuariosStatus.loading;
  bool get guardando => _guardando;
  List<AdminUsuario> get usuarios => _usuarios;

  Future<void> cargar() async {
    _status = AdminUsuariosStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _usuarios = await _ds.getUsuarios();
      _status = AdminUsuariosStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = AdminUsuariosStatus.error;
      _usuarios = [];
    }
    notifyListeners();
  }

  Future<String?> editarUsuario(
    String id, {
    String? nombre,
    String? email,
    String? rol,
    bool? isActive,
  }) async {
    _guardando = true;
    _error = null;
    notifyListeners();

    try {
      await _ds.editarUsuario(id,
          nombre: nombre, email: email, rol: rol, isActive: isActive);
      await cargar();
      _guardando = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _guardando = false;
      notifyListeners();
      return _error;
    }
  }

  Future<String?> eliminarUsuario(String id) async {
    _guardando = true;
    _error = null;
    notifyListeners();

    try {
      await _ds.eliminarUsuario(id);
      _usuarios.removeWhere((u) => u.id == id);
      _guardando = false;
      notifyListeners();
      return null;
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
