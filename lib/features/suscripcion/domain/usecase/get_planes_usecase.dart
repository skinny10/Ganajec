import 'package:ganajec/share/domain/entities/plan.dart';
import '../repositories/suscripcion_repository.dart';

class GetPlanesUseCase {
  final SuscripcionRepository _repo;
  GetPlanesUseCase(this._repo);
  Future<List<Plan>> call() => _repo.getPlanes();
}
