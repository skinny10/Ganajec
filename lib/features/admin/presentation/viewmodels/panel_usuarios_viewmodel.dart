import 'package:flutter/material.dart';
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
      _usuarios = [
        const Usuario(id: '1', nombre: 'Juan Perez', email: 'juanperez@gmail.com', rol: RolUsuario.ganadero, estado: EstadoUsuario.activo),
        const Usuario(id: '2', nombre: 'Maria Lopez', email: 'Mariaperez@gmail.com', rol: RolUsuario.ganadero, estado: EstadoUsuario.activo),
        const Usuario(id: '3', nombre: 'Samuel', email: 'Samuelperez@gmail.com', rol: RolUsuario.ganadero, estado: EstadoUsuario.inactivo),
        const Usuario(id: '4', nombre: 'Carlos Mendoza', email: 'carlos@gmail.com', rol: RolUsuario.dueno, estado: EstadoUsuario.activo),
        const Usuario(id: '5', nombre: 'Ana Martinez', email: 'ana@gmail.com', rol: RolUsuario.veterinario, estado: EstadoUsuario.activo),
      ];
      _stats = const UsuarioStats(
        totalUsuarios: 25,
        totalGanaderos: 14,
        totalDuenos: 14,
        totalVeterinarios: 14,
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
