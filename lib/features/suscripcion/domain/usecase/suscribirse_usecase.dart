import 'package:ganajec/share/domain/entities/plan.dart';
import '../repositories/suscripcion_repository.dart';

class SuscribirseUseCase {
  final SuscripcionRepository _repo;
  SuscribirseUseCase(this._repo);
  Future<bool> call(PlanTipo tipo, {required bool esAnual}) =>
      _repo.suscribirse(tipo, esAnual: esAnual);
}
