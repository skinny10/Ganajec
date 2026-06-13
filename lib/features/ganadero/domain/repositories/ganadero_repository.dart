import 'package:ganajec/share/domain/entities/alerta.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/historial_productivo.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import 'package:ganajec/share/domain/entities/registro_sintomas.dart';

abstract class GanaderoRepository {
  Future<List<Animal>> getAnimales();
  Future<List<Prediccion>> getUltimasPredicciones();
  Future<List<Alerta>> getAlertas();
  Future<Map<String, int>> getResumenHato();
  Future<Animal> crearAnimal(Animal animal);
  Future<List<HistorialProductivo>> getHistorialAnimal(String animalId);
  Future<List<Prediccion>> getPrediccionesAnimal(String animalId);
  Future<Animal> actualizarAnimal(Animal animal);
  Future<void> eliminarAnimal(String animalId);
  Future<Prediccion> registrarSintomas(RegistroSintomas registro);
}
