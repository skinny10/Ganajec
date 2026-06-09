import '../../domain/entities/animal.dart';
import '../../domain/entities/alerta.dart';
import '../../domain/entities/prediccion.dart';
import '../../domain/repositories/ganadero_repository.dart';
import '../datasource/ganadero_remote_ds.dart';

class GanaderoRepositoryImpl implements GanaderoRepository {
  final GanaderoRemoteDataSource remoteDataSource;

  const GanaderoRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Animal>> getAnimales() => remoteDataSource.getAnimales();

  @override
  Future<List<Prediccion>> getUltimasPredicciones() =>
      remoteDataSource.getUltimasPredicciones();

  @override
  Future<List<Alerta>> getAlertas() => remoteDataSource.getAlertas();

  @override
  Future<Map<String, int>> getResumenHato() =>
      remoteDataSource.getResumenHato();
}