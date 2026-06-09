import '../entities/prediccion.dart';
import '../repositories/ganadero_repository.dart';

class GetPredicionesUseCase {
  final GanaderoRepository repository;
  const GetPredicionesUseCase(this.repository);

  Future<List<Prediccion>> call() => repository.getUltimasPredicciones();
}