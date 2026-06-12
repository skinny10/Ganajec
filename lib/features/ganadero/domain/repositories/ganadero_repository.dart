import 'package:ganajec/share/domain/entities/alerta.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';

abstract class GanaderoRepository {
  Future<List<Animal>> getAnimales();
  Future<List<Prediccion>> getUltimasPredicciones();
  Future<List<Alerta>> getAlertas();
  Future<Map<String, int>> getResumenHato();
  Future<Animal> crearAnimal(Animal animal);
}
