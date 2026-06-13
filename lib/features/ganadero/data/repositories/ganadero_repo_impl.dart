import 'package:ganajec/share/domain/entities/alerta.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/historial_productivo.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import 'package:ganajec/share/domain/entities/registro_sintomas.dart';
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

  @override
  Future<List<HistorialProductivo>> getHistorialAnimal(String animalId) =>
      remoteDataSource.getHistorialAnimal(animalId);

  @override
  Future<List<Prediccion>> getPrediccionesAnimal(String animalId) =>
      remoteDataSource.getPrediccionesAnimal(animalId);

  @override
  Future<Animal> actualizarAnimal(Animal animal) =>
      remoteDataSource.actualizarAnimal(animal);

  @override
  Future<void> eliminarAnimal(String animalId) =>
      remoteDataSource.eliminarAnimal(animalId);

  @override
  Future<Prediccion> registrarSintomas(RegistroSintomas registro) =>
      remoteDataSource.registrarSintomas(registro);
}
