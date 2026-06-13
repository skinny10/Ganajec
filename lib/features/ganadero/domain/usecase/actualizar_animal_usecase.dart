import 'package:ganajec/share/domain/entities/animal.dart';
import '../repositories/ganadero_repository.dart';

class ActualizarAnimalUseCase {
  final GanaderoRepository _repository;

  const ActualizarAnimalUseCase(this._repository);

  Future<Animal> call(Animal animal) => _repository.actualizarAnimal(animal);
}
