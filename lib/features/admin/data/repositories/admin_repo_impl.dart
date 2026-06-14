import '../../domain/entities/usuario.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_ds.dart';

class AdminRepoImpl implements AdminRepository {
  final AdminRemoteDataSource dataSource;

  AdminRepoImpl(this.dataSource);

  @override
  Future<List<Usuario>> getUsuarios() async {
    return await dataSource.getUsuarios();
  }

  @override
  Future<UsuarioStats> getStats() async {
    return await dataSource.getStats();
  }

  @override
  Future<void> agregarUsuario(Usuario usuario) async {
    // TODO: implementar cuando el backend esté listo
  }
}
