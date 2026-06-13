import 'package:ganajec/share/domain/entities/prediccion.dart';
import '../repositories/ganadero_repository.dart';

class GetPrediccionesAnimalUseCase {
  final GanaderoRepository _repository;

  const GetPrediccionesAnimalUseCase(this._repository);

  Future<List<Prediccion>> call(String animalId) =>
      _repository.getPrediccionesAnimal(animalId);
}
