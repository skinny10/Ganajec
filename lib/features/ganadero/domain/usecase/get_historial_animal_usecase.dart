import 'package:ganajec/share/domain/entities/historial_productivo.dart';
import '../repositories/ganadero_repository.dart';

class GetHistorialAnimalUseCase {
  final GanaderoRepository _repository;

  const GetHistorialAnimalUseCase(this._repository);

  Future<List<HistorialProductivo>> call(String animalId) =>
      _repository.getHistorialAnimal(animalId);
}
