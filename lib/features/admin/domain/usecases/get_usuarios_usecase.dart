import '../entities/usuario.dart';
import '../repositories/admin_repository.dart';

class GetUsuariosUsecase {
  final AdminRepository repository;

  GetUsuariosUsecase(this.repository);

  Future<List<Usuario>> call() {
    return repository.getUsuarios();
  }
}

class GetStatsUsecase {
  final AdminRepository repository;

  GetStatsUsecase(this.repository);

  Future<UsuarioStats> call() {
    return repository.getStats();
  }
}
