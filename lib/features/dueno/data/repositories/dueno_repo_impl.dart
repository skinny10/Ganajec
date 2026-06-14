import '../../domain/entities/dueno_dashboard.dart';
import '../../domain/repositories/dueno_repository.dart';
import '../datasources/dueno_remote_ds.dart';

class DuenoRepoImpl implements DuenoRepository {
  final DuenoRemoteDataSource dataSource;

  DuenoRepoImpl(this.dataSource);

  @override
  Future<DuenoDashboard> getDashboard(String duenoId) async {
    return await dataSource.getDashboard(duenoId);
  }

  @override
  Future<List<GanaderoResumen>> getGanaderos(String duenoId) async {
    return await dataSource.getGanaderos(duenoId);
  }
}
