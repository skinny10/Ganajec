import 'package:ganajec/core/domain/entities/animal.dart';
import 'package:ganajec/features/ganadero/domain/repositories/ganadero_repository.dart';

class CrearAnimalUseCase {
  final GanaderoRepository repository;
  const CrearAnimalUseCase(this.repository);

  Future<Animal> call(Animal animal) => repository.crearAnimal(animal);
}