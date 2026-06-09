import '../entities/alerta.dart';
import '../repositories/ganadero_repository.dart';

class GetAlertasUseCase {
  final GanaderoRepository repository;
  const GetAlertasUseCase(this.repository);

  Future<List<Alerta>> call() => repository.getAlertas();
}