import 'package:ganajec/share/domain/entities/alerta.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import 'package:ganajec/features/ganadero/domain/repositories/ganadero_repository.dart';
import 'package:ganajec/features/ganadero/data/datasource/ganadero_remote_ds.dart';

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

  @override
  Future<Animal> crearAnimal(Animal animal) =>
     remoteDataSource.crearAnimal(animal);
}
