import '../models/animal_model.dart';
import '../models/alerta_model.dart';
import '../models/prediccion_model.dart';

abstract class GanaderoRemoteDataSource {
  Future<List<AnimalModel>> getAnimales();
  Future<List<PrediccionModel>> getUltimasPredicciones();
  Future<List<AlertaModel>> getAlertas();
  Future<Map<String, int>> getResumenHato();
}

class GanaderoRemoteDataSourceImpl implements GanaderoRemoteDataSource {
  // Aquí irá Dio cuando conectes la API
  // final Dio dio;
  // GanaderoRemoteDataSourceImpl(this.dio);

  @override
  Future<List<AnimalModel>> getAnimales() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      AnimalModel(
        id: '1',
        ranchoId: 'r1',
        ganaderoId: 'g1',
        nombre: 'Lupita',
        raza: 'Holstein',
        sexo: 'hembra',
        fechaNacimiento: DateTime(2020, 3, 10),
        pesoKg: 480,
        idExterno: 'ID-0021',
        creadoEn: DateTime.now(),
      ),
      AnimalModel(
        id: '2',
        ranchoId: 'r1',
        ganaderoId: 'g1',
        nombre: 'Canela',
        raza: 'Suizo',
        sexo: 'hembra',
        fechaNacimiento: DateTime(2021, 6, 15),
        pesoKg: 420,
        idExterno: 'ID-0014',
        creadoEn: DateTime.now(),
      ),
      AnimalModel(
        id: '3',
        ranchoId: 'r1',
        ganaderoId: 'g1',
        nombre: 'Estrella',
        raza: 'Angus',
        sexo: 'hembra',
        fechaNacimiento: DateTime(2019, 1, 20),
        pesoKg: 510,
        idExterno: 'ID-0008',
        creadoEn: DateTime.now(),
      ),
      AnimalModel(
        id: '4',
        ranchoId: 'r1',
        ganaderoId: 'g1',
        nombre: 'Rosita',
        raza: 'Holstein',
        sexo: 'hembra',
        fechaNacimiento: DateTime(2022, 8, 5),
        pesoKg: 390,
        idExterno: 'ID-0033',
        creadoEn: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<PrediccionModel>> getUltimasPredicciones() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      PrediccionModel(
        id: 'p1',
        animalId: '1',
        animalNombre: 'Lupita',
        enfermedad: 'Mastitis',
        confianza: 0.87,
        fecha: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PrediccionModel(
        id: 'p2',
        animalId: '2',
        animalNombre: 'Canela',
        enfermedad: 'Laminitis leve',
        confianza: 0.72,
        fecha: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      PrediccionModel(
        id: 'p3',
        animalId: '3',
        animalNombre: 'Estrella',
        enfermedad: 'Sin enfermedad',
        confianza: 0.94,
        fecha: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  @override
  Future<List<AlertaModel>> getAlertas() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      AlertaModel(
        id: 'a1',
        animalId: '1',
        ganaderoId: 'g1',
        tipo: 'productiva',
        severidad: 'alta',
        mensaje: 'Lupita bajó 40% de leche en 3 días — revisa su estado',
        leida: false,
        creadoEn: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  @override
  Future<Map<String, int>> getResumenHato() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'total': 12,
      'en_buen_estado': 9,
      'con_alertas': 3,
    };
  }
}