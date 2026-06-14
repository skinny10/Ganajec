import 'package:flutter/material.dart';
import 'package:ganajec/core/network/api_client.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/get_usuarios_usecase.dart';

enum PanelUsuariosState { initial, loading, loaded, error }

class PanelUsuariosViewModel extends ChangeNotifier {
  final GetUsuariosUsecase getUsuariosUsecase;
  final GetStatsUsecase getStatsUsecase;

  PanelUsuariosViewModel({
    required this.getUsuariosUsecase,
    required this.getStatsUsecase,
  });

  PanelUsuariosState _state = PanelUsuariosState.initial;
  List<Usuario> _usuarios = [];
  UsuarioStats? _stats;
  String? _errorMessage;
  RolUsuario? _filtroRol;
  String _query = '';

  PanelUsuariosState get state => _state;
  UsuarioStats? get stats => _stats;
  String? get errorMessage => _errorMessage;
  RolUsuario? get filtroRol => _filtroRol;

  List<Usuario> get usuariosFiltrados {
    return _usuarios.where((u) {
      final coincideRol = _filtroRol == null || u.rol == _filtroRol;
      final coincideQuery = u.nombre.toLowerCase().contains(_query.toLowerCase()) ||
          u.email.toLowerCase().contains(_query.toLowerCase());
      return coincideRol && coincideQuery;
    }).toList();
  }

  Future<void> cargarUsuarios() async {
    _state = PanelUsuariosState.loading;
    notifyListeners();

    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/admin/usuarios');
      final lista = res.data['usuarios'] as List;

      _usuarios = lista.map((json) {
        final rolStr = json['rol'] as String? ?? '';
        final rol = RolUsuario.values.firstWhere(
          (r) => r.name == rolStr,
          orElse: () => RolUsuario.ganadero,
        );
        final activo = json['activo'] as bool? ?? false;
        final estado = activo ? EstadoUsuario.activo : EstadoUsuario.inactivo;

        return Usuario(
          id: json['id'] as String,
          nombre: json['nombre'] as String,
          email: json['email'] as String? ?? '',
          rol: rol,
          estado: estado,
        );
      }).toList();

      _stats = UsuarioStats(
        totalUsuarios: _usuarios.length,
        totalGanaderos:
            _usuarios.where((u) => u.rol == RolUsuario.ganadero).length,
        totalDuenos: _usuarios.where((u) => u.rol == RolUsuario.dueno).length,
        totalVeterinarios:
            _usuarios.where((u) => u.rol == RolUsuario.veterinario).length,
      );
      _state = PanelUsuariosState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = PanelUsuariosState.error;
    }

    notifyListeners();
  }

  void filtrarPorRol(RolUsuario? rol) {
    _filtroRol = rol;
    notifyListeners();
  }

  void buscar(String query) {
    _query = query;
    notifyListeners();
  }
}
