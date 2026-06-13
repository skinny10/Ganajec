import '../repositories/ganadero_repository.dart';

class EliminarAnimalUseCase {
  final GanaderoRepository _repository;

  const EliminarAnimalUseCase(this._repository);

  Future<void> call(String animalId) => _repository.eliminarAnimal(animalId);
}
