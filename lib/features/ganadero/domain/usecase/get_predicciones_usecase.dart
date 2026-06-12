import 'package:ganajec/share/domain/entities/prediccion.dart';
import 'package:ganajec/features/ganadero/domain/repositories/ganadero_repository.dart';

class GetPredicionesUseCase {
  final GanaderoRepository repository;
  const GetPredicionesUseCase(this.repository);

  Future<List<Prediccion>> call() => repository.getUltimasPredicciones();
}
