import '../entities/usuario.dart';

abstract class AdminRepository {
  Future<List<Usuario>> getUsuarios();
  Future<UsuarioStats> getStats();
  Future<void> agregarUsuario(Usuario usuario);
}
