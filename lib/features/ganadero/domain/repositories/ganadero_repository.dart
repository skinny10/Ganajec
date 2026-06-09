import '../entities/animal.dart';
import '../entities/alerta.dart';
import '../entities/prediccion.dart';

abstract class GanaderoRepository {
  Future<List<Animal>> getAnimales();
  Future<List<Prediccion>> getUltimasPredicciones();
  Future<List<Alerta>> getAlertas();
  Future<Map<String, int>> getResumenHato();
}